type team = array<Players.player>

let kFactor = 32.0

let getTotalEloFromTeam = (team: team) =>
  Array.reduce(team, 0.0, (acc, creeper) => acc +. creeper.elo)

let getCombinedTeamScores = (teamA: team, teamB: team) => {
  let totalEloA = getTotalEloFromTeam(teamA)
  let totalEloB = getTotalEloFromTeam(teamB)

  // Avg using the opposite team amount of players. For example:
  // Team 1: [1200] = 1200 / 2 = 600
  // Team 2: [850, 700] = (850 + 700) / 2 = 775
  let avgA = totalEloA /. Array.length(teamB)->Int.toFloat
  let avgB = totalEloB /. Array.length(teamA)->Int.toFloat

  (avgA, avgB)
}

let getExpected = (scoreA, scoreB) =>
  1.0 /. (1.0 +. Math.pow(10.0, ~exp=(scoreB -. scoreA) /. 400.0))

let getRatingChange = (expected, actual) => kFactor *. (actual -. expected)

let calculateScore = (winners: team, losers: team) => {
  let (winnersScore, losersScore) = getCombinedTeamScores(winners, losers)

  let expectedScoreWinners = getExpected(winnersScore, losersScore)
  let expectedScoreLosers = getExpected(losersScore, winnersScore)

  let winners = Array.map(winners, creeper => {
    let elo = creeper.elo +. getRatingChange(expectedScoreWinners, 1.0)
    {
      ...creeper,
      elo,
    }
  })
  let losers = Array.map(losers, creeper => {
    let elo = creeper.elo +. getRatingChange(expectedScoreLosers, 0.0)
    {
      ...creeper,
      elo,
    }
  })

  (winners, losers, getRatingChange(expectedScoreWinners, 1.0))
}
