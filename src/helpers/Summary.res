type dailyLine = {
  name: string,
  creeps: int,
  games: int,
  score: int,
}

let getDailyOverviewWith = async (period, ~getTimePeriod, ~fetchAllPlayers) => {
  let games: Js.Dict.t<Games.game> = await getTimePeriod(period)
  let players: Js.Dict.t<Players.player> = await fetchAllPlayers()

  let creepsMap = Map.make()

  games
  ->Dict.valuesToArray
  ->Array.forEach(game => {
    let winner = game.blueScore > game.redScore ? Players.Blue : Players.Red
    let isAbsolute = abs(game.blueScore - game.redScore) == 7

    game.blueTeam->Array.forEach(player => {
      let {creeps, games, score} = Map.get(creepsMap, player)->Option.getOr({
        name: "",
        creeps: 0,
        games: 0,
        score: 0,
      })
      let (creeps, games, score) = switch (winner, isAbsolute) {
      | (Red, true) => (creeps + 2, games + 1, score - game.redScore)
      | (Red, false) => (creeps + 1, games + 1, score - game.redScore)
      | (Blue, _) => (creeps + 0, games + 1, score + game.blueScore)
      }
      Map.set(
        creepsMap,
        player,
        {
          name: (players->Dict.get(player)->Option.getUnsafe).name,
          creeps,
          games,
          score,
        },
      )
    })
    game.redTeam->Array.forEach(player => {
      let {creeps, games, score} = Map.get(creepsMap, player)->Option.getOr({
        name: "",
        creeps: 0,
        games: 0,
        score: 0,
      })
      let (creeps, games, score) = switch (winner, isAbsolute) {
      | (Blue, true) => (creeps + 2, games + 1, score - game.blueScore)
      | (Blue, false) => (creeps + 1, games + 1, score - game.blueScore)
      | (Red, _) => (creeps + 0, games + 1, score + game.redScore)
      }
      Map.set(
        creepsMap,
        player,
        {
          name: (players->Dict.get(player)->Option.getUnsafe).name,
          creeps,
          games,
          score,
        },
      )
    })
  })

  creepsMap
}

let getDailyOverview = async period => {
  let result = await getDailyOverviewWith(
    period,
    ~getTimePeriod=Games.getTimePeriod,
    ~fetchAllPlayers=Players.fetchAllPlayers,
  )
  result
}

let toAPIObject = data => {
  Map.entries(data)->Dict.fromIterator
}
