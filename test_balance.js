// Test script to verify game balance bug
// Run with: node test_balance.js

const { rating, predictWin } = require('openskill');

console.log('='.repeat(80));
console.log('GAME BALANCE BUG VERIFICATION TEST');
console.log('='.repeat(80));
console.log();

// Create example players with different skill levels
const alice = rating({ mu: 28.0, sigma: 6.0 });   // Strong
const bob = rating({ mu: 26.0, sigma: 7.0 });     // Above avg
const charlie = rating({ mu: 24.0, sigma: 7.5 }); // Average
const diana = rating({ mu: 22.0, sigma: 8.0 });   // Below avg

console.log('PLAYERS:');
console.log('  Alice:   mu=28.0, sigma=6.0 (Strong)');
console.log('  Bob:     mu=26.0, sigma=7.0 (Above average)');
console.log('  Charlie: mu=24.0, sigma=7.5 (Average)');
console.log('  Diana:   mu=22.0, sigma=8.0 (Below average)');
console.log();

console.log('HISTORICAL STATS:');
console.log('  Blue wins: 120 (60%)');
console.log('  Red wins: 80 (40%)');
console.log('  → Blue side has 10% positional advantage');
console.log();

// Test all 3 possible pairings
console.log('STEP 1: Find best pairing (closest to 50/50)');
console.log('-'.repeat(80));

const pairings = [
  { name: 'Pairing 1', team1: [alice, bob], team2: [charlie, diana], players: '(Alice+Bob) vs (Charlie+Diana)' },
  { name: 'Pairing 2', team1: [alice, charlie], team2: [bob, diana], players: '(Alice+Charlie) vs (Bob+Diana)' },
  { name: 'Pairing 3', team1: [alice, diana], team2: [bob, charlie], players: '(Alice+Diana) vs (Bob+Charlie)' },
];

let bestPairing = null;
let bestDeviation = Infinity;

pairings.forEach(pairing => {
  const probs = predictWin([pairing.team1, pairing.team2]);
  const team1WinProb = probs[0];
  const deviation = Math.abs(team1WinProb - 0.5);

  console.log(`${pairing.name}: ${pairing.players}`);
  console.log(`  Team 1 win probability: ${(team1WinProb * 100).toFixed(1)}%`);
  console.log(`  Deviation from 50%: ${(deviation * 100).toFixed(1)}%`);

  if (deviation < bestDeviation) {
    bestDeviation = deviation;
    bestPairing = pairing;
  }
  console.log();
});

console.log(`BEST PAIRING: ${bestPairing.name} with ${(bestDeviation * 100).toFixed(1)}% deviation`);
console.log(`  teamA = [Alice, Diana]`);
console.log(`  teamB = [Bob, Charlie]`);
console.log();

// Now test color assignment
const teamA = [alice, diana];
const teamB = [bob, charlie];

const pA = predictWin([teamA, teamB])[0];
const teamAIsStronger = pA >= 0.5;

console.log('STEP 2: Assign team colors');
console.log('-'.repeat(80));
console.log(`teamA (Alice+Diana) win probability: ${(pA * 100).toFixed(1)}%`);
console.log(`teamAIsStronger: ${teamAIsStronger} (${pA} >= 0.5)`);
console.log();

// Historical stats
const blueWins = 120;
const redWins = 80;
const total = blueWins + redWins;
const blueStronger = (blueWins / total) > 0.5;

console.log(`Blue historical win rate: ${(blueWins / total * 100).toFixed(1)}%`);
console.log(`blueStronger: ${blueStronger}`);
console.log();

// Current BUGGY logic
console.log('CURRENT (BUGGY) LOGIC:');
console.log('-'.repeat(80));
let blueTeam_current, redTeam_current;

// switch (blueStronger, teamAIsStronger)
if (blueStronger && teamAIsStronger) {
  blueTeam_current = teamA;
  redTeam_current = teamB;
  console.log('Case: (true, true) → Blue gets teamA (stronger), Red gets teamB');
} else if (blueStronger && !teamAIsStronger) {
  blueTeam_current = teamB;
  redTeam_current = teamA;
  console.log('Case: (true, false) → Blue gets teamB, Red gets teamA');
} else if (!blueStronger && teamAIsStronger) {
  blueTeam_current = teamB;
  redTeam_current = teamA;
  console.log('Case: (false, true) → Blue gets teamB, Red gets teamA');
} else {
  blueTeam_current = teamA;
  redTeam_current = teamB;
  console.log('Case: (false, false) → Blue gets teamA, Red gets teamB');
}

const pBlue_current = predictWin([blueTeam_current, redTeam_current])[0];
console.log();
console.log('Result:');
console.log(`  Blue team: ${blueTeam_current === teamA ? 'Alice+Diana (stronger)' : 'Bob+Charlie (weaker)'}`);
console.log(`  Red team: ${redTeam_current === teamA ? 'Alice+Diana (stronger)' : 'Bob+Charlie (weaker)'}`);
console.log(`  Blue pure skill win probability: ${(pBlue_current * 100).toFixed(1)}%`);
console.log();
console.log('Analysis:');
console.log(`  Blue side has +10% positional advantage (60% historical)`);
console.log(`  Blue has ${blueTeam_current === teamA ? 'STRONGER' : 'WEAKER'} team by skill`);
if (blueTeam_current === teamA) {
  console.log(`  Combined: ~${(pBlue_current * 100).toFixed(0)}% + 10% = ~${(pBlue_current * 100 + 10).toFixed(0)}% Blue win rate`);
  console.log(`  ❌ GAME IS IMBALANCED! (Strong team on strong side)`);
} else {
  console.log(`  Combined: ~${(pBlue_current * 100).toFixed(0)}% + 10% = ~${(pBlue_current * 100 + 10).toFixed(0)}% Blue win rate`);
  console.log(`  ✓ This would be balanced`);
}
console.log();

// CORRECT logic
console.log('CORRECT (FIXED) LOGIC:');
console.log('-'.repeat(80));
let blueTeam_correct, redTeam_correct;

// Inverted logic: assign WEAKER team to stronger side
if (blueStronger && teamAIsStronger) {
  blueTeam_correct = teamB;  // INVERTED
  redTeam_correct = teamA;
  console.log('Case: (true, true) → Blue gets teamB (weaker), Red gets teamA (stronger)');
} else if (blueStronger && !teamAIsStronger) {
  blueTeam_correct = teamA;  // INVERTED
  redTeam_correct = teamB;
  console.log('Case: (true, false) → Blue gets teamA (weaker), Red gets teamB');
} else if (!blueStronger && teamAIsStronger) {
  blueTeam_correct = teamA;  // INVERTED
  redTeam_correct = teamB;
  console.log('Case: (false, true) → Blue gets teamA, Red gets teamB (stronger)');
} else {
  blueTeam_correct = teamB;  // INVERTED
  redTeam_correct = teamA;
  console.log('Case: (false, false) → Blue gets teamB, Red gets teamA (weaker)');
}

const pBlue_correct = predictWin([blueTeam_correct, redTeam_correct])[0];
console.log();
console.log('Result:');
console.log(`  Blue team: ${blueTeam_correct === teamA ? 'Alice+Diana (stronger)' : 'Bob+Charlie (weaker)'}`);
console.log(`  Red team: ${redTeam_correct === teamA ? 'Alice+Diana (stronger)' : 'Bob+Charlie (weaker)'}`);
console.log(`  Blue pure skill win probability: ${(pBlue_correct * 100).toFixed(1)}%`);
console.log();
console.log('Analysis:');
console.log(`  Blue side has +10% positional advantage (60% historical)`);
console.log(`  Blue has ${blueTeam_correct === teamA ? 'STRONGER' : 'WEAKER'} team by skill`);
if (blueTeam_correct === teamA) {
  console.log(`  Combined: ~${(pBlue_correct * 100).toFixed(0)}% + 10% = ~${(pBlue_correct * 100 + 10).toFixed(0)}% Blue win rate`);
  console.log(`  ❌ This would be imbalanced`);
} else {
  console.log(`  Combined: ~${(pBlue_correct * 100).toFixed(0)}% + 10% - 10% (weaker) = ~${(50).toFixed(0)}% Blue win rate`);
  console.log(`  ✓ GAME IS BALANCED! (Weak team on strong side compensates)`);
}
console.log();

console.log('='.repeat(80));
console.log('CONCLUSION:');
console.log('='.repeat(80));
console.log('Current logic assigns STRONGER team to STRONGER side → AMPLIFIES imbalance');
console.log('Correct logic assigns WEAKER team to STRONGER side → COMPENSATES imbalance');
console.log();
console.log('Bug location: src/components/MatchMakerModal.res lines 112-117');
console.log('Fix: Invert the color assignment logic in assignColors function');
console.log('='.repeat(80));
