type team = array<Players.player>

let calculateScore: (
  team,
  team,
  ~getEloFn: Players.player => float=?,
) => (array<Players.player>, array<Players.player>, float)

let roundScore: float => int
