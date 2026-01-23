type modifier = Handicap(int, int) | OneVOne

type period = Daily | Weekly | Monthly | All

type gameMode = Foosball | Darts | Fifa

type game = {
  blueScore: int,
  redScore: int,
  blueTeam: array<string>,
  redTeam: array<string>,
  date: Date.t,
  modifiers: option<array<modifier>>,
  scoreDeltas: option<Js.Dict.t<int>>,
}

let addGame: game => promise<Firebase.databaseReference>

let getTimePeriod: period => promise<Js.Dict.t<game>>

let fetchAllGames: unit => promise<array<game>>

let removeGame: string => promise<unit>

let useLastGames: unit => Js.Dict.t<game>
