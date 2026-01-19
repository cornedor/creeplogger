type playerScore = {
  playerKey: string,
  score: int,
}

type fifaGame = {
  playerScores: array<playerScore>,
  date: Date.t,
}

let addFifaGame: fifaGame => promise<Firebase.databaseReference>

let fetchAllGames: unit => promise<array<fifaGame>>

let removeGame: string => promise<unit>

let useLastGames: unit => Js.Dict.t<fifaGame>
