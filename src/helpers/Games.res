open Firebase
open RescriptSchema

type modifier = Handicap(int, int) | OneVOne

type peroid = Daily | Weekly | Monthly

type game = {
  blueScore: int,
  redScore: int,
  blueTeam: array<string>,
  redTeam: array<string>,
  date: Date.t,
  modifiers: option<array<modifier>>,
}

let modifierSchema = S.union([
  S.object(s => {
    s.tag("kind", "handicap")
    Handicap(s.field("blue", S.int), s.field("red", S.int))
  }),
  S.object(s => {
    s.tag("kind", "one-v-one")
    OneVOne
  }),
])

let gameSchema = S.object(s => {
  blueScore: s.field("blueScore", S.int->S.Int.min(0)),
  redScore: s.field("redScore", S.int->S.Int.min(0)),
  redTeam: s.field("redTeam", S.array(S.string)),
  blueTeam: s.field("blueTeam", S.array(S.string)),
  date: s.field(
    "date",
    S.float->S.transform(_ => {
      parser: Date.fromTime,
      serializer: Date.getTime,
    }),
  ),
  modifiers: s.field(
    "modifiers",
    S.option(S.array(modifierSchema))->FirebaseSchema.nullableTransform,
  ),
})

let addGame = game => {
  let gamesRef = Firebase.Database.refPath(Database.database, "games")

  switch S.serializeWith(game, gameSchema) {
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
  }

  let games =
    await Firebase.Database.query2(
      Firebase.Database.refPath(Database.database, "games"),
      Firebase.Database.orderByChild("date"),
      Firebase.Database.startAt(Date.getTime(date)),
    )->Firebase.Database.get

  switch games->Firebase.Database.Snapshot.val->Nullable.toOption {
  | Some(val) =>
    switch val->S.parseWith(S.dict(gameSchema)) {
    | Ok(val) => val
    | Error(e) => {
        Js.log(e)
        Js.Dict.empty()
      }
    }
  | None => Js.Dict.empty()
  }
}
