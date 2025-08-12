open Vitest

let makePlayer = (~mu=25.0, ~sigma=8.333, ()): Players.player => {
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
  elo: 1000.0,
  lastEloChange: 0.0,
  key: "k",
  mattermostHandle: None,
  lastGames: [],
  hidden: None,
  mu,
  sigma,
  ordinal: 0.0,
  lastOpenSkillChange: 0.0,
  dartsElo: 1000.0,
  dartsLastEloChange: 0.0,
  dartsGames: 0,
  dartsWins: 0,
  dartsLosses: 0,
  dartsLastGames: [],
}

describe("OpenSkillRating", () => {
  test("calculateScore updates mu/sigma and returns average delta", () => {
    let winners = [makePlayer(~mu=27.0, ~sigma=8.0, ())]
    let losers = [makePlayer(~mu=23.0, ~sigma=9.0, ())]

    let fakeRateGame = (_winners, _losers) => ([OpenSkill.createRating(~mu=28.0, ~sigma=7.9, ())], [OpenSkill.createRating(~mu=22.0, ~sigma=9.1, ())])

    let (updatedWinners, updatedLosers, avgDelta) =
      OpenSkillRating.calculateScore(winners, losers, ~gameMode=Games.Foosball, ~rateGame=fakeRateGame)

    let uw = Array.getUnsafe(updatedWinners, 0)
    let ul = Array.getUnsafe(updatedLosers, 0)

    expectFloatCloseTo(uw.mu, 28.0)
    expectFloatCloseTo(uw.sigma, 7.9)
    expectFloatCloseTo(ul.mu, 22.0)
    expectFloatCloseTo(ul.sigma, 9.1)

    let newOrdinal = 28.0 -. 3.0 *. 7.9
    expectFloatCloseTo(avgDelta, newOrdinal)
    expectFloatCloseTo(uw.lastOpenSkillChange, newOrdinal)
  })

  test("toDisplayDelta and toDisplayOrdinal scale values by 60 and round", () => {
    expectIntEqual(OpenSkillRating.toDisplayDelta(1.2), 72)
    expectIntEqual(OpenSkillRating.toDisplayDelta(1.5), 90)
    expectIntEqual(OpenSkillRating.toDisplayOrdinal(2.0), 120)
  })

  test("roundScore rounds to nearest int", () => {
    expectIntEqual(OpenSkillRating.roundScore(2.2), 2)
    expectIntEqual(OpenSkillRating.roundScore(2.5), 3)
  })
})