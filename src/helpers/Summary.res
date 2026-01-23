type dailyLine = {
  name: string,
  creeps: int,
  games: int,
  score: int,
  goalDiff: int,
}

let getDailyOverview = async period => {
  let games = await Games.getTimePeriod(period)
  let players = await Players.fetchAllPlayers()

  let creepsMap = Map.make()

  // Simply sum up the stored score deltas from each game
  games->Dict.valuesToArray->Array.forEach(game => {
    let winner = game.blueScore > game.redScore ? Players.Blue : Players.Red
    let absGoalDiff = abs(game.blueScore - game.redScore)

    // Sum up stored score deltas (all new games have these)
    let deltas = game.scoreDeltas->Option.getExn
    deltas->Js.Dict.entries->Array.forEach(((playerKey, scoreDelta)) => {
      let player = players->Dict.get(playerKey)->Option.getExn

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
  })

  creepsMap
}

let toAPIObject = data => {
  Map.entries(data)->Dict.fromIterator
}
