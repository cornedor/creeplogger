open Firebase

let _ignoreOpenSkill = OpenSkillRating.roundScore(0.0)

type stats = {
  totalGames: int,
  totalRedWins: int,
  totalBlueWins: int,
  totalAbsoluteWins: int,
  totalDartsGames: int,
}

let statsSchema = Schema.object(s => {
  totalGames: s.fieldOr("games", Schema.int, 0),
  totalRedWins: s.fieldOr("redWins", Schema.int, 0),
  totalBlueWins: s.fieldOr("blueWins", Schema.int, 0),
  totalAbsoluteWins: s.fieldOr("absoluteWins", Schema.int, 0),
  totalDartsGames: s.fieldOr("dartsGames", Schema.int, 0),
})

let empty: stats = {
  totalGames: 0,
  totalRedWins: 0,
  totalBlueWins: 0,
  totalAbsoluteWins: 0,
  totalDartsGames: 0,
}

let bucket = "stats"

let fetchStats = async () => {
  let stats = await Firebase.Database.refPath(Database.database, bucket)->Firebase.Database.get
  switch stats->Firebase.Database.Snapshot.val->Js.toOption {
  | Some(stats) =>
    switch Schema.parseWith(stats, statsSchema) {
    | Ok(stats) => Some(stats)
    | Error(error) => {
        Console.error(error)
        None
      }
    }
  | None => None
  }
}

let useStats = () => {
  let (stats, setStats) = React.useState(_ => empty)
  let statsRef = Firebase.Database.refPath(Database.database, bucket)
  React.useEffect(() => {
    let unsubscribe = Firebase.Database.onValue(
      statsRef,
      snapshot => {
        switch snapshot->Firebase.Database.Snapshot.val->Js.toOption {
        | Some(stats) =>
          switch Schema.parseWith(stats, statsSchema) {
          | Ok(stats) => setStats(_ => stats)
          | Error(error) => Console.error(error)
          }
        | None => ()
        }
      },
      (),
    )

    Some(unsubscribe)
  }, [])

  stats
}

let updateStats = async (redScore, blueScore) => {
  let blueWin = Rules.isBlueWin(redScore, blueScore)
  let redWin = Rules.isRedWin(redScore, blueScore)
  let isAbsolute = Rules.isAbsolute(redScore, blueScore)
  let statsRef = Firebase.Database.refPath(Database.database, bucket)
  Firebase.Database.runTransaction(statsRef, data => {
    switch data->Schema.parseWith(statsSchema) {
    | Ok(data) => {
        let newData = Schema.reverseConvertToJsonWith(
          {
            ...data,
            totalGames: data.totalGames + 1,
            totalRedWins: data.totalRedWins + (redWin ? 1 : 0),
            totalBlueWins: data.totalBlueWins + (blueWin ? 1 : 0),
            totalAbsoluteWins: data.totalAbsoluteWins + (isAbsolute ? 1 : 0),
          },
          statsSchema,
        )
        newData
      }
    | Error(_) => panic("Failed parsing stats")
    }
  })
}

let updateDartsStats = async () => {
  let statsRef = Firebase.Database.refPath(Database.database, bucket)
  Firebase.Database.runTransaction(statsRef, data => {
    switch data->Schema.parseWith(statsSchema) {
    | Ok(data) => {
        let newData = Schema.reverseConvertToJsonWith(
          {
            ...data,
            totalDartsGames: data.totalDartsGames + 1,
          },
          statsSchema,
        )
        newData
      }
    | Error(_) => panic("Failed parsing stats")
    }
  })
}

let writeStats = async stats => {
  let statsRef = Firebase.Database.refPath(Database.database, bucket)
  let data = switch stats->Schema.serializeWith(statsSchema) {
  | Ok(data) => {
      Js.log2("Log", data)
      data
    }
  | Error(_) => panic("Could not serialize stats")
  }
  await Firebase.Database.set(statsRef, data)
}

let recalculateStats = async () => {
  let games = await Games.fetchAllGames()
  let dartsGames = await DartsGames.fetchAllGames()
  let players = await Players.fetchAllPlayers()

  let playerKeys = Dict.keysToArray(players)
  Array.forEach(playerKeys, key => {
    let player = Dict.get(players, key)->Option.getExn
    Dict.set(
      players,
      key,
      {
        ...player,
        // Regular game stats
        games: 0,
        teamGoals: 0,
        teamGoalsAgainst: 0,
        redGames: 0,
        blueGames: 0,
        wins: 0,
        losses: 0,
        absoluteLosses: 0,
        absoluteWins: 0,
        redWins: 0,
        blueWins: 0,
        // Reset Elo for foosball to baseline (same as darts)
        elo: 1000.0,
        lastEloChange: 0.0,
        // Reset OpenSkill fields
        mu: 25.0,
        sigma: 8.333,
        ordinal: 0.0,
        lastGames: [],
        // Darts game stats
        dartsGames: 0,
        dartsWins: 0,
        dartsLosses: 0,
        dartsElo: 1000.0,
        dartsLastEloChange: 0.0,
        dartsLastGames: [],
      },
    )
  })

  let stats: stats = empty

  // Process regular games
  let stats = games->Array.reduce(stats, (stats, game) => {
    let blueWin = Rules.isBlueWin(game.redScore, game.blueScore)
    let redWin = Rules.isRedWin(game.redScore, game.blueScore)
    let isAbsolute = Rules.isAbsolute(game.redScore, game.blueScore)

    let redPlayers = game.redTeam->Array.map(key => Dict.get(players, key)->Option.getExn)
    let bluePlayers = game.blueTeam->Array.map(key => Dict.get(players, key)->Option.getExn)

    let (bluePlayers, redPlayers, _) = switch blueWin {
    | true => OpenSkillRating.calculateScore(bluePlayers, redPlayers, ~gameMode=Games.Foosball)
    | false => {
        let (red, blue, points) = OpenSkillRating.calculateScore(
          redPlayers,
          bluePlayers,
          ~gameMode=Games.Foosball,
        )
        (blue, red, points)
      }
    }
    
    // Also calculate Elo for foosball games (for legacy compatibility)
    let (blueElo, redElo, _) = switch blueWin {
    | true => Elo.calculateScore(bluePlayers, redPlayers, ~gameMode=Games.Foosball)
    | false => {
        let (red, blue, points) = Elo.calculateScore(
          redPlayers,
          bluePlayers,
          ~gameMode=Games.Foosball,
        )
        (blue, red, points)
      }
    }
    
    let bluePlayers = blueElo
    let redPlayers = redElo
    Array.forEach(bluePlayers, player => {
      let lastGames = Players.getLastGames(player.lastGames, blueWin)
      Dict.set(
        players,
        player.key,
        {
          ...player,
          games: player.games + 1,
          teamGoals: player.teamGoals + game.blueScore,
          teamGoalsAgainst: player.teamGoalsAgainst + game.redScore,
          blueGames: player.blueGames + 1,
          wins: blueWin ? player.wins + 1 : player.wins,
          losses: redWin ? player.losses + 1 : player.losses,
          absoluteLosses: redWin && isAbsolute ? player.absoluteLosses + 1 : player.absoluteLosses,
          absoluteWins: blueWin && isAbsolute ? player.absoluteWins + 1 : player.absoluteWins,
          blueWins: blueWin ? player.blueWins + 1 : player.blueWins,
          lastGames,
        },
      )
    })
    Array.forEach(redPlayers, player => {
      let lastGames = Players.getLastGames(player.lastGames, redWin)
      Dict.set(
        players,
        player.key,
        {
          ...player,
          games: player.games + 1,
          teamGoals: player.teamGoals + game.redScore,
          teamGoalsAgainst: player.teamGoalsAgainst + game.blueScore,
          redGames: player.redGames + 1,
          wins: redWin ? player.wins + 1 : player.wins,
          losses: blueWin ? player.losses + 1 : player.losses,
          absoluteLosses: blueWin && isAbsolute ? player.absoluteLosses + 1 : player.absoluteLosses,
          absoluteWins: redWin && isAbsolute ? player.absoluteWins + 1 : player.absoluteWins,
          redWins: redWin ? player.redWins + 1 : player.redWins,
          lastGames,
        },
      )
    })

    {
      totalGames: stats.totalGames + 1,
      totalRedWins: stats.totalRedWins + (redWin ? 1 : 0),
      totalBlueWins: stats.totalBlueWins + (blueWin ? 1 : 0),
      totalAbsoluteWins: stats.totalAbsoluteWins + (isAbsolute ? 1 : 0),
      totalDartsGames: stats.totalDartsGames,
    }
  })

  // Process darts games
  let stats = dartsGames->Array.reduce(stats, (stats, game) => {
    let winners = game.winners->Array.map(key => Dict.get(players, key)->Option.getExn)
    let losers = game.losers->Array.map(key => Dict.get(players, key)->Option.getExn)

    let (winners, losers, _) = Elo.calculateScore(winners, losers, ~gameMode=Games.Darts)

    Array.forEach(winners, player => {
      let lastGames = Players.getLastGames(player.dartsLastGames, true)
      Dict.set(
        players,
        player.key,
        {
          ...player,
          dartsGames: player.dartsGames + 1,
          dartsWins: player.dartsWins + 1,
          dartsLastGames: lastGames,
          dartsElo: player.dartsElo,
          dartsLastEloChange: player.dartsLastEloChange,
        },
      )
    })

    Array.forEach(losers, player => {
      let lastGames = Players.getLastGames(player.dartsLastGames, false)
      Dict.set(
        players,
        player.key,
        {
          ...player,
          dartsGames: player.dartsGames + 1,
          dartsLosses: player.dartsLosses + 1,
          dartsLastGames: lastGames,
          dartsElo: player.dartsElo,
          dartsLastEloChange: player.dartsLastEloChange,
        },
      )
    })

    {
      ...stats,
      totalDartsGames: stats.totalDartsGames + 1,
    }
  })

  Js.log(stats)
  Js.log(players)

  let _ = await Promise.all(
    playerKeys->Array.map(key => {
      let player = Dict.get(players, key)->Option.getExn
      Players.writePlayer(player)
    }),
  )

  await writeStats(stats)
  stats
}
