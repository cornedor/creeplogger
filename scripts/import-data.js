const fs = require('fs');
const path = require('path');
const { initializeApp } = require('firebase/app');
const { getDatabase, ref, set, push, get, update, connectDatabaseEmulator } = require('firebase/database');

// Import compiled ReScript modules
const { calculateScore } = require('../src/helpers/OpenSkillRating.bs.mjs');

// Emulator configuration
const config = {
  projectId: 'demo-creeplogger',
  databaseURL: 'https://demo-creeplogger-default-rtdb.firebaseio.com',
  apiKey: 'demo-api-key',
  authDomain: 'demo-creeplogger.firebaseapp.com',
};

const app = initializeApp(config);
const db = getDatabase(app);

// Connect to emulator
connectDatabaseEmulator(db, 'localhost', 9000);

// Create default OpenSkill player
function createDefaultPlayer(playerKey, playerName, mattermostHandle = null) {
  return {
    name: playerName,
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
    key: playerKey,
    mh: mattermostHandle,
    lastGames: [],
    hidden: null,
    mu: 25.0,
    sigma: 8.333,
    ordinal: 0.0,
    osChange: 0.0,
    dartsElo: 1000.0,
    dartsChange: 0.0,
    dartsGames: 0,
    dartsWins: 0,
    dartsLosses: 0,
    dartsLastGames: []
  };
}

// Get team from team array (either redTeam or blueTeam)
function getTeam(teamIds, players) {
  return teamIds.map(id => players[id]);
}

// Update player stats after a game (non-rating stats)
function updatePlayerGameStats(player, isWin, isAbsolute, teamColor, teamGoals, opponentGoals) {
  const isRed = teamColor === 'red';
  const isBlue = teamColor === 'blue';
  
  // Update last 5 games
  const lastGames = [...player.lastGames, isWin ? 1 : 0].slice(-5);
  
  return {
    ...player,
    games: player.games + 1,
    wins: isWin ? player.wins + 1 : player.wins,
    losses: !isWin ? player.losses + 1 : player.losses,
    absoluteWins: (isWin && isAbsolute) ? player.absoluteWins + 1 : player.absoluteWins,
    absoluteLosses: (!isWin && isAbsolute) ? player.absoluteLosses + 1 : player.absoluteLosses,
    redGames: isRed ? player.redGames + 1 : player.redGames,
    blueGames: isBlue ? player.blueGames + 1 : player.blueGames,
    redWins: (isRed && isWin) ? player.redWins + 1 : player.redWins,
    blueWins: (isBlue && isWin) ? player.blueWins + 1 : player.blueWins,
    teamGoals: player.teamGoals + teamGoals,
    teamGoalsAgainst: player.teamGoalsAgainst + opponentGoals,
    lastGames
  };
}

// Check if a game result is absolute (7-0, 7-1, or 7-2)
function isAbsolute(winnerScore, loserScore) {
  return winnerScore === 7 && loserScore <= 2;
}

async function processMatchHistory() {
  console.log('🏆 Processing match history with OpenSkill calculations...');
  
  try {
    // Clear the entire database first
    console.log('🧹 Clearing existing database...');
    const rootRef = ref(db, '/');
    await set(rootRef, null);
    console.log('   ✅ Database cleared\n');
    
    // Read the existing data.json file
    const dataPath = path.join(process.cwd(), 'data.json');
    if (!fs.existsSync(dataPath)) {
      throw new Error('data.json file not found in project root');
    }
    
    const rawData = fs.readFileSync(dataPath, 'utf8');
    const data = JSON.parse(rawData);
    
    if (!data.games || !data.players) {
      throw new Error('data.json must contain both games and players sections');
    }

    // Initialize players with OpenSkill defaults
    console.log('👥 Initializing players with OpenSkill defaults...');
    const players = {};
    const playerNames = {};
    
    for (const [playerId, playerData] of Object.entries(data.players)) {
      players[playerId] = createDefaultPlayer(playerId, playerData.name, playerData.mh || null);
      playerNames[playerId] = playerData.name;
      console.log(`   📊 ${playerData.name}: Reset to OpenSkill defaults (mu=25.0, sigma=8.333, ordinal=0.0)`);
    }

    // Sort games chronologically by date
    const games = Object.entries(data.games)
      .map(([gameId, gameData]) => ({ ...gameData, id: gameId }))
      .sort((a, b) => a.date - b.date);

    console.log('');
    console.log(`⚽ Processing ${games.length} games chronologically...`);
    
    let processedGames = 0;
    const finalGames = {};

    for (const game of games) {
      const { redTeam, blueTeam, redScore, blueScore, date, modifiers = [] } = game;
      
      // Skip games with missing teams or invalid scores
      if (!redTeam || !blueTeam || redScore === undefined || blueScore === undefined) {
        console.log(`   ⚠️  Skipping invalid game: ${game.id}`);
        continue;
      }

      // Determine winner and loser
      const isRedWin = redScore > blueScore;
      const winners = isRedWin ? getTeam(redTeam, players) : getTeam(blueTeam, players);
      const losers = isRedWin ? getTeam(blueTeam, players) : getTeam(redTeam, players);
      const winnerScore = isRedWin ? redScore : blueScore;
      const loserScore = isRedWin ? blueScore : redScore;
      
      // Skip games where we can't find all players
      if (winners.some(p => !p) || losers.some(p => !p)) {
        console.log(`   ⚠️  Skipping game with missing players: ${game.id}`);
        continue;
      }

      // Calculate new OpenSkill ratings using app logic
      const [updatedWinners, updatedLosers, avgChange] = calculateScore(
        winners, 
        losers, 
        winnerScore, 
        loserScore
      );

      // Update game stats for all players
      const gameIsAbsolute = isAbsolute(winnerScore, loserScore);
      
      // Update winners
      for (let i = 0; i < updatedWinners.length; i++) {
        const playerId = isRedWin ? redTeam[i] : blueTeam[i];
        const teamColor = isRedWin ? 'red' : 'blue';
        players[playerId] = updatePlayerGameStats(
          updatedWinners[i], 
          true, 
          gameIsAbsolute, 
          teamColor, 
          winnerScore, 
          loserScore
        );
      }
      
      // Update losers
      for (let i = 0; i < updatedLosers.length; i++) {
        const playerId = isRedWin ? blueTeam[i] : redTeam[i];
        const teamColor = isRedWin ? 'blue' : 'red';
        players[playerId] = updatePlayerGameStats(
          updatedLosers[i], 
          false, 
          gameIsAbsolute, 
          teamColor, 
          loserScore, 
          winnerScore
        );
      }

      // Store the processed game
      finalGames[game.id] = {
        redTeam,
        blueTeam,
        redScore,
        blueScore,
        date,
        modifiers
      };

      processedGames++;
      
      if (processedGames % 50 === 0 || processedGames === games.length) {
        console.log(`   ⚽ Processed ${processedGames}/${games.length} games...`);
      }
    }

    // Import the recalculated data to Firebase
    console.log('');
    console.log('📤 Importing processed data to Firebase...');
    
    // Import players
    const playersRef = ref(db, 'players');
    await set(playersRef, players);
    console.log(`   ✅ Imported ${Object.keys(players).length} players with recalculated OpenSkill ratings`);
    
    // Import games
    const gamesRef = ref(db, 'games');
    await set(gamesRef, finalGames);
    console.log(`   ✅ Imported ${Object.keys(finalGames).length} processed games`);
    
    // Import other sections (skip dartsGames)
    const otherSections = ['queue', 'rules', 'summary', 'stats'];
    for (const section of otherSections) {
      if (data[section]) {
        const sectionRef = ref(db, section);
        await set(sectionRef, data[section]);
        const items = typeof data[section] === 'object' ? Object.keys(data[section]).length : 1;
        console.log(`   ✅ Imported ${section} (${items} items)`);
      }
    }
    
    // Print final ratings for verification
    console.log('');
    console.log('🏅 Final OpenSkill ratings:');
    const sortedPlayers = Object.values(players)
      .filter(p => p.games > 0)
      .sort((a, b) => b.ordinal - a.ordinal)
      .slice(0, 10);
      
    for (const player of sortedPlayers) {
      console.log(`   ${player.name}: ${(player.ordinal * 60).toFixed(0)} (${player.games} games, mu=${player.mu.toFixed(1)}, σ=${player.sigma.toFixed(1)})`);
    }
    
    console.log('');
    console.log('🎉 Match history processing completed!');
    console.log(`📊 Processed ${processedGames} games with OpenSkill calculations`);
    console.log('');
    console.log('🔍 View your data at: http://localhost:4000');
    console.log('🚀 Start your app with: npm run dev');
    console.log('');
    console.log('💡 Mattermost integration was skipped during testing');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error processing match history:', error.message);
    console.error('Stack trace:', error.stack);
    console.log('');
    console.log('🔧 Troubleshooting:');
    console.log('1. Make sure Firebase emulator is running: npm run emulator');
    console.log('2. Check that data.json exists in the project root');
    console.log('3. Verify ReScript compilation: npm run res:build');
    console.log('4. Verify the emulator is accessible at http://localhost:9000');
    process.exit(1);
  }
}

processMatchHistory();