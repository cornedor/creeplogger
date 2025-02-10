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

let addDartsGame: dartsGame => promise<Firebase.databaseReference>

let dartsModeToString: dartsMode => string

let fetchAllGames: unit => promise<array<dartsGame>>

let removeGame: string => promise<unit>

let useLastGames: unit => Js.Dict.t<dartsGame>
