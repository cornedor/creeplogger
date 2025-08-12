import { describe, it, expect } from 'vitest'
import { calculateScore, roundScore } from '../src/helpers/Elo.bs.mjs'

// Minimal player shape based on compiled output usage in Elo.bs.mjs
function makePlayer(overrides: Partial<any> = {}) {
  return {
    name: 'p',
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
    elo: 1000,
    lastEloChange: 0,
    key: 'k',
    mattermostHandle: null,
    lastGames: [],
    hidden: null,
    mu: 25,
    sigma: 8.333,
    ordinal: 0,
    lastOpenSkillChange: 0,
    dartsElo: 1000,
    dartsLastEloChange: 0,
    dartsGames: 0,
    dartsWins: 0,
    dartsLosses: 0,
    dartsLastGames: [],
    ...overrides,
  }
}

describe('Elo.calculateScore', () => {
  it('increases winners elo and decreases losers elo (Foosball)', () => {
    const winners = [makePlayer({ elo: 1100 }), makePlayer({ elo: 1050 })]
    const losers = [makePlayer({ elo: 1000 }), makePlayer({ elo: 950 })]

    const [newWinners, newLosers, delta] = calculateScore(winners, losers, 'Foosball')

    // Winners should gain, losers should lose
    expect(newWinners[0].elo).toBeGreaterThan(winners[0].elo)
    expect(newWinners[1].elo).toBeGreaterThan(winners[1].elo)
    expect(newLosers[0].elo).toBeLessThan(losers[0].elo)
    expect(newLosers[1].elo).toBeLessThan(losers[1].elo)

    // Delta should be positive for winners
    expect(delta).toBeGreaterThan(0)
  })

  it('uses dartsElo when gameMode is Darts', () => {
    const winners = [makePlayer({ dartsElo: 1200 })]
    const losers = [makePlayer({ dartsElo: 1000 })]

    const [newWinners, newLosers, delta] = calculateScore(winners, losers, 'Darts')

    expect(newWinners[0].dartsElo).toBeGreaterThan(1200)
    expect(newLosers[0].dartsElo).toBeLessThan(1000)
    expect(delta).toBeGreaterThan(0)
  })

  it('roundScore rounds to nearest int', () => {
    expect(roundScore(1.2)).toBe(1)
    expect(roundScore(1.5)).toBe(2)
  })
})