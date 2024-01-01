open Firebase
open RescriptSchema

type player = {
  name: string,
  wins: int,
  losses: int,
  absoluteWins: int,
  absoluteLosses: int,
  games: int,
  blueGames: int,
  redGames: int,
  blueWins: int,
  redWins: int,
  elo: int,
  key: string,
  mattermostHandle: option<string>,
}

type team = Blue | Red

let bucket = "players"

let playerSchema = S.object(s => {
  name: s.field("name", S.string),
  wins: s.fieldOr("wins", S.int, 0),
  losses: s.fieldOr("losses", S.int, 0),
  absoluteWins: s.fieldOr("absoluteWins", S.int, 0),
  absoluteLosses: s.fieldOr("absoluteLosses", S.int, 0),
  games: s.fieldOr("games", S.int, 0),
  redGames: s.fieldOr("redGames", S.int, 0),
  blueGames: s.fieldOr("blueGames", S.int, 0),
  redWins: s.fieldOr("redWins", S.int, 0),
  blueWins: s.fieldOr("blueWins", S.int, 0),
  elo: s.fieldOr("elo", S.int, 1000),
  key: s.field("key", S.string),
  mattermostHandle: s.field(
    "mh",
    S.option(S.string)->S.transform(_ => {
      parser: value => value,
      serializer: value =>
        switch value {
        | None => %raw(`null`)
        | Some(value) => Some(value)
        },
    }),
  ),
})

let playersSchema = S.dict(playerSchema)

let addPlayer = async name => {
  let playersRef = Firebase.Database.refPath(Database.database, bucket)
  let data = switch {
    name,
    wins: 0,
    losses: 0,
    absoluteWins: 0,
    absoluteLosses: 0,
    games: 0,
    redGames: 0,
    blueGames: 0,
    redWins: 0,
    blueWins: 0,
    elo: 1000,
    key: "",
    mattermostHandle: None,
  }->S.serializeWith(playerSchema) {
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

let useAllPlayers = () => {
  let (players, setPlayers) = React.useState(_ => [])
  let playersRef = Firebase.Database.query1(
    Firebase.Database.refPath(Database.database, bucket),
    Firebase.Database.orderByChild("games"),
  )

  React.useEffect(() => {
    let unsubscribe = Firebase.Database.onValue(
      playersRef,
      snapshot => {
        let data = Firebase.Database.Snapshot.val(snapshot)
        switch data->Js.toOption {
        | Some(data) =>
          switch data->S.parseWith(playersSchema) {
          | Ok(players) => setPlayers(_ => Dict.valuesToArray(players))
          | Error(e) => {
              Console.error(e)
              setPlayers(_ => [])
            }
          }
        | None => setPlayers(_ => [])
        }
      },
      (),
    )

    Some(unsubscribe)
  }, [])

  players
}

let fetchPlayerByKey = async key => {
  let playerRef = Firebase.Database.refPath(Database.database, bucket ++ "/" ++ key)
  let data = await Firebase.Database.get(playerRef)
  switch Firebase.Database.Snapshot.val(data)->Js.toOption {
  | Some(player) =>
    switch player->S.parseWith(playerSchema) {
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

type winResult = Win | Lose | AbsoluteWin | AbsoluteLose
let updateGameStats = (key, pointsA, pointsB, team: team, elo) => {
  let isAbsolute = abs(pointsA - pointsB) == 7

  let isWin = pointsA > pointsB
  let isAbsoluteWin = isAbsolute && isWin
  let isLoss = pointsA < pointsB
  let isAbsoluteLoss = isAbsolute && isLoss
  let isRedWin = team == Red && isWin
  let isBlueWin = team == Blue && isWin

  let playerRef = Firebase.Database.refPath(Database.database, bucket ++ "/" ++ key)
  Firebase.Database.runTransaction(playerRef, data => {
    switch data->S.parseWith(playerSchema) {
    | Ok(player) =>
      switch S.serializeWith(
        {
          ...player,
          games: player.games + 1,
          redGames: team == Red ? player.redGames + 1 : player.redGames,
          blueGames: team == Blue ? player.blueGames + 1 : player.blueGames,
          wins: isWin ? player.wins + 1 : player.wins,
          losses: isLoss ? player.losses + 1 : player.losses,
          absoluteLosses: isAbsoluteLoss ? player.absoluteLosses + 1 : player.absoluteLosses,
          absoluteWins: isAbsoluteWin ? player.absoluteWins + 1 : player.absoluteWins,
          redWins: isRedWin ? player.redWins + 1 : player.redWins,
          blueWins: isBlueWin ? player.blueWins + 1 : player.blueWins,
          elo,
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
