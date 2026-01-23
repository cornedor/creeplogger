type dailyLine = {
  name: string,
  creeps: int,
  games: int,
  score: int,
  goalDiff: int,
}

let getDailyOverview: Games.period => promise<RescriptCore.Map.t<string, dailyLine>>

let toAPIObject: RescriptCore.Map.t<string, dailyLine> => Js.Dict.t<dailyLine>
