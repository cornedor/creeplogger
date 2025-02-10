open Firebase

type dartsMode =
  | AroundTheClock
  | Bullen
  | Killer
  | M501
  | M301

type dartsGame = {
  winners: array<string>,
  losers: array<string>,
  date: Date.t,
  mode: dartsMode,
}

let dartsModeSchema = Schema.union([
  Schema.object(s => {
    s.tag("kind", "r")
    AroundTheClock
  }),
  Schema.object(s => {
    s.tag("kind", "b")
    Bullen
  }),
  Schema.object(s => {
    s.tag("kind", "k")
    Killer
  }),
  Schema.object(s => {
    s.tag("kind", "5")
    M501
  }),
  Schema.object(s => {
    s.tag("kind", "3")
    M301
  }),
])

let dartsModeToString = dartsMode => {
  switch dartsMode {
  | AroundTheClock => "Around the Cock"
  | Bullen => "Bullen"
  | Killer => "Killer"
  | M501 => "501"
  | M301 => "301"
  }
}

let dartsGameSchema = Schema.object(s => {
  winners: s.field("w", Schema.array(Schema.string)),
  losers: s.field("l", Schema.array(Schema.string)),
  date: s.field(
    "d",
    Schema.float->Schema.transform(_ => {
      parser: Date.fromTime,
      serializer: Date.getTime,
    }),
  ),
  mode: s.field("m", dartsModeSchema),
})

let addDartsGame = dartsGame => {
  let dartsGamesRef = Firebase.Database.refPath(Database.database, "dartsGames")

  switch Schema.serializeWith(dartsGame, dartsGameSchema) {
  | Ok(data) => Firebase.Database.pushValue(dartsGamesRef, data)
  | Error(_) => panic("Could not create darts game")
  }
}

external snapshotToArray: dataSnapshot => array<dataSnapshot> = "%identity"

let fetchAllGames = async () => {
  let games =
    await Firebase.Database.query1(
      Firebase.Database.refPath(Database.database, "dartsGames"),
      Firebase.Database.orderByChild("date"),
    )->Firebase.Database.get

  let orderedGames = []
  Array.forEach(snapshotToArray(games), snap => {
    switch snap->Firebase.Database.Snapshot.val->Nullable.toOption {
    | Some(val) =>
      switch val->Schema.parseWith(dartsGameSchema) {
      | Ok(val) => orderedGames->Array.push(val)
      | Error(e) => Js.log(e)
      }
    | None => ()
    }
  })

  orderedGames
}

let removeGame = gameKey => {
  let gameRef = Firebase.Database.refPath(Database.database, "dartsGames/" ++ gameKey)
  Firebase.Database.remove(gameRef)
}

let empty: Js.Dict.t<dartsGame> = Js.Dict.empty()
let useLastGames = () => {
  let (games, setGames) = React.useState(_ => empty)
  let gamesRef = Firebase.Database.query1(
    Firebase.Database.refPath(Database.database, "dartsGames"),
    Firebase.Database.orderByChild("date"),
  )
  React.useEffect(() => {
    let unsubscribe = Firebase.Database.onValue(
      gamesRef,
      snapshot => {
        let games = switch Firebase.Database.Snapshot.val(snapshot)->Nullable.toOption {
        | Some(val) =>
          switch val->Schema.parseWith(Schema.dict(dartsGameSchema)) {
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
