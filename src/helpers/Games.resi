type modifier = Handicap(int, int) | OneVOne

type peroid = Daily | Weekly | Monthly | All

type game = {
  blueScore: int,
  redScore: int,
  blueTeam: array<string>,
  redTeam: array<string>,
  date: Date.t,
  modifiers: option<array<modifier>>,
}

let addGame: game => promise<Firebase.databaseReference>

let getTimePeriod: peroid => promise<Js.Dict.t<game>>

let fetchAllGames: unit => promise<array<game>>

let removeGame: string => promise<unit>

let useLastGames: unit => Js.Dict.t<game>
