open Vitest

let makePlayer = (~elo=1000.0, ~dartsElo=1000.0, ()): Players.player => {
  name: "p",
  wins: 0,
  losses: 0,
  absoluteWins: 0,
  absoluteLosses: 0,
  games: 0,
  teamGoals: 0,
  teamGoalsAgainst: 0,
  blueGames: 0,
  redGames: 0,
  blueWins: 0,
  redWins: 0,
  elo,
  lastEloChange: 0.0,
  key: "k",
  mattermostHandle: None,
  lastGames: [],
  hidden: None,
  mu: 25.0,
  sigma: 8.333,
  ordinal: 0.0,
  lastOpenSkillChange: 0.0,
  dartsElo,
  dartsLastEloChange: 0.0,
  dartsGames: 0,
  dartsWins: 0,
  dartsLosses: 0,
  dartsLastGames: [],
}

describe("Elo.calculateScore", () => {
  test("increases winners elo and decreases losers elo (Foosball)", () => {
    let winners = [makePlayer(~elo=1100.0, ()), makePlayer(~elo=1050.0, ())]
    let losers = [makePlayer(~elo=1000.0, ()), makePlayer(~elo=950.0, ())]

    let (newWinners, newLosers, delta) = Elo.calculateScore(winners, losers, ~gameMode=Games.Foosball)

    expectFloatGreater(Array.getUnsafe(newWinners, 0).elo, 1100.0)
    expectFloatGreater(Array.getUnsafe(newWinners, 1).elo, 1050.0)
    expectFloatLess(Array.getUnsafe(newLosers, 0).elo, 1000.0)
    expectFloatLess(Array.getUnsafe(newLosers, 1).elo, 950.0)
    expectFloatGreater(delta, 0.0)
  })

  test("uses dartsElo when gameMode is Darts", () => {
    let winners = [makePlayer(~dartsElo=1200.0, ())]
    let losers = [makePlayer(~dartsElo=1000.0, ())]

    let (newWinners, newLosers, delta) = Elo.calculateScore(winners, losers, ~gameMode=Games.Darts)

    expectFloatGreater(Array.getUnsafe(newWinners, 0).dartsElo, 1200.0)
    expectFloatLess(Array.getUnsafe(newLosers, 0).dartsElo, 1000.0)
    expectFloatGreater(delta, 0.0)
  })

  test("roundScore rounds to nearest int", () => {
    expectIntEqual(Elo.roundScore(1.2), 1)
    expectIntEqual(Elo.roundScore(1.5), 2)
  })
})