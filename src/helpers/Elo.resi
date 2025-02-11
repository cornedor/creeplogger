type team = array<Players.player>

let calculateScore: (
  team,
  team,
  ~gameMode: Games.gameMode,
) => (array<Players.player>, array<Players.player>, float)

let roundScore: float => int
