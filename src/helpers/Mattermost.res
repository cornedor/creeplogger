@@directive("'use server';")
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
    ->Array.joinWith(", ")
  let redNames =
    redPlayers
    ->Array.map(player =>
      switch player.mattermostHandle {
      | Some(handle) => `@${handle}`
      | None => player.name
      }
    )
    ->Array.joinWith(", ")

  let bluePoints = blueScore < redScore ? 0 - points : points
  let redPoints = blueScore > redScore ? 0 - points : points

  let message = `### Nieuw potje geregistreerd!

| Team | Goals | Punten |
| ---- | ----- | ------ |
| ${blueNames} | ${blueScore->Int.toString} | ${bluePoints->Int.toString} |
| ${redNames} | ${redScore->Int.toString} | ${redPoints->Int.toString} |
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
      let a = Int32.shift_left(a.creeps, 16) - a.games
      let b = Int32.shift_left(b.creeps, 16) - b.games
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
          creeper.games->Int.toString ++ " |"
        )
        ->Array.joinWith("\n")

      let topCreeper = overviewArray[0]->Option.getExn

      let intro = `### De kruip statistieken van vandaag zijn bekend!

Feliciteer direct onze top kruiper van de dag: ${topCreeper.name} met maarliefst ${topCreeper.creeps->Int.toString} kruipjes!

| # | Naam | Kruipjes | Potjes |
| - | ---- | -------- | ------ | 
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
