type team = array<Players.player>

@inline
let kFactor = 32.0

@inline
let getTotalEloFromTeam = (team: team, ~getEloFn) =>
  Array.reduce(team, 0.0, (acc, creeper) => acc +. getEloFn(creeper))

@inline
let getCombinedTeamScores = (teamA: team, teamB: team, ~getEloFn) => {
  let totalEloA = getTotalEloFromTeam(teamA, ~getEloFn)
  let totalEloB = getTotalEloFromTeam(teamB, ~getEloFn)

  let countA = Array.length(teamA)
  let countB = Array.length(teamB)
  let max = max(countA, countB)
  // let min = min(countA, countB)

  let mulA = countA == max ? max->Int.toFloat : 1.5
  let mulB = countB == max ? max->Int.toFloat : 1.5

  // Avg using the opposite team amount of players. For example:
  // Team 1: [1200] = 1200 / 2 = 600
  // Team 2: [850, 700] = (850 + 700) / 2 = 775

  let avgA = totalEloA /. mulA
  let avgB = totalEloB /. mulB

  (avgA, avgB)
}

@inline
let getExpected = (scoreA, scoreB) =>
  1.0 /. (1.0 +. Math.pow(10.0, ~exp=(scoreB -. scoreA) /. 400.0))

@inline
let getRatingChange = (expected, actual) => kFactor *. (actual -. expected)

@inline
let getEloFn = (gameMode: Games.gameMode, player: Players.player) =>
  gameMode == Games.Darts ? player.dartsElo : player.elo

@inline
let setEloFn = (gameMode: Games.gameMode, player: Players.player, elo, change) =>
  gameMode == Games.Darts
    ? {
        ...player,
        dartsElo: elo,
        dartsLastEloChange: change,
      }
    : {
        ...player,
        elo,
        lastEloChange: change,
      }

let calculateScore = (winners: team, losers: team, ~gameMode: Games.gameMode) => {
  let (winnersScore, losersScore) = getCombinedTeamScores(
    winners,
    losers,
    ~getEloFn=getEloFn(gameMode, ...)
  )

  let expectedScoreWinners = getExpected(winnersScore, losersScore)
  let expectedScoreLosers = getExpected(losersScore, winnersScore)

  let winners = Array.map(winners, creeper => {
    let change = getRatingChange(expectedScoreWinners, 1.0)
    let elo = getEloFn(gameMode, creeper) +. change
    setEloFn(gameMode, creeper, elo, change)
  })
  let losers = Array.map(losers, creeper => {
    let change = getRatingChange(expectedScoreLosers, 0.0)
    let elo = getEloFn(gameMode, creeper) +. change
    setEloFn(gameMode, creeper, elo, change)
  })

  (winners, losers, getRatingChange(expectedScoreWinners, 1.0))
}

let roundScore = score => Math.round(score)->Float.toInt
