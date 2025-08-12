type dailyLine = {
  name: string,
  creeps: int,
  games: int,
  score: int,
}

let getDailyOverviewWith: (
  Games.peroid,
  ~getTimePeriod: Games.peroid => promise<Js.Dict.t<Games.game>>,
  ~fetchAllPlayers: unit => promise<Js.Dict.t<Players.player>>,
) => promise<RescriptCore.Map.t<string, dailyLine>>

let getDailyOverview: Games.peroid => promise<RescriptCore.Map.t<string, dailyLine>>

let toAPIObject: RescriptCore.Map.t<string, dailyLine> => Js.Dict.t<dailyLine>
