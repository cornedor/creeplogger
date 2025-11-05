# Game Balance Test Scenario

## Setup

### Example Players (ordered by skill)
```
Alice:   mu=28.0, sigma=6.0  (Strong player, ordinal ≈ 10.0)
Bob:     mu=26.0, sigma=7.0  (Above average, ordinal ≈ 5.0)
Charlie: mu=24.0, sigma=7.5  (Average, ordinal ≈ 1.5)
Diana:   mu=22.0, sigma=8.0  (Below average, ordinal ≈ -2.0)
```

### Historical Stats
```
Blue wins: 120
Red wins: 80
Total: 200 games
Blue win rate: 60% (Blue side has positional advantage)
```

## Step-by-Step Execution

### Step 1: User selects all 4 players in MatchMakerModal

### Step 2: bestPairingOfFour() evaluates all 3 possible pairings

Let's calculate win probabilities for each pairing:

#### Pairing 1: (Alice + Bob) vs (Charlie + Diana)
```
Team 1: [28.0, 26.0] → avg mu = 27.0
Team 2: [24.0, 22.0] → avg mu = 23.0
OpenSkill predicts: Team 1 has ~75% win probability
Deviation from 0.5: |0.75 - 0.5| = 0.25
```

#### Pairing 2: (Alice + Charlie) vs (Bob + Diana)
```
Team 1: [28.0, 24.0] → avg mu = 26.0
Team 2: [26.0, 22.0] → avg mu = 24.0
OpenSkill predicts: Team 1 has ~60% win probability
Deviation from 0.5: |0.60 - 0.5| = 0.10
```

#### Pairing 3: (Alice + Diana) vs (Bob + Charlie)
```
Team 1: [28.0, 22.0] → avg mu = 25.0
Team 2: [26.0, 24.0] → avg mu = 25.0
OpenSkill predicts: Team 1 has ~50% win probability
Deviation from 0.5: |0.50 - 0.5| = 0.00  ← BEST PAIRING!
```

**Result:** Pairing 3 is selected (minimal deviation)
- teamA = [Alice, Diana]
- teamB = [Bob, Charlie]

### Step 3: assignColors() assigns team colors

```rescript
// Line 105: Calculate which team is stronger
let pA = OpenSkill.getWinProbability(teamA, teamB)
// pA = 0.50 (50% for teamA)

let teamAIsStronger = pA >= 0.5
// teamAIsStronger = true (barely, since 0.50 >= 0.5)

// Line 108-109: Check historical bias
let total = 120 + 80 = 200
let blueStronger = 120.0 / 200.0 > 0.5
// blueStronger = true (0.60 > 0.5)

// Line 112-117: Current (BUGGY) logic
switch (blueStronger, teamAIsStronger) {
| (true, true) => (/*Blue*/ teamA, /*Red*/ teamB)  ← THIS CASE
| ...
}
```

**Current Assignment:**
- Blue: Alice + Diana (the slightly stronger team in pure skill)
- Red: Bob + Charlie

### Step 4: Calculate Final Win Probability

Now Blue (Alice+Diana) plays on the historically advantageous Blue side:
```
Base skill probability: 50% (teams are balanced by skill)
But Blue side has 60% historical win rate (10% positional advantage)
Combined effect: ~55-60% Blue win probability

RESULT: Game is IMBALANCED by ~5-10% favoring Blue!
```

---

## What SHOULD Happen (Correct Logic)

The assignColors logic should be inverted:

```rescript
// CORRECT logic
switch (blueStronger, teamAIsStronger) {
| (true, true) => (/*Blue*/ teamB, /*Red*/ teamA)   ← Weaker to Blue
| (true, false) => (/*Blue*/ teamA, /*Red*/ teamB)  ← Weaker to Blue
| (false, true) => (/*Blue*/ teamA, /*Red*/ teamB)  ← Weaker to Red
| (false, false) => (/*Blue*/ teamB, /*Red*/ teamA) ← Weaker to Red
}
```

**Correct Assignment:**
- Blue: Bob + Charlie (the slightly weaker team)
- Red: Alice + Diana (the slightly stronger team)

**Final Probability:**
```
Blue side advantage: +10% (from 60% historical win rate)
Team skill disadvantage: -10% (weaker team by ~10%)
Net effect: 50% + 10% - 10% = ~50%

RESULT: Game is BALANCED! ✓
```

---

## Summary

| Aspect | Current (Buggy) | Correct |
|--------|----------------|---------|
| Blue Team | Alice + Diana (stronger) | Bob + Charlie (weaker) |
| Red Team | Bob + Charlie (weaker) | Alice + Diana (stronger) |
| Blue Win % | ~55-60% (IMBALANCED) | ~50% (BALANCED) |
| Logic | Strong team → Strong side | Weak team → Strong side |
| Effect | Amplifies imbalance | Compensates imbalance |

The bug causes the matchmaker to create MORE imbalanced games instead of balanced ones!
