type team = array<Players.player>

let kFactor = 32.0

let getTotalEloFromTeam = (team: team) =>
  Array.reduce(team, 0.0, (acc, creeper) => acc +. creeper.elo)

@inline
let getCombinedTeamScores = (teamA: team, teamB: team) => {
  let totalEloA = getTotalEloFromTeam(teamA)
  let totalEloB = getTotalEloFromTeam(teamB)

  let countA = Array.length(teamA)
  let countB = Array.length(teamB)
  let max = max(countA, countB)
  // let min = min(countA, countB)

  let mulA = countA == max ? max->Int.toFloat : 1.5
  let mulB = countB == max ? max->Int.toFloat : 1.5

  // Avg using the opposite team amount of players. For example:
  // Team 1: [1200] = 1200 / 2 = 600
  // Team 2: [850, 700] = (850 + 700) / 1 = 775

  let avgA = totalEloA /. mulA
  let avgB = totalEloB /. mulB

  (avgA, avgB)
}

@inline
let getExpected = (scoreA, scoreB) =>
  1.0 /. (1.0 +. Math.pow(10.0, ~exp=(scoreB -. scoreA) /. 400.0))

@inline
let getRatingChange = (expected, actual) => kFactor *. (actual -. expected)

let calculateScore = (winners: team, losers: team) => {
  let (winnersScore, losersScore) = getCombinedTeamScores(winners, losers)

  let expectedScoreWinners = getExpected(winnersScore, losersScore)
  let expectedScoreLosers = getExpected(losersScore, winnersScore)

  let winners = Array.map(winners, creeper => {
    let change = getRatingChange(expectedScoreWinners, 1.0)
    let elo = creeper.elo +. change
    {
      ...creeper,
      elo,
      lastEloChange: change,
    }
  })
  let losers = Array.map(losers, creeper => {
    let change = getRatingChange(expectedScoreLosers, 0.0)
    let elo = creeper.elo +. change
    {
      ...creeper,
      elo,
      lastEloChange: change,
    }
  })

  (winners, losers, getRatingChange(expectedScoreWinners, 1.0))
}

let roundScore = score => Math.round(score)->Float.toInt
