// OpenSkill rating system to replace Elo calculations
// Equivalent functionality to Elo.res but using OpenSkill algorithm

type team = array<Players.player>

@inline
let getOpenSkillRating = (player: Players.player) => 
  OpenSkill.createRating(~mu=player.mu, ~sigma=player.sigma, ())

@inline 
let calculateOrdinal = (mu: float, sigma: float) => mu -. (3.0 *. sigma)

// Convert team of players to array of OpenSkill ratings
let teamToRatings = (team: team) => 
  Array.map(team, getOpenSkillRating)

// Update a player with new OpenSkill values
let updatePlayerRating = (player: Players.player, newRating: OpenSkill.rating) => {
  let newOrdinal = calculateOrdinal(newRating.mu, newRating.sigma)
  let muChange = newRating.mu -. player.mu
  
  {
    ...player,
    mu: newRating.mu,
    sigma: newRating.sigma, 
    ordinal: newOrdinal,
    lastEloChange: muChange, // Keep using lastEloChange for compatibility
  }
}

// Calculate new ratings for both teams after a game
// Returns (updated winners, updated losers, points change for display)
let calculateScore = (winners: team, losers: team, ~gameMode: Games.gameMode=Games.Foosball) => {
  // Convert teams to OpenSkill ratings
  let winnerRatings = teamToRatings(winners)
  let loserRatings = teamToRatings(losers)
  
  // Calculate new ratings
  let (newWinnerRatings, newLoserRatings) = OpenSkill.rateGame(winnerRatings, loserRatings)
  
  // Update players with new ratings
  let updatedWinners = Array.mapWithIndex(winners, (player, index) => {
    let newRating = Array.getUnsafe(newWinnerRatings, index)
    updatePlayerRating(player, newRating)
  })
  
  let updatedLosers = Array.mapWithIndex(losers, (player, index) => {
    let newRating = Array.getUnsafe(newLoserRatings, index)
    updatePlayerRating(player, newRating)
  })
  
  // Calculate average rating change for display (similar to Elo points)
  let avgWinnerChange = Array.reduce(updatedWinners, 0.0, (acc, player) => 
    acc +. player.lastEloChange
  ) /. Int.toFloat(Array.length(updatedWinners))
  
  (updatedWinners, updatedLosers, avgWinnerChange)
}

// Calculate win probability between two teams
let getWinProbability = (teamA: team, teamB: team) => {
  let ratingsA = teamToRatings(teamA)
  let ratingsB = teamToRatings(teamB)
  OpenSkill.getWinProbability(ratingsA, ratingsB)
}

// Round score for display (keeping compatibility with Elo.res)
let roundScore = score => Math.round(score)->Float.toInt