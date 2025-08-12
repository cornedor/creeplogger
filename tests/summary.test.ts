import { describe, it, expect, vi } from 'vitest'

vi.mock('/workspace/src/helpers/Players.bs.mjs', async () => {
  const original: any = await vi.importActual('/workspace/src/helpers/Players.bs.mjs')
  return {
    ...original,
    fetchAllPlayers: vi.fn().mockResolvedValue({
      a: { name: 'Alice' },
      b: { name: 'Bob' },
      c: { name: 'Carol' },
      d: { name: 'Dave' },
    }),
  }
})

vi.mock('/workspace/src/helpers/Games.bs.mjs', async () => {
  const original: any = await vi.importActual('/workspace/src/helpers/Games.bs.mjs')
  return {
    ...original,
    getTimePeriod: vi.fn().mockResolvedValue({
      g1: {
        blueScore: 5,
        redScore: 6,
        blueTeam: ['a', 'b'],
        redTeam: ['c', 'd'],
      },
      g2: {
        blueScore: 7,
        redScore: 0,
        blueTeam: ['a'],
        redTeam: ['c'],
      },
    }),
  }
})

import * as Summary from '/workspace/src/helpers/Summary.bs.mjs'

describe('Summary.getDailyOverview', () => {
  it('accumulates creeps, games, and score for both teams including absolute wins', async () => {
    const result = await (Summary.getDailyOverview as any)('Daily')

    const toObj = (map: Map<any, any>) => {
      const obj: Record<string, any> = {}
      ;(map as any).forEach((v: any, k: string) => (obj[k] = v))
      return obj
    }

    const overview = toObj(result)

    expect(overview['a']).toEqual({ name: 'Alice', creeps: 1, games: 2, score: 1 })
    expect(overview['b']).toEqual({ name: 'Bob', creeps: 1, games: 1, score: -6 })
    expect(overview['c']).toEqual({ name: 'Carol', creeps: 2, games: 2, score: -1 })
    expect(overview['d']).toEqual({ name: 'Dave', creeps: 0, games: 1, score: 6 })
  })
})