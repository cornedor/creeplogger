type fifaGame = {
  blueScore: int,
  redScore: int,
  blueTeam: array<string>,
  redTeam: array<string>,
  date: Date.t,
}

let addFifaGame: fifaGame => promise<Firebase.databaseReference>

let fetchAllGames: unit => promise<array<fifaGame>>

let removeGame: string => promise<unit>

let useLastGames: unit => Js.Dict.t<fifaGame>
