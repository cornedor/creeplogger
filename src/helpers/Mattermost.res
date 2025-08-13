@@directive("'use server';")
open OpenSkillRating
let url = %raw(`process.env.MATTERMOST_URL`)
let isEnabled = %raw(`process.env.MATTERMOST_ENABLED`) == "true"

type mattermostMessage = {text: string}

let publishMessage = (message: string) => {
  switch (url, isEnabled) {
  | (None, true) => panic("MATTERMOST_URL not set")
  | (Some(url), true) =>
    Some(
      Fetch.fetch(
        url,
        {
          method: #POST,
          body: Fetch.Body.string(
            JSON.stringifyAny({
              text: message,
            })->Option.getExn,
          ),
        },
      ),
    )
  | _ => None
  }
}

let sendCreepsUpdate = async (
  bluePlayers: array<Players.player>,
  redPlayers: array<Players.player>,
  blueScore: int,
  redScore: int,
  points: int,
) => {
  let blueNames =
    bluePlayers
    ->Array.map(player =>
      switch player.mattermostHandle {
      | Some(handle) => `@${handle}`
      | None => player.name
      }
    )
    ->Array.join(", ")
  let redNames =
    redPlayers
    ->Array.map(player =>
      switch player.mattermostHandle {
      | Some(handle) => `@${handle}`
      | None => player.name
      }
    )
    ->Array.join(", ")

  let bluePoints = blueScore < redScore ? 0 - points : points
  let redPoints = blueScore > redScore ? 0 - points : points

  // Determine winning team and compute per-player OpenSkill deltas
  let winningTeam = if blueScore > redScore { Players.Blue } else { Players.Red }

  let (winnersOS, losersOS, _avgWinnerChange) = switch winningTeam {
  | Blue => OpenSkillRating.calculateScore(bluePlayers, redPlayers, ~gameMode=Games.Foosball)
  | Red => {
      let (red, blue, avg) = OpenSkillRating.calculateScore(
        redPlayers,
        bluePlayers,
        ~gameMode=Games.Foosball,
      )
      (red, blue, avg)
    }
  }

  let formatHandleOrName = (player: Players.player) =>
    switch player.mattermostHandle {
    | Some(handle) => `@${handle}`
    | None => player.name
    }

  let winnersStr =
    winnersOS
    ->Array.map(player => {
      let delta = OpenSkillRating.toDisplayDelta(player.lastOpenSkillChange)
      let sign = delta >= 0 ? "+" : ""
      `${formatHandleOrName(player)} (${sign}${delta->Int.toString})`
    })
    ->Array.join(", ")

  let losersStr =
    losersOS
    ->Array.map(player => {
      let delta = OpenSkillRating.toDisplayDelta(player.lastOpenSkillChange)
      let sign = delta >= 0 ? "+" : ""
      `${formatHandleOrName(player)} (${sign}${delta->Int.toString})`
    })
    ->Array.join(", ")

  let blueIndividuals = switch winningTeam {
  | Blue => winnersStr
  | Red => losersStr
  }

  let redIndividuals = switch winningTeam {
  | Blue => losersStr
  | Red => winnersStr
  }

  // Pre-game win probability based on OpenSkill
  let blueWinProb = OpenSkillRating.getWinProbability(bluePlayers, redPlayers) *. 100.0
  let redWinProb = 100.0 -. blueWinProb
  let blueProbRounded = (blueWinProb *. 10.0)->Js.Math.round /. 10.0
  let redProbRounded = (redWinProb *. 10.0)->Js.Math.round /. 10.0
  let blueProbStr = blueProbRounded->Float.toString
  let redProbStr = redProbRounded->Float.toString

  let message = `### Nieuw potje geregistreerd!

| Team | Goals | OpenSkill Δ |
| ---- | ----- | ----------- |
| ${blueNames} | ${blueScore->Int.toString} | ${bluePoints->Int.toString} |
| ${redNames} | ${redScore->Int.toString} | ${redPoints->Int.toString} |

Individueel:
- Blauw: ${blueIndividuals}
- Rood: ${redIndividuals}

OpenSkill winstkans (pre-game): Blauw ${blueProbStr}% vs Rood ${redProbStr}%
`

  switch publishMessage(message) {
  | Some(promise) =>
    let _ = await promise
  | None => ()
  }

  0
}

let sendDartsUpdate = async (
  winners: array<Players.player>,
  losers: array<Players.player>,
  points: int,
  mode: string,
) => {
  let winnerNames =
    winners
    ->Array.map(player =>
      switch player.mattermostHandle {
      | Some(handle) => `@${handle}`
      | None => player.name
      }
    )
    ->Array.join(", ")
  let loserNames =
    losers
    ->Array.map(player =>
      switch player.mattermostHandle {
      | Some(handle) => `@${handle}`
      | None => player.name
      }
    )
    ->Array.join(", ")

  let message = `### 🎯 Nieuw darts potje geregistreerd!

Winnaar: ${winnerNames} (+${points->Int.toString})
Verliezer: ${loserNames} (-${points->Int.toString})
Game mode: ${mode}
`

  switch publishMessage(message) {
  | Some(promise) =>
    let _ = await promise
  | None => ()
  }

  0
}

let sendDailyUpdate = async () => {
  let overview = await Summary.getDailyOverview(Daily)
  let overviewArray =
    overview
    ->Map.values
    ->Core__Iterator.toArray
    ->Array.toSorted((a, b) => {
      let a = Int32.shift_left(a.creeps, 16) - Int32.shift_left(a.games, 8) - a.score
      let b = Int32.shift_left(b.creeps, 16) - Int32.shift_left(b.games, 8) - b.score
      b->Int.toFloat -. a->Int.toFloat
    })

  switch Array.length(overviewArray) {
  | 0 => false
  | _ => {
      let table =
        overviewArray
        ->Array.mapWithIndex((creeper, index) =>
          "| " ++
          Int.toString(index + 1) ++
          " | " ++
          creeper.name ++
          " | " ++
          creeper.creeps->Int.toString ++
          " | " ++
          creeper.games->Int.toString ++
          " | " ++
          creeper.score->Int.toString ++ " |"
        )
        ->Array.join("\n")

      let topCreeper = overviewArray[0]->Option.getExn

      let intro = `### De kruip statistieken van vandaag zijn bekend!

Feliciteer direct onze top kruiper van de dag: ${topCreeper.name} met maar liefst ${topCreeper.creeps->Int.toString} kruipjes en een netto score van ${topCreeper.score->Int.toString}!

| # | Naam | Kruipjes | Potjes | Netto Score |
| - | ---- | -------- | ------ | ----------- |
${table}

`

      switch publishMessage(intro) {
      | Some(prom) =>
        let _ = await prom
        true
      | None => {
          Js.log(intro)
          false
        }
      }
    }
  }
}

let sendDaysWithoutReset = async (name: string) => {
  let message = `${name} is reset`

  switch publishMessage(message) {
  | Some(promise) =>
    let _ = await promise
  | None => ()
  }

  0
}
