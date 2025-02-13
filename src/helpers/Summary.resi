type dailyLine = {
  name: string,
  creeps: int,
  games: int,
  score: int,
}

let getDailyOverview: Games.peroid => promise<RescriptCore.Map.t<string, dailyLine>>

let toAPIObject: RescriptCore.Map.t<string, dailyLine> => Js.Dict.t<dailyLine>
