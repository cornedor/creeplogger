open Firebase
open RescriptSchema

type modifier = Handicap(int, int) | OneVOne

type game = {
  blueScore: int,
  redScore: int,
  blueTeam: array<string>,
  redTeam: array<string>,
  date: Date.t,
  modifiers: array<modifier>,
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
  modifiers: s.field("modifiers", S.array(modifierSchema)),
})

let addGame = async game => {
  let gamesRef = Firebase.Database.refPath(Database.database, "games")

  switch S.serializeWith(game, gameSchema) {
  | Ok(data) => Firebase.Database.pushValue(gamesRef, data)
  | Error(_) => panic("Could not create game")
  }
}
