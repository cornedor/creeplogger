import { describe, it, expect, vi, beforeEach } from 'vitest'
import * as OpenSkillModule from '../src/helpers/OpenSkill.bs.mjs'
import {
  calculateScore,
  toDisplayDelta,
  toDisplayOrdinal,
  getWinProbability,
  roundScore,
} from '../src/helpers/OpenSkillRating.bs.mjs'

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

beforeEach(() => {
  vi.restoreAllMocks()
})

describe('OpenSkillRating', () => {
  it('calculateScore updates mu/sigma and returns average delta', () => {
    const winners = [makePlayer({ mu: 27, sigma: 8 })]
    const losers = [makePlayer({ mu: 23, sigma: 9 })]

    // Mock underlying OpenSkill.rateGame to be deterministic
    vi.spyOn(OpenSkillModule, 'rateGame').mockReturnValue([
      // winner updates
      [{ mu: 28, sigma: 7.9 } as any],
      // loser updates
      [{ mu: 22, sigma: 9.1 } as any],
    ])

    const [updatedWinners, updatedLosers, avgDelta] = calculateScore(winners, losers, 'Foosball')

    expect(updatedWinners[0].mu).toBeCloseTo(28)
    expect(updatedWinners[0].sigma).toBeCloseTo(7.9)
    expect(updatedLosers[0].mu).toBeCloseTo(22)
    expect(updatedLosers[0].sigma).toBeCloseTo(9.1)

    // ordinal = mu - 3*sigma
    const newOrdinal = 28 - 3 * 7.9
    const delta = newOrdinal - winners[0].ordinal
    expect(avgDelta).toBeCloseTo(delta)
    expect(updatedWinners[0].lastOpenSkillChange).toBeCloseTo(delta)
  })

  it('toDisplayDelta and toDisplayOrdinal scale values by 60 and round', () => {
    expect(toDisplayDelta(1.2)).toBe(72)
    expect(toDisplayDelta(1.5)).toBe(90)
    expect(toDisplayOrdinal(2)).toBe(120)
  })

  it('getWinProbability delegates to OpenSkill.getWinProbability', () => {
    const teamA = [makePlayer({ mu: 27 })]
    const teamB = [makePlayer({ mu: 23 })]

    vi.spyOn(OpenSkillModule, 'getWinProbability').mockReturnValue(0.8)

    expect(getWinProbability(teamA, teamB)).toBeCloseTo(0.8)
  })

  it('roundScore rounds to nearest int', () => {
    expect(roundScore(2.2)).toBe(2)
    expect(roundScore(2.5)).toBe(3)
  })
})