type team = Blue | Red

type player = {
  name: string,
  wins: int,
  losses: int,
  absoluteWins: int,
  absoluteLosses: int,
  games: int,
  teamGoals: int,
  teamGoalsAgainst: int,
  blueGames: int,
  redGames: int,
  blueWins: int,
  redWins: int,
  elo: float,
  lastEloChange: float,
  key: string,
  mattermostHandle: option<string>,
  lastGames: array<int>,
  hidden: option<bool>,
  dartsElo: float,
  dartsLastEloChange: float,
  dartsGames: int,
  dartsWins: int,
  dartsLosses: int,
  dartsLastGames: array<int>,
}

type playersOrder = [#games | #elo | #dartsElo]

@inline
let bucket: string

let addPlayer: string => promise<Firebase.databaseReference>

let useAllPlayers: (~orderBy: playersOrder=?, ~asc: bool=?) => array<player>

let fetchAllPlayers: unit => promise<Js.Dict.t<player>>
let fetchPlayerByKey: string => promise<option<player>>

let playerByKey: (array<player>, string) => option<player>

let updateGameStats: (string, int, int, team, float) => Js.Json.t => Js.Json.t

let updateDartsGameStats: (string, int, float) => Js.Json.t => Js.Json.t

let writePlayer: player => promise<unit>

let getLastGames: (array<int>, bool) => array<int>

let playersSchema: Schema.t<Js.Dict.t<player>>

let removePlayer: string => promise<unit>
