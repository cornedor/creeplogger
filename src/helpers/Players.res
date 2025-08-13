open Firebase

type player = {
  name: string,
  wins: int,
  losses: int,
  absoluteWins: int,
  absoluteLosses: int,
  games: int,
  teamGoals: int,
  teamGoalsAgainst: int,
  blueGames: int,
  redGames: int,
  blueWins: int,
  redWins: int,
  elo: float,
  lastEloChange: float,
  key: string,
  mattermostHandle: option<string>,
  lastGames: array<int>,
  hidden: option<bool>,
  // OpenSkill fields
  mu: float,
  sigma: float,
  ordinal: float,
  lastOpenSkillChange: float,
  dartsElo: float,
  dartsLastEloChange: float,
  dartsGames: int,
  dartsWins: int,
  dartsLosses: int,
  dartsLastGames: array<int>,
}

type team = Blue | Red

@inline
let bucket = "players"

let playerSchema = Schema.object(s => {
  name: s.field("name", Schema.string),
  wins: s.fieldOr("wins", Schema.int, 0),
  losses: s.fieldOr("losses", Schema.int, 0),
  absoluteWins: s.fieldOr("absoluteWins", Schema.int, 0),
  absoluteLosses: s.fieldOr("absoluteLosses", Schema.int, 0),
  games: s.fieldOr("games", Schema.int, 0),
  teamGoals: s.fieldOr("teamGoals", Schema.int, 0),
  teamGoalsAgainst: s.fieldOr("teamGoalsAgainst", Schema.int, 0),
  blueGames: s.fieldOr("blueGames", Schema.int, 0),
  redGames: s.fieldOr("redGames", Schema.int, 0),
  blueWins: s.fieldOr("blueWins", Schema.int, 0),
  redWins: s.fieldOr("redWins", Schema.int, 0),
  elo: s.fieldOr("elo", Schema.float, 1000.0),
  lastEloChange: s.fieldOr("change", Schema.float, 0.0),
  key: s.field("key", Schema.string),
  mattermostHandle: s.field("mh", Schema.option(Schema.string)->FirebaseSchema.nullableTransform),
  lastGames: s.fieldOr("lastGames", Schema.array(Schema.int), []),
  hidden: s.field("hidden", Schema.option(Schema.bool)->FirebaseSchema.nullableTransform),
  mu: s.fieldOr("mu", Schema.float, 25.0),
  sigma: s.fieldOr("sigma", Schema.float, 8.333),
  ordinal: s.fieldOr("ordinal", Schema.float, 0.0),
  lastOpenSkillChange: s.fieldOr("osChange", Schema.float, 0.0),
  dartsElo: s.fieldOr("dartsElo", Schema.float, 1000.0),
  dartsLastEloChange: s.fieldOr("dartsChange", Schema.float, 0.0),
  dartsGames: s.fieldOr("dartsGames", Schema.int, 0),
  dartsWins: s.fieldOr("dartsWins", Schema.int, 0),
  dartsLosses: s.fieldOr("dartsLosses", Schema.int, 0),
  dartsLastGames: s.fieldOr("dartsLastGames", Schema.array(Schema.int), []),
})

let playersSchema = Schema.dict(playerSchema)

let addPlayer = async name => {
  let playersRef = Firebase.Database.refPath(Database.database, bucket)
  let data = switch {
    name,
    wins: 0,
    losses: 0,
    absoluteWins: 0,
    absoluteLosses: 0,
    games: 0,
    teamGoals: 0,
    teamGoalsAgainst: 0,
    redGames: 0,
    blueGames: 0,
    redWins: 0,
    blueWins: 0,
    elo: 1000.0,
    lastEloChange: 0.0,
    key: "",
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
  }->Schema.serializeWith(playerSchema) {
  | Ok(data) => data
  | Error(_error) => panic("Could not serialize player")
  }
  let ref = await Firebase.Database.pushValue(playersRef, data)
  switch ref["key"]->Js.Nullable.toOption {
  | Some(key) =>
    await Firebase.Database.set(
      Firebase.Database.refPath(Database.database, bucket ++ "/" ++ key ++ "/key"),
      key,
    )
  | None => ()
  }
  ref
}

type playersOrder = [#games | #elo | #rating | #dartsElo]

// let sortPlayersBy(orderBy: playersOrder)

external snapshotToArray: dataSnapshot => array<dataSnapshot> = "%identity"

let useAllPlayers = (~orderBy: playersOrder=#rating, ~asc=false) => {
  let (players, setPlayers) = React.useState(_ => [])
  React.useEffect(() => {
    let isClient: bool = %raw("typeof window !== 'undefined'")
    if !isClient {
      None
    } else {
      let playersRef = Firebase.Database.refPath(Database.database, bucket)
      let unsubscribe = Firebase.Database.onValue(
        Firebase.Database.query1(playersRef, Firebase.Database.orderByChild("games")),
        snapshot => {
          let newPlayers = []
          Array.forEach(snapshotToArray(snapshot), snap => {
            switch Firebase.Database.Snapshot.val(snap)->Nullable.toOption {
            | Some(val) =>
              switch val->Schema.parseWith(playerSchema) {
              | Ok(player) => Array.push(newPlayers, player)
              | Error(_e) => ()
              }
            | None => ()
            }
          })
                  setPlayers(_ => newPlayers)
        },
        (),
      )

      Some(unsubscribe)
    }
  }, [setPlayers])

  let cmpInsensitive = (a, b) => {
    let al = Js.String2.toLowerCase(a)
    let bl = Js.String2.toLowerCase(b)
    if al < bl { -1 } else if al > bl { 1 } else { 0 }
  }

  React.useMemo(() =>
    players->Array.toSorted((a, b) => {
      let (x, y) = asc ? (a, b) : (b, a)
      let primary = switch orderBy {
      | #games => Int.toFloat(x.games - y.games)
      | #elo => x.elo -. y.elo
      | #rating => x.ordinal -. y.ordinal
      | #dartsElo => x.dartsElo -. y.dartsElo
      }
      if primary == 0.0 {
        let nameCmp = cmpInsensitive(x.name, y.name)
        if nameCmp == 0 {
          Int.toFloat(cmpInsensitive(x.key, y.key))
        } else {
          Int.toFloat(nameCmp)
        }
      } else {
        primary
      }
    })
  , (players, asc, orderBy))
}

let fetchAllPlayers = async () => {
  let playersRef = Firebase.Database.refPath(Database.database, bucket)

  let data = await Firebase.Database.get(playersRef)
  let empty: Js.Dict.t<player> = Js.Dict.empty()

  switch Firebase.Database.Snapshot.val(data)->Js.toOption {
  | Some(data) =>
    switch data->Schema.parseWith(playersSchema) {
    | Ok(players) => players
    | Error(_) => empty
    }
  | None => empty
  }
}

let fetchPlayerByKey = async key => {
  let playerRef = Firebase.Database.refPath(Database.database, bucket ++ "/" ++ key)
  let data = await Firebase.Database.get(playerRef)
  switch Firebase.Database.Snapshot.val(data)->Js.toOption {
  | Some(player) =>
    switch player->Schema.parseWith(playerSchema) {
    | Ok(player) => Some(player)
    | Error(error) => {
        Console.error(error)
        None
      }
    }
  | None => None
  }
}

let playerByKey = (players, key) => players->Array.find(c => c.key == key)

let writePlayer = (player: player) => {
  let playerRef = Firebase.Database.refPath(Database.database, bucket ++ "/" ++ player.key)
  Firebase.Database.set(playerRef, Schema.reverseConvertToJsonWith(player, playerSchema))
}

let getLastGames = (lastGames, win) => {
  let newGames = Array.concat(lastGames, [win ? 1 : 0])
  newGames->Array.sliceToEnd(~start=-5)
}

let updateGameStats = (key, myTeamPoints, opponentTeamPoints, team: team, elo) => {
  let isAbsolute = Rules.isAbsolute(myTeamPoints, opponentTeamPoints)

  let isWin = myTeamPoints > opponentTeamPoints
  let isAbsoluteWin = isAbsolute && isWin
  let isLoss = myTeamPoints < opponentTeamPoints
  let isAbsoluteLoss = isAbsolute && isLoss
  let isRedWin = team == Red && isWin
  let isBlueWin = team == Blue && isWin

  let playerRef = Firebase.Database.refPath(Database.database, bucket ++ "/" ++ key)
  Firebase.Database.runTransaction(playerRef, data => {
    switch data->Schema.parseWith(playerSchema) {
    | Ok(player) =>
      switch Schema.serializeWith(
        {
          ...player,
          games: player.games + 1,
          teamGoals: player.teamGoals + myTeamPoints,
          teamGoalsAgainst: player.teamGoalsAgainst + opponentTeamPoints,
          redGames: team == Red ? player.redGames + 1 : player.redGames,
          blueGames: team == Blue ? player.blueGames + 1 : player.blueGames,
          wins: isWin ? player.wins + 1 : player.wins,
          losses: isLoss ? player.losses + 1 : player.losses,
          absoluteLosses: isAbsoluteLoss ? player.absoluteLosses + 1 : player.absoluteLosses,
          absoluteWins: isAbsoluteWin ? player.absoluteWins + 1 : player.absoluteWins,
          redWins: isRedWin ? player.redWins + 1 : player.redWins,
          blueWins: isBlueWin ? player.blueWins + 1 : player.blueWins,
          lastEloChange: elo -. player.elo,
          elo,
          lastGames: getLastGames(player.lastGames, isWin),
        },
        playerSchema,
      ) {
      | Ok(res) => res
      | _ => data
      }
    | Error(_) => data
    }
  })
}

// Update stats using OpenSkill values, while preserving Elo field untouched here
let updateOpenSkillGameStats = (
  key,
  myTeamPoints,
  opponentTeamPoints,
  team: team,
  mu,
  sigma,
  ordinal,
) => {
  let isAbsolute = Rules.isAbsolute(myTeamPoints, opponentTeamPoints)

  let isWin = myTeamPoints > opponentTeamPoints
  let isAbsoluteWin = isAbsolute && isWin
  let isLoss = myTeamPoints < opponentTeamPoints
  let isAbsoluteLoss = isAbsolute && isLoss
  let isRedWin = team == Red && isWin
  let isBlueWin = team == Blue && isWin

  let playerRef = Firebase.Database.refPath(Database.database, bucket ++ "/" ++ key)
  Firebase.Database.runTransaction(playerRef, data => {
    switch data->Schema.parseWith(playerSchema) {
    | Ok(player) =>
      switch Schema.serializeWith(
        {
          ...player,
          games: player.games + 1,
          teamGoals: player.teamGoals + myTeamPoints,
          teamGoalsAgainst: player.teamGoalsAgainst + opponentTeamPoints,
          redGames: team == Red ? player.redGames + 1 : player.redGames,
          blueGames: team == Blue ? player.blueGames + 1 : player.blueGames,
          wins: isWin ? player.wins + 1 : player.wins,
          losses: isLoss ? player.losses + 1 : player.losses,
          absoluteLosses: isAbsoluteLoss ? player.absoluteLosses + 1 : player.absoluteLosses,
          absoluteWins: isAbsoluteWin ? player.absoluteWins + 1 : player.absoluteWins,
          redWins: isRedWin ? player.redWins + 1 : player.redWins,
          blueWins: isBlueWin ? player.blueWins + 1 : player.blueWins,
          // Do not touch Elo deltas here; Elo updates elsewhere
          lastEloChange: player.lastEloChange,
          mu,
          sigma,
          ordinal,
          lastOpenSkillChange: ordinal -. player.ordinal,
          // Keep existing Elo untouched
          elo: player.elo,
          lastGames: getLastGames(player.lastGames, isWin),
        },
        playerSchema,
      ) {
      | Ok(res) => res
      | _ => data
      }
    | Error(_) => data
    }
  })
}

// In darts team points are 0 if the player lost, or 1 of the player won.
let updateDartsGameStats = (key, myTeamPoints, elo) => {
  let isWin = myTeamPoints == 1
  let isLoss = myTeamPoints == 0

  let playerRef = Firebase.Database.refPath(Database.database, bucket ++ "/" ++ key)
  Firebase.Database.runTransaction(playerRef, data => {
    switch data->Schema.parseWith(playerSchema) {
    | Ok(player) =>
      switch Schema.serializeWith(
        {
          ...player,
          dartsGames: player.dartsGames + 1,
          dartsWins: isWin ? player.dartsWins + 1 : player.dartsWins,
          dartsLosses: isLoss ? player.dartsLosses + 1 : player.dartsLosses,
          dartsLastGames: getLastGames(player.dartsLastGames, isWin),
          dartsElo: elo,
          dartsLastEloChange: elo -. player.dartsElo,
        },
        playerSchema,
      ) {
      | Ok(res) => res
      | _ => data
      }
    | Error(_) => data
    }
  })
}

let removePlayer = playerKey => {
  let playerRef = Firebase.Database.refPath(Database.database, bucket ++ "/" ++ playerKey)
  Firebase.Database.remove(playerRef)
}
