let sendCreepsUpdate: (array<Players.player>, array<Players.player>, int, int, int) => promise<int>

let sendDartsUpdate: (array<Players.player>, array<Players.player>, int, string) => promise<int>

let sendFifaUpdate: (array<Players.player>, array<Players.player>, int, int) => promise<int>

let publishMessage: string => option<promise<Fetch.Response.t>>

let sendDailyUpdate: unit => promise<bool>

let sendDaysWithoutReset: string => promise<int>
