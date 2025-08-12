import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    environment: 'node',
    include: ['tests/**/*_test.bs.mjs'],
    setupFiles: ['tests/_shims/vitest.setup.ts'],
    coverage: {
      provider: 'v8',
      reportsDirectory: './coverage',
      reporter: ['text', 'html', 'lcov'],
      include: ['src/helpers/**/*.{bs.mjs,mjs,js}'],
    },
  },
})