open Firebase

type modifier = Handicap(int, int) | OneVOne

type peroid = Daily | Weekly | Monthly | All

type gameMode = Foosball | Darts | Fifa

type game = {
  blueScore: int,
  redScore: int,
  blueTeam: array<string>,
  redTeam: array<string>,
  date: Date.t,
  modifiers: option<array<modifier>>,
  scoreDeltas: option<Js.Dict.t<int>>, // Store the score changes per player
}

let modifierSchema = Schema.union([
  Schema.object(s => {
    s.tag("kind", "handicap")
    Handicap(s.field("blue", Schema.int), s.field("red", Schema.int))
  }),
  Schema.object(s => {
    s.tag("kind", "one-v-one")
    OneVOne
  }),
])

let gameSchema = Schema.object(s => {
  blueScore: s.field("blueScore", Schema.int->Schema.intMin(0)),
  redScore: s.field("redScore", Schema.int->Schema.intMin(0)),
  redTeam: s.field("redTeam", Schema.array(Schema.string)),
  blueTeam: s.field("blueTeam", Schema.array(Schema.string)),
  date: s.field(
    "date",
    Schema.float->Schema.transform(_ => {
      parser: Date.fromTime,
      serializer: Date.getTime,
    }),
  ),
  modifiers: s.field(
    "modifiers",
    Schema.option(Schema.array(modifierSchema))->FirebaseSchema.nullableTransform,
  ),
  scoreDeltas: s.field(
    "scoreDeltas",
    Schema.option(Schema.dict(Schema.int))->FirebaseSchema.nullableTransform,
  ),
})

let addGame = game => {
  let gamesRef = Firebase.Database.refPath(Database.database, "games")

  switch Schema.serializeWith(game, gameSchema) {
  | Ok(data) => Firebase.Database.pushValue(gamesRef, data)
  | Error(_) => panic("Could not create game")
  }
}

let getTimePeriod = async period => {
  let date = Date.make()
  Date.setHoursMSMs(date, ~hours=0, ~minutes=0, ~seconds=0, ~milliseconds=0)

  let endDate = switch period {
  | Daily => {
      let end = Date.make()
      Date.setHoursMSMs(end, ~hours=23, ~minutes=59, ~seconds=59, ~milliseconds=999)
      Some(end)
    }
  | Weekly => {
      let x = Date.getDay(date)
      let newDate = Date.getDate(date) - (x == 0 ? 7 : x) + 1
      Date.setDate(date, newDate)
      let end = Date.make()
      Date.setDate(end, Date.getDate(date) + 6)
      Date.setHoursMSMs(end, ~hours=23, ~minutes=59, ~seconds=59, ~milliseconds=999)
      Some(end)
    }
  | Monthly => {
      Date.setDate(date, 0)
      let end = Date.make()
      Date.setDate(end, 0)
      Date.setDate(end, Date.getDate(end) - 1)
      Date.setHoursMSMs(end, ~hours=23, ~minutes=59, ~seconds=59, ~milliseconds=999)
      Some(end)
    }
  | All => None
  }

  switch period {
  | Daily => ()
  | Weekly => {
      let x = Date.getDay(date)
      let newDate = Date.getDate(date) - (x == 0 ? 7 : x) + 1
      Date.setDate(date, newDate)
    }

  | Monthly => Date.setDate(date, 0)
  | All => Date.setFullYear(date, 2000)
  }

  let games = switch endDate {
  | Some(end) =>
    await Firebase.Database.query3(
      Firebase.Database.refPath(Database.database, "games"),
      Firebase.Database.orderByChild("date"),
      Firebase.Database.startAt(Date.getTime(date)),
      Firebase.Database.endAt(Date.getTime(end)),
    )->Firebase.Database.get
  | None =>
    await Firebase.Database.query2(
      Firebase.Database.refPath(Database.database, "games"),
      Firebase.Database.orderByChild("date"),
      Firebase.Database.startAt(Date.getTime(date)),
    )->Firebase.Database.get
  }

  switch games->Firebase.Database.Snapshot.val->Nullable.toOption {
  | Some(val) =>
    switch val->Schema.parseWith(Schema.dict(gameSchema)) {
    | Ok(val) => val
    | Error(e) => {
        Js.log(e)
        Js.Dict.empty()
      }
    }
  | None => Js.Dict.empty()
  }
}

let empty: Js.Dict.t<game> = Js.Dict.empty()
let useLastGames = () => {
  let (games, setGames) = React.useState(_ => empty)
  let gamesRef = Firebase.Database.query1(
    Firebase.Database.refPath(Database.database, "games"),
    Firebase.Database.orderByChild("date"),
  )
  React.useEffect(() => {
    let unsubscribe = Firebase.Database.onValue(
      gamesRef,
      snapshot => {
        let games = switch Firebase.Database.Snapshot.val(snapshot)->Nullable.toOption {
        | Some(val) =>
          switch val->Schema.parseWith(Schema.dict(gameSchema)) {
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

external snapshotToArray: dataSnapshot => array<dataSnapshot> = "%identity"

let fetchAllGames = async () => {
  let games =
    await Firebase.Database.query1(
      Firebase.Database.refPath(Database.database, "games"),
      Firebase.Database.orderByChild("date"),
    )->Firebase.Database.get

  let orderedGames = []
  Array.forEach(snapshotToArray(games), snap => {
    switch snap->Firebase.Database.Snapshot.val->Nullable.toOption {
    | Some(val) =>
      switch val->Schema.parseWith(gameSchema) {
      | Ok(val) => orderedGames->Array.push(val)
      | Error(e) => Js.log(e)
      }
    | None => ()
    }
  })

  orderedGames
}

let removeGame = gameKey => {
  let gameRef = Firebase.Database.refPath(Database.database, "games/" ++ gameKey)
  Firebase.Database.remove(gameRef)
}
