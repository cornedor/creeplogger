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

  games
  ->Dict.valuesToArray
  ->Array.forEach(game => {
    let winner = game.blueScore > game.redScore ? Players.Blue : Players.Red
    let isAbsolute = abs(game.blueScore - game.redScore) == 7
    let absGoalDiff = abs(game.blueScore - game.redScore)
    // todo: collect game points
    let gamePoints = 16

    game.blueTeam->Array.forEach(player => {
      let {creeps, games, score, goalDiff} = Map.get(creepsMap, player)->Option.getOr({
        name: "",
        creeps: 0,
        games: 0,
        score: 0,
        goalDiff: 0,
      })
      let (creeps, games, score, goalDiff) = switch (winner, isAbsolute) {
      | (Red, true) => (creeps + 2, games + 1, score - gamePoints, goalDiff - absGoalDiff)
      | (Red, false) => (creeps + 1, games + 1, score - gamePoints, goalDiff - absGoalDiff)
      | (Blue, _) => (creeps + 0, games + 1, score + gamePoints, goalDiff + absGoalDiff)
      }
      Map.set(
        creepsMap,
        player,
        {
          name: (players->Dict.get(player)->Option.getUnsafe).name,
          creeps,
          games,
          score,
          goalDiff,
        },
      )
    })
    game.redTeam->Array.forEach(player => {
      let {creeps, games, score, goalDiff} = Map.get(creepsMap, player)->Option.getOr({
        name: "",
        creeps: 0,
        games: 0,
        score: 0,
        goalDiff: 0,
      })
      let (creeps, games, score, goalDiff) = switch (winner, isAbsolute) {
      | (Blue, true) => (creeps + 2, games + 1, score - gamePoints, goalDiff - absGoalDiff)
      | (Blue, false) => (creeps + 1, games + 1, score - gamePoints, goalDiff - absGoalDiff)
      | (Red, _) => (creeps + 0, games + 1, score + gamePoints, goalDiff + absGoalDiff)
      }
      Map.set(
        creepsMap,
        player,
        {
          name: (players->Dict.get(player)->Option.getUnsafe).name,
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
