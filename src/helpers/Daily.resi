open RescriptCore

type dailyLine = {
  name: string,
  creeps: int,
  games: int,
}

let getDailyOverview: Games.peroid => promise<RescriptCore.Map.t<string, dailyLine>>
