# CLAUDE.md - Creeplogger (Kruiplogger) Project Guide

**Last Updated**: 2025-11-28

## Project Overview

**Creeplogger** (Dutch: "Kruiplogger") is a competitive game tracking application for recording and managing scores for foosball (table soccer) and darts games. The term "creep" refers to losing badly, with "absolute" losses being 7-goal differences in foosball.

### Key Features
- Player management and tracking
- Multi-game support (Foosball and Darts)
- Dual rating systems: ELO and OpenSkill (TrueSkill-like)
- Real-time score tracking with team assignment (Blue vs Red)
- Statistics and leaderboard with sorting options
- Daily summaries via Mattermost integration
- Match-making suggestions for balanced teams
- PWA support for mobile installation
- Admin panel for player management

### User Interface Language
The UI is in **Dutch**. Common terms:
- **Kruiplogger** = Creeplogger (losing tracker)
- **Blauw** = Blue team
- **Rood** = Red team
- **Tafelvoetbal** = Foosball/Table Soccer
- **Darts** = Darts

---

## Tech Stack & Architecture

### Core Technologies
- **Next.js 15.1.3** - React framework with App Router (server and client components)
- **React 19** - UI library
- **ReScript 11.1.4** - Strongly-typed functional language (primary business logic)
- **TypeScript 5** - For Next.js entry points and API routes

### Multi-Language Architecture Pattern
This project uses a **ReScript-first** approach:
1. **Business logic**: Written in ReScript (`.res` files)
2. **Entry points**: TypeScript (`.tsx` files) for Next.js pages
3. **Compiled outputs**: ReScript generates `.bs.mjs` files
4. **Tracked outputs**: `.bs.mjs` files are **intentionally tracked in git** for code review

### Styling & UI
- **Tailwind CSS 3** - Utility-first CSS framework
- **Custom Fonts**:
  - Inter (primary font)
  - Caveat (handwritten style, accessible via `font-handwritten` class)
- **Custom Theme**:
  - Dark background: `#242328` (`darkbg` color)
  - Blue ring: `#6ca2ee` (Blue team indicator)
  - Red ring: `#ee6c6c` (Red team indicator)
  - Background blobs: `/public/BG.png`

### Backend & Database
- **Firebase 11.1.0**:
  - Firebase Realtime Database (data storage)
  - Firebase Authentication
- **Real-time subscriptions**: Firebase listeners with React hooks

### Rating Systems
- **Custom ELO implementation** - Traditional ELO rating (`src/helpers/Elo.res`)
- **OpenSkill (openskill 4.1.0)** - Microsoft TrueSkill-like algorithm (`src/helpers/OpenSkill.res`)

### State Management
- **React Hooks** - Built-in state management
- **React Hook Form 7.54.2** - Form management with ReScript bindings
- **Firebase as source of truth** - Real-time database subscriptions
- **Transaction-based updates** - Atomic stat updates using Firebase transactions

### Monitoring & Analytics
- **Sentry (@sentry/nextjs 8.47.0)** - Error tracking and monitoring
  - Organization: `corne-dorrestijn`
  - Project: `creeplogger`
  - Tunnel route: `/monitoring` (bypasses ad-blockers)
- **Plausible Analytics** - Privacy-friendly analytics (embedded script)

### Schema & Validation
- **rescript-schema 8.0.0** - Runtime schema validation
- **rescript-schema-ppx** - Compile-time schema generation with `@schema` decorator

---

## Directory Structure

```
/home/user/creeplogger/
├── src/
│   ├── app/                          # Next.js App Router
│   │   ├── admin/                   # Admin panel for player management
│   │   │   ├── Admin.res            # Admin page component
│   │   │   ├── Admin.resi           # Admin interface
│   │   │   ├── LoginForm.res        # Authentication form
│   │   │   └── page.tsx             # Next.js entry point
│   │   ├── api/                     # API routes
│   │   │   ├── daily-update/        # Cron job endpoint (Vercel Cron)
│   │   │   │   └── route.ts         # Daily Mattermost summary
│   │   │   └── summary/             # Summary API
│   │   │       └── route.ts         # GET /api/summary?period=daily|weekly|monthly|all
│   │   ├── queue/                   # Queue management page
│   │   │   ├── QueuePage.res        # Queue UI component
│   │   │   └── page.tsx             # Next.js entry point
│   │   ├── Logger.res               # Main application component (client)
│   │   ├── Logger.resi              # Logger interface
│   │   ├── LoggerS.res              # Server-side data fetching wrapper
│   │   ├── layout.tsx               # Root layout with fonts and meta
│   │   ├── page.tsx                 # Home page entry
│   │   ├── globals.css              # Global styles and Tailwind directives
│   │   ├── global-error.jsx         # Error boundary
│   │   └── [icons]                  # Favicon, apple-icon, etc.
│   ├── components/                  # React components (ReScript)
│   │   ├── UserGrid.res             # Player selection grid (step 1)
│   │   ├── ScoreStep.res            # Score input (step 2 for foosball)
│   │   ├── DartsGameModeStep.res    # Darts mode selection (step 2 for darts)
│   │   ├── ConfirmationStep.res     # Final confirmation (step 3)
│   │   ├── Header.res               # App header with navigation
│   │   ├── LeaderboardModal.res     # Rankings/leaderboard display
│   │   ├── StatsModal.res           # Player statistics modal
│   │   ├── MatchMakerModal.res      # Team suggestion modal
│   │   ├── NewPlayerForm.res        # Add new player form
│   │   ├── Button.res               # Reusable button component
│   │   ├── GridItem.res             # Player card container
│   │   ├── Link.res                 # Navigation link wrapper
│   │   └── [icons]                  # AdminIcon, DartsIcon, SoccerIcon, etc.
│   └── helpers/                     # Business logic and utilities (ReScript)
│       ├── Database.res             # Firebase config and initialization
│       ├── Firebase.res             # Firebase bindings and type definitions
│       ├── FirebaseSchema.res       # Schema helpers for Firebase data
│       ├── Players.res              # Player CRUD operations and data models
│       ├── Games.res                # Foosball game logic and data models
│       ├── DartsGames.res           # Darts game logic and data models
│       ├── Elo.res                  # ELO rating calculations
│       ├── OpenSkill.res            # OpenSkill (TrueSkill) bindings
│       ├── OpenSkillRating.res      # OpenSkill rating calculations
│       ├── Stats.res                # Statistics calculations
│       ├── Summary.res              # Daily summary generation
│       ├── Mattermost.res           # Mattermost webhook integration
│       ├── Queue.res                # Player queue management
│       ├── Rules.res                # Game rules validation
│       ├── Periods.res              # Time period utilities
│       ├── Search.res               # Player search functionality
│       └── [various utilities]      # Other helper modules
├── public/                          # Static assets
│   ├── BG.png                       # Background image (blobs pattern)
│   └── manifest.json                # PWA manifest
├── .github/workflows/               # GitHub Actions
│   ├── claude.yml                   # Claude Code integration
│   └── claude-code-review.yml       # Code review workflow
├── package.json                     # Dependencies and scripts
├── rescript.json                    # ReScript compiler configuration
├── next.config.mjs                  # Next.js configuration
├── tailwind.config.ts               # Tailwind CSS configuration
├── tsconfig.json                    # TypeScript configuration
├── vercel.json                      # Vercel deployment config (Cron jobs)
├── .env                             # Environment variables (Firebase, Mattermost)
└── .gitignore                       # Git ignore rules
```

---

## Key Conventions

### ReScript File Organization

1. **Triple-file pattern** for components and modules:
   - `.res` - Implementation
   - `.resi` - Interface (type signatures, public API)
   - `.bs.mjs` - Generated JavaScript (tracked in git)

2. **Interface files (`.resi`)** are **required** for Fast Refresh:
   - Must export **only React components** for proper Fast Refresh
   - Keep exports minimal to prevent breaking Fast Refresh

3. **Generated files (`.bs.mjs`)** are tracked in git:
   - Allows code review of actual JavaScript output
   - Helps detect inefficient code during compiler upgrades
   - Makes it easier for non-ReScript developers to review changes

### ReScript Configuration

**File**: `rescript.json`

Key settings:
- **JSX version 4** with automatic mode (no need for `React.createElement`)
- **ES modules** with in-source compilation
- **Suffix**: `.bs.mjs`
- **Compiler flags**:
  - `-open RescriptCore` - Auto-open RescriptCore module
  - `-open RescriptSchema` - Auto-open RescriptSchema module
- **PPX flags**:
  - `@greenlabs/ppx-rhf/ppx` - React Hook Form integration
  - `rescript-schema-ppx/bin` - Schema generation with `@schema` decorator

### ReScript-TypeScript Interop

**GenType configuration** enabled for TypeScript type generation:
- Language: TypeScript
- Module: ES6
- Import path: Relative
- Interfaces not exported by default

Use `@genType` decorator to export types to TypeScript:
```rescript
@genType
type player = { name: string, wins: int }
```

### Firebase Data Patterns

1. **Schema validation** for all Firebase data:
   ```rescript
   @schema
   type player = {
     name: string,
     wins: int,
     // ...
   }
   ```

2. **Transaction-based updates** for statistics:
   ```rescript
   // Use Firebase transactions for atomic updates
   Firebase.Database.runTransaction(ref, transaction => {
     // Update logic
   })
   ```

3. **Real-time subscriptions** with hooks:
   ```rescript
   let (players, setPlayers) = React.useState(_ => [])

   React.useEffect0(() => {
     let unsubscribe = Firebase.onValue(playersRef, snapshot => {
       // Update state
     })
     Some(unsubscribe)
   })
   ```

### Naming Conventions

- **ReScript files**: PascalCase (e.g., `Players.res`, `LeaderboardModal.res`)
- **TypeScript files**: kebab-case or camelCase (e.g., `route.ts`, `page.tsx`)
- **Components**: PascalCase (e.g., `UserGrid`, `ScoreStep`)
- **Functions**: camelCase (e.g., `getAllPlayers`, `updatePlayerStats`)
- **Constants**: UPPER_SNAKE_CASE or camelCase (e.g., `firebaseConfig`)

### Component Patterns

**Multi-step workflow** for game logging:
```rescript
type step = PlayerSelection | ScoreInput | Confirmation

// Logger.res orchestrates the workflow
switch currentStep {
| PlayerSelection => <UserGrid ... />
| ScoreInput => gameMode == Foosball ? <ScoreStep ... /> : <DartsGameModeStep ... />
| Confirmation => <ConfirmationStep ... />
}
```

**Modal pattern** with visibility state:
```rescript
let (modalVisible, setModalVisible) = React.useState(_ => false)

<>
  <button onClick={_ => setModalVisible(_ => true)}>
    {React.string("Open Modal")}
  </button>
  {modalVisible ? <Modal onClose={_ => setModalVisible(_ => false)} /> : React.null}
</>
```

---

## Data Models

### Player Model

**File**: `src/helpers/Players.res`

```rescript
@schema
type player = {
  // Core
  name: string,
  key: string,

  // Foosball statistics
  wins: int,
  losses: int,
  absoluteWins: int,        // 7+ goal margin wins
  absoluteLosses: int,      // 7+ goal margin losses
  games: int,
  teamGoals: int,
  teamGoalsAgainst: int,
  blueGames: int,           // Games played on blue team
  redGames: int,            // Games played on red team
  blueWins: int,            // Wins on blue team
  redWins: int,             // Wins on red team
  lastGames: array<int>,    // Last 5 games (1=win, 0=loss)

  // Foosball ratings
  elo: float,               // Current ELO rating
  lastEloChange: float,     // Last ELO change
  mu: float,                // OpenSkill skill estimate
  sigma: float,             // OpenSkill uncertainty
  ordinal: float,           // Display rating (mu - 3*sigma)
  lastOpenSkillChange: float,

  // Darts statistics
  dartsElo: float,
  dartsLastEloChange: float,
  dartsGames: int,
  dartsWins: int,
  dartsLosses: int,
  dartsLastGames: array<int>,

  // Optional fields
  mattermostHandle: option<string>,
  hidden: option<bool>,     // Hide from UI if true
}
```

### Game Model (Foosball)

**File**: `src/helpers/Games.res`

```rescript
@schema
type game = {
  blueScore: int,
  redScore: int,
  blueTeam: array<string>,  // Player keys
  redTeam: array<string>,   // Player keys
  date: Date.t,
  modifiers: option<array<modifier>>,
}

type modifier =
  | Handicap(int, int)      // Score handicaps
  | OneVOne                 // 1v1 modifier
```

**Important**: Teams can have 1-2 players each.

### Darts Game Model

**File**: `src/helpers/DartsGames.res`

```rescript
@schema
type dartsGame = {
  winners: array<string>,   // Player keys
  losers: array<string>,    // Player keys
  date: Date.t,
  mode: dartsMode,
}

type dartsMode =
  | AroundTheClock
  | Bullen
  | Killer
  | M501                    // 501 darts
  | M301                    // 301 darts
  | Unknown
```

### Stats Model

**File**: `src/helpers/Stats.res`

```rescript
@schema
type stats = {
  totalGames: int,
  totalRedWins: int,
  totalBlueWins: int,
  totalAbsoluteWins: int,
  totalDartsGames: int,
}
```

### Queue Model

**File**: `src/helpers/Queue.res`

```rescript
@schema
type queueItem = {
  playerKey: string,
  until: float,             // Unix timestamp
}
```

---

## Development Workflow

### Initial Setup

```bash
# Install dependencies
npm install

# Start development server (runs ReScript + Next.js concurrently)
npm run dev
```

The dev server runs on `http://localhost:3000`.

### Development Scripts

```json
{
  "dev": "concurrently \"npm run res:start\" \"npm run next:dev\"",
  "build": "rescript && next build",
  "tsc": "tsc",
  "next:dev": "next dev",
  "next:build": "next build",
  "next:start": "next start",
  "next:lint": "next lint",
  "res:build": "rescript",
  "res:clean": "rescript clean",
  "res:start": "rescript build -w"
}
```

### Making Changes

#### When modifying ReScript code:

1. Edit `.res` file
2. ReScript compiler auto-compiles to `.bs.mjs`
3. Review generated `.bs.mjs` for efficiency
4. Update `.resi` interface if public API changed
5. **Commit both `.res` and `.bs.mjs` files**

#### When modifying TypeScript/Next.js code:

1. Edit `.tsx` or `.ts` file
2. TypeScript compiler runs automatically
3. Check for type errors with `npm run tsc`

#### When modifying styles:

1. Edit Tailwind classes in components
2. Or edit `src/app/globals.css` for global styles
3. Hot reload should reflect changes immediately

### Common Development Tasks

#### Adding a new player field:

1. Update `player` type in `src/helpers/Players.res`
2. Update `playerSchema` if using `@schema` decorator
3. Update Firebase transaction logic in relevant functions
4. Update UI components that display player data
5. Consider migration for existing Firebase data

#### Adding a new game mode:

1. Add new variant to `dartsMode` in `src/helpers/DartsGames.res`
2. Update `DartsGameModeStep.res` UI
3. Update `Summary.res` for summary generation
4. Update any mode-specific logic

#### Adding a new statistic:

1. Update data model (e.g., `player` type)
2. Update calculation logic (e.g., in `Stats.res`)
3. Update transaction logic for atomic updates
4. Update UI to display new statistic
5. Update `Summary.res` if needed for daily reports

---

## Code Style Guidelines

### ReScript Style

1. **Use pattern matching** over if/else when possible:
   ```rescript
   // Good
   switch player.wins {
   | 0 => "No wins yet"
   | 1 => "1 win"
   | n => `${Int.toString(n)} wins`
   }

   // Avoid
   if player.wins == 0 {
     "No wins yet"
   } else if player.wins == 1 {
     "1 win"
   } else {
     `${Int.toString(player.wins)} wins`
   }
   ```

2. **Leverage type inference**:
   ```rescript
   // Good - type is inferred
   let players = Players.getAllPlayers()

   // Unnecessary
   let players: array<Players.player> = Players.getAllPlayers()
   ```

3. **Use pipe operator** for data transformations:
   ```rescript
   // Good
   players
   ->Array.filter(p => !p.hidden->Option.getOr(false))
   ->Array.sortBy(p => p.elo)
   ->Array.reverse

   // Avoid
   Array.reverse(Array.sortBy(Array.filter(players, p => !Option.getOr(p.hidden, false)), p => p.elo))
   ```

4. **Prefer immutable data** - use spread operators:
   ```rescript
   // Good
   let updatedPlayer = {...player, wins: player.wins + 1}

   // Avoid (mutation)
   player.wins = player.wins + 1
   ```

5. **Handle options explicitly**:
   ```rescript
   // Good - explicit handling
   switch player.mattermostHandle {
   | Some(handle) => `@${handle}`
   | None => player.name
   }

   // Or with Option.getOr
   player.mattermostHandle->Option.getOr(player.name)
   ```

### TypeScript Style

1. **Use explicit types** for API responses and props
2. **Avoid `any`** - use `unknown` and type guards if needed
3. **Use async/await** over promise chains

### Tailwind CSS Guidelines

1. **Use semantic color names**: `bg-darkbg`, `text-blue-500`
2. **Use custom utilities**: `font-handwritten`, `bg-blobs`
3. **Responsive design**: Mobile-first approach
4. **Team indicators**: Use `ring-blue` and `ring-red` for team colors

---

## Testing & Quality Assurance

### Current State

**No formal testing framework** is currently configured.

### Quality Assurance Approaches

1. **Type safety**: ReScript's strong type system catches errors at compile time
2. **Schema validation**: Runtime validation with `rescript-schema`
3. **Linting**: ESLint with `next/core-web-vitals` preset
4. **Manual testing**: QA process before deployment
5. **Sentry monitoring**: Production error tracking

### Manual Testing Checklist

When making changes, verify:
- [ ] ReScript compiles without errors (`npm run res:build`)
- [ ] TypeScript compiles without errors (`npm run tsc`)
- [ ] ESLint passes (`npm run next:lint`)
- [ ] Development server runs without errors
- [ ] UI renders correctly on mobile and desktop
- [ ] Firebase real-time updates work correctly
- [ ] No console errors in browser
- [ ] Sentry integration works (check error reporting)

### Future Testing Recommendations

Consider adding:
- Jest or Vitest for unit testing
- React Testing Library for component testing
- Playwright or Cypress for E2E testing
- rescript-vitest for ReScript-first testing

---

## Build & Deployment

### Build Process

```bash
# Production build
npm run build
```

**Build steps**:
1. ReScript compiles all `.res` files to `.bs.mjs`
2. Next.js builds production bundle
3. Sentry uploads source maps (automatically via `withSentryConfig`)

### Deployment

**Platform**: Vercel

**Automatic deployment** on git push to main branch.

### Vercel Configuration

**File**: `vercel.json`

```json
{
  "crons": [{
    "path": "/api/daily-update?send=true",
    "schedule": "30 17 * * *"
  }]
}
```

**Cron job**: Daily update at 17:30 UTC (sends Mattermost summary).

### Environment Variables

**Required** (set in Vercel dashboard or `.env` file):

```bash
# Firebase
NEXT_PUBLIC_FIREBASE_API_KEY=
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=
NEXT_PUBLIC_FIREBASE_DATABASE_URL=
NEXT_PUBLIC_FIREBASE_PROJECT_ID=
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=
NEXT_PUBLIC_FIREBASE_APP_ID=
NEXT_PUBLIC_FIREBASE_MEASUREMENT_ID=

# Mattermost
MATTERMOST_WEBHOOK_URL=
MATTERMOST_ENABLED=true

# Cron authentication
CRON_SECRET=

# Sentry (auto-configured by @sentry/nextjs)
SENTRY_AUTH_TOKEN=
```

### PWA Configuration

**File**: `public/manifest.json`

- **Name**: Kruiplogger
- **Display**: standalone (full-screen app)
- **Theme**: Dark (#242328)
- **Orientation**: portrait
- **Icons**: Favicon and apple-icon configured

Users can install the app on mobile devices.

---

## API Routes

### GET `/api/daily-update`

**File**: `src/app/api/daily-update/route.ts`

**Purpose**: Triggered by Vercel Cron job daily at 17:30 UTC.

**Authentication**: Bearer token (`CRON_SECRET` env var)

**Query parameters**:
- `?send=true` - Actually sends the update to Mattermost
- Omit `send` - Dry run, returns summary without sending

**Response**:
```json
{
  "message": "Daily update sent successfully",
  "summary": "..."
}
```

**Functionality**:
1. Fetches yesterday's games
2. Generates summary with player stats
3. Posts to Mattermost webhook

### GET `/api/summary`

**File**: `src/app/api/summary/route.ts`

**Purpose**: Get game summary statistics for a time period.

**Query parameters**:
- `?period=daily` - Yesterday's games
- `?period=weekly` - Last 7 days
- `?period=monthly` - Last 30 days
- `?period=all` - All-time statistics

**Response**:
```json
{
  "period": "daily",
  "games": 5,
  "players": [
    {
      "name": "Player Name",
      "games": 3,
      "wins": 2,
      "creeps": 1,
      "goalsScored": 15,
      "goalsConceded": 12
    }
  ]
}
```

---

## Common Issues & Solutions

### ReScript compilation errors

**Issue**: `.bs.mjs` file not generated or outdated.

**Solution**:
```bash
npm run res:clean
npm run res:build
```

### Fast Refresh not working

**Issue**: Changes not reflected in browser without full reload.

**Cause**: Non-React exports in `.resi` file.

**Solution**: Ensure `.resi` files only export React components.

### Firebase connection issues

**Issue**: "Permission denied" errors.

**Solution**: Check Firebase rules and ensure environment variables are set correctly.

### TypeScript type errors with ReScript modules

**Issue**: TypeScript can't find types for ReScript modules.

**Solution**: Use `@genType` decorator in ReScript files to generate TypeScript types.

### Sentry not capturing errors

**Issue**: Errors not appearing in Sentry dashboard.

**Solution**:
1. Verify `SENTRY_AUTH_TOKEN` is set
2. Check Sentry DSN is correct
3. Ensure error boundary is configured (`global-error.jsx`)

---

## Important Notes for AI Assistants

### Critical Patterns to Follow

1. **Always track `.bs.mjs` files**: When modifying `.res` files, include the generated `.bs.mjs` files in commits.

2. **Maintain type safety**: Use ReScript's type system. Avoid `Js.Nullable.t` unless necessary for JS interop.

3. **Transaction-based updates**: Use Firebase transactions for all statistic updates to prevent race conditions.

4. **Team balance**: The match-maker uses OpenSkill ratings to suggest balanced teams. Maintain this logic carefully.

5. **Dual rating systems**: Both ELO and OpenSkill are used. Update both when processing games.

6. **Interface files**: Create `.resi` files for all `.res` files to maintain Fast Refresh compatibility.

### Things to Avoid

1. **Don't mutate state**: Use immutable updates with spread operators.
2. **Don't skip schema validation**: Always validate Firebase data with schemas.
3. **Don't break Fast Refresh**: Keep `.resi` files clean (React components only).
4. **Don't modify `.bs.mjs` directly**: Always edit `.res` source files.
5. **Don't ignore TypeScript errors**: Fix type errors before committing.

### When Making Changes

1. **Read before writing**: Always read existing code before making changes.
2. **Test locally**: Run `npm run dev` and verify changes work.
3. **Check build**: Run `npm run build` to ensure production build succeeds.
4. **Verify types**: Run `npm run tsc` to check for TypeScript errors.
5. **Review generated code**: Check `.bs.mjs` files for efficiency.

### Git Workflow

- **Branch naming**: Use descriptive branch names (e.g., `feature/add-player-search`, `fix/elo-calculation`)
- **Commit messages**: Clear, descriptive messages (e.g., "Add search functionality to player grid")
- **Track all outputs**: Include `.bs.mjs` files in commits
- **Keep commits focused**: One logical change per commit

---

## Resources

### Documentation Links

- [ReScript Docs](https://rescript-lang.org)
- [Next.js Docs](https://nextjs.org/docs)
- [Firebase Docs](https://firebase.google.com/docs)
- [Tailwind CSS Docs](https://tailwindcss.com/docs)
- [OpenSkill Docs](https://openskill.me/en/stable/)

### Project-Specific Resources

- **Main branch**: Check recent commits for patterns
- **Admin panel**: `/admin` - Player management and stats recalculation
- **Queue page**: `/queue` - View and manage player queue
- **API routes**: `/api/summary` and `/api/daily-update` for integrations

---

## Changelog

### 2025-11-28
- Initial CLAUDE.md creation
- Documented complete codebase structure
- Added development workflows and conventions
- Documented all data models and API routes
