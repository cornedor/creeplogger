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
  gameTypes: array<string>,
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
  teamGoalsAgainst: s.fieldOr("tga", Schema.int, 0),
  redGames: s.fieldOr("redGames", Schema.int, 0),
  blueGames: s.fieldOr("blueGames", Schema.int, 0),
  redWins: s.fieldOr("redWins", Schema.int, 0),
  blueWins: s.fieldOr("blueWins", Schema.int, 0),
  elo: s.fieldOr("elo", Schema.float, 1000.0),
  lastEloChange: s.fieldOr("change", Schema.float, 0.0),
  key: s.field("key", Schema.string),
  mattermostHandle: s.field("mh", Schema.option(Schema.string)->FirebaseSchema.nullableTransform),
  lastGames: s.fieldOr("lastGames", Schema.array(Schema.int), []),
  hidden: s.field("hidden", Schema.option(Schema.bool)->FirebaseSchema.nullableTransform),
  gameTypes: s.fieldOr("gameTypes", Schema.array(Schema.string), []),
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
    gameTypes: [],
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

type playersOrder = [#games | #elo]

// let sortPlayersBy(orderBy: playersOrder)

external snapshotToArray: dataSnapshot => array<dataSnapshot> = "%identity"

let useAllPlayers = (~orderBy: playersOrder=#games, ~asc=true) => {
  let (players, setPlayers) = React.useState(_ => [])
  let playersRef = Firebase.Database.query1(
    Firebase.Database.refPath(Database.database, bucket),
    Firebase.Database.orderByChild(orderBy),
  )

  let sortFunction = asc ? Array.toReversed : a => a

  React.useEffect(() => {
    let unsubscribe = Firebase.Database.onValue(
      playersRef,
      snapshot => {
        let newPlayers = []
        Array.forEach(snapshotToArray(snapshot), snap => {
          let data = Firebase.Database.Snapshot.val(snap)
          switch data->Js.toOption {
          | Some(data) =>
            switch data->Schema.parseWith(playerSchema) {
            | Ok(player) => Array.push(newPlayers, player)
            | Error(e) => Console.error(e)
            }
          | None => ()
          }
        })
        setPlayers(_ => newPlayers)
      },
      (),
    )

    Some(unsubscribe)
  }, [setPlayers])

  let players = React.useMemo(() => players->sortFunction, (players, asc))

  players
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
  Firebase.Database.set(playerRef, Schema.serializeOrRaiseWith(player, playerSchema))
}

let getLastGames = (lastGames, win) => {
  Array.push(lastGames, win ? 1 : 0)
  lastGames->Array.sliceToEnd(~start=-5)
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
          teamGoalsAgainst: player.teamGoals + opponentTeamPoints,
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
