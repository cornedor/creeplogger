type modifier = Handicap(int, int) | OneVOne

type peroid = Daily | Weekly | Monthly

type game = {
  blueScore: int,
  redScore: int,
  blueTeam: array<string>,
  redTeam: array<string>,
  date: Date.t,
  modifiers: string,
}

let addGame: game => Js.Promise.t<Firebase.databaseReference>

let getTimePeriod: peroid => promise<Dict.t<game>>
