open Firebase

type playerScore = {
  playerKey: string,
  score: int,
}

type fifaGame = {
  playerScores: array<playerScore>,
  date: Date.t,
}

let playerScoreSchema = Schema.object(s => {
  playerKey: s.field("p", Schema.string),
  score: s.field("s", Schema.int),
})

let fifaGameSchema = Schema.object(s => {
  playerScores: s.field("ps", Schema.array(playerScoreSchema)),
  date: s.field(
    "d",
    Schema.float->Schema.transform(_ => {
      parser: Date.fromTime,
      serializer: Date.getTime,
    }),
  ),
})

let addFifaGame = fifaGame => {
  let fifaGamesRef = Firebase.Database.refPath(Database.database, "fifaGames")

  switch Schema.serializeWith(fifaGame, fifaGameSchema) {
  | Ok(data) => Firebase.Database.pushValue(fifaGamesRef, data)
  | Error(_) => panic("Could not create FIFA game")
  }
}

external snapshotToArray: dataSnapshot => array<dataSnapshot> = "%identity"

let fetchAllGames = async () => {
  let games =
    await Firebase.Database.query1(
      Firebase.Database.refPath(Database.database, "fifaGames"),
      Firebase.Database.orderByChild("date"),
    )->Firebase.Database.get

  let orderedGames = []
  Array.forEach(snapshotToArray(games), snap => {
    switch snap->Firebase.Database.Snapshot.val->Nullable.toOption {
    | Some(val) =>
      switch val->Schema.parseWith(fifaGameSchema) {
      | Ok(val) => orderedGames->Array.push(val)
      | Error(e) => Js.log(e)
      }
    | None => ()
    }
  })

  orderedGames
}

let removeGame = gameKey => {
  let gameRef = Firebase.Database.refPath(Database.database, "fifaGames/" ++ gameKey)
  Firebase.Database.remove(gameRef)
}

let empty: Js.Dict.t<fifaGame> = Js.Dict.empty()
let useLastGames = () => {
  let (games, setGames) = React.useState(_ => empty)
  let gamesRef = Firebase.Database.query1(
    Firebase.Database.refPath(Database.database, "fifaGames"),
    Firebase.Database.orderByChild("date"),
  )
  React.useEffect(() => {
    let unsubscribe = Firebase.Database.onValue(
      gamesRef,
      snapshot => {
        let games = switch Firebase.Database.Snapshot.val(snapshot)->Nullable.toOption {
        | Some(val) =>
          switch val->Schema.parseWith(Schema.dict(fifaGameSchema)) {
          | Ok(val) => val
          | Error(e) => {
              Js.log(e)
              Js.Dict.empty()
            }
          }
        | None => empty
        }
        setGames(_ => games)
      },
      (),
    )

    Some(unsubscribe)
  }, [setGames])

  games
}
