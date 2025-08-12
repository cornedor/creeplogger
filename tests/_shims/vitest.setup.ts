import { vi } from 'vitest'

// Alias @rescript/core modules used by compiled files to our shims
vi.mock('@rescript/core/src/Core__Array.bs.mjs', async () => {
  const mod = await import('./Core__Array.bs.mjs')
  return mod
})

vi.mock('@rescript/core/src/RescriptCore.bs.mjs', async () => {
  const mod = await import('./RescriptCore.bs.mjs')
  return mod
})

vi.mock('@rescript/core/src/Core__Option.bs.mjs', async () => {
  const mod = await import('./Core__Option.bs.mjs')
  return mod
})

// Prevent Firebase database access in tests that import compiled helpers indirectly
vi.mock('/workspace/src/helpers/Database.bs.mjs', () => {
  return {
    database: {},
    auth: {},
    config: {},
  }
})