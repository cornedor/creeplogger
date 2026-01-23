type dailyLine = {
  name: string,
  creeps: int,
  games: int,
  score: int,
  goalDiff: int,
}

let getDailyOverview = async (period: string) => {
  let periodEnum = switch period {
  | "Daily" => Games.Daily
  | "Weekly" => Games.Weekly
  | "Monthly" => Games.Monthly
  | "All" => Games.All
  | _ => Games.Daily
  }
  let games = await Games.getTimePeriod(periodEnum)
  let players = await Players.fetchAllPlayers()

  let creepsMap = Map.make()

  // Simply sum up the stored score deltas from each game
  games->Dict.valuesToArray->Array.forEach(game => {
    let winner = game.blueScore > game.redScore ? Players.Blue : Players.Red
    let absGoalDiff = abs(game.blueScore - game.redScore)

    // Use stored score deltas if available, otherwise fall back to calculation
    switch game.scoreDeltas {
    | Some(deltas) => {
        // Sum up stored deltas
        deltas->Js.Dict.entries->Array.forEach(((playerKey, scoreDelta)) => {
          let player = players->Dict.get(playerKey)->Option.getOr({
            name: "Unknown",
            wins: 0,
            losses: 0,
            absoluteWins: 0,
            absoluteLosses: 0,
            games: 0,
            teamGoals: 0,
            teamGoalsAgainst: 0,
            blueGames: 0,
            redGames: 0,
            blueWins: 0,
            redWins: 0,
            elo: 1000.0,
            lastEloChange: 0.0,
            key: playerKey,
            mattermostHandle: None,
            lastGames: [],
            hidden: None,
            mu: 25.0,
            sigma: 8.333,
            ordinal: 0.0,
            lastOpenSkillChange: 0.0,
            dartsElo: 1000.0,
            dartsLastEloChange: 0.0,
            dartsGames: 0,
            dartsWins: 0,
            dartsLosses: 0,
            dartsLastGames: [],
            fifaGames: 0,
            fifaWins: 0,
            fifaLosses: 0,
            fifaLastGames: [],
            fifaGoalsScored: 0,
            fifaGoalsConceded: 0,
            fifaMu: 25.0,
            fifaSigma: 8.333,
            fifaOrdinal: 0.0,
            fifaLastOpenSkillChange: 0.0,
          })

          let lost = if game.blueTeam->Array.includes(playerKey) {
            winner == Players.Red
          } else {
            winner == Players.Blue
          }

          let goalDiffDelta = if game.blueTeam->Array.includes(playerKey) {
            if winner == Players.Red { -absGoalDiff } else { absGoalDiff }
          } else {
            if winner == Players.Blue { -absGoalDiff } else { absGoalDiff }
          }

          let {creeps, games, score, goalDiff} = Map.get(creepsMap, playerKey)->Option.getOr({
            name: player.name,
            creeps: 0,
            games: 0,
            score: 0,
            goalDiff: 0,
          })
          let (creeps, games, score, goalDiff) = if lost {
            (creeps + 1, games + 1, score + scoreDelta, goalDiff + goalDiffDelta)
          } else {
            (creeps + 0, games + 1, score + scoreDelta, goalDiff + goalDiffDelta)
          }
          Map.set(
            creepsMap,
            playerKey,
            {
              name: player.name,
              creeps,
              games,
              score,
              goalDiff,
            },
          )
        })
      }
    | None => {
        // Fallback: calculate deltas for old games without stored scoreDeltas
        // New games should always have scoreDeltas stored
        let blueTeamPlayers = game.blueTeam
          ->Array.map(key => players->Dict.get(key)->Option.getExn)
        let redTeamPlayers = game.redTeam
          ->Array.map(key => players->Dict.get(key)->Option.getExn)

        let (updatedBluePlayers, updatedRedPlayers, _) = switch winner {
        | Blue => OpenSkillRating.calculateScore(blueTeamPlayers, redTeamPlayers, ~gameMode=Games.Foosball)
        | Red => {
            let (red, blue, avg) = OpenSkillRating.calculateScore(
              redTeamPlayers,
              blueTeamPlayers,
              ~gameMode=Games.Foosball,
            )
            (blue, red, avg)
          }
        }

        updatedBluePlayers->Array.forEach(player => {
          let scoreDelta = OpenSkillRating.toDisplayDelta(player.lastOpenSkillChange)
          let lost = winner == Players.Red

          let {creeps, games, score, goalDiff} = Map.get(creepsMap, player.key)->Option.getOr({
            name: "",
            creeps: 0,
            games: 0,
            score: 0,
            goalDiff: 0,
          })
          let (creeps, games, score, goalDiff) = if lost {
            (creeps + 1, games + 1, score + scoreDelta, goalDiff - absGoalDiff)
          } else {
            (creeps + 0, games + 1, score + scoreDelta, goalDiff + absGoalDiff)
          }
          Map.set(
            creepsMap,
            player.key,
            {
              name: player.name,
              creeps,
              games,
              score,
              goalDiff,
            },
          )
        })

        updatedRedPlayers->Array.forEach(player => {
          let scoreDelta = OpenSkillRating.toDisplayDelta(player.lastOpenSkillChange)
          let lost = winner == Players.Blue

          let {creeps, games, score, goalDiff} = Map.get(creepsMap, player.key)->Option.getOr({
            name: "",
            creeps: 0,
            games: 0,
            score: 0,
            goalDiff: 0,
          })
          let (creeps, games, score, goalDiff) = if lost {
            (creeps + 1, games + 1, score + scoreDelta, goalDiff - absGoalDiff)
          } else {
            (creeps + 0, games + 1, score + scoreDelta, goalDiff + absGoalDiff)
          }
          Map.set(
            creepsMap,
            player.key,
            {
              name: player.name,
              creeps,
              games,
              score,
              goalDiff,
            },
          )
        })
      }
    }
  })

  creepsMap
}

let toAPIObject = data => {
  Map.entries(data)->Dict.fromIterator
}
