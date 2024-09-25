open Firebase

type modifier = Handicap(int, int) | OneVOne

type peroid = Daily | Weekly | Monthly | All

type game = {
  blueScore: int,
  redScore: int,
  blueTeam: array<string>,
  redTeam: array<string>,
  game: string,
  date: Date.t,
  modifiers: option<array<modifier>>,
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
  blueScore: s.field("blueScore", Schema.int->Schema.Int.min(0)),
  redScore: s.field("redScore", Schema.int->Schema.Int.min(0)),
  redTeam: s.field("redTeam", Schema.array(Schema.string)),
  blueTeam: s.field("blueTeam", Schema.array(Schema.string)),
  game: s.field("game", Schema.string),
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

  let games =
    await Firebase.Database.query2(
      Firebase.Database.refPath(Database.database, "games"),
      Firebase.Database.orderByChild("date"),
      Firebase.Database.startAt(Date.getTime(date)),
    )->Firebase.Database.get

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
