// ReScript bindings for the openskill npm package

type rating = {
  mu: float,
  sigma: float,
}

type modelOptions = {
  balance: bool,
}

type rateOptions = {
  tau: float,
  model: string,
}

// External bindings for the openskill JavaScript library
@module("openskill") external rating: unit => rating = "rating"
@module("openskill") external ratingWithValues: {.."mu": float, "sigma": float} => rating = "rating"

@module("openskill") external rate: array<array<rating>> => array<array<rating>> = "rate"
@module("openskill") external rateWithModel: (array<array<rating>>, modelOptions) => array<array<rating>> = "rate"

@module("openskill") external ordinal: rating => float = "ordinal"

@module("openskill") external predictWin: array<array<rating>> => array<float> = "predictWin"

// Helper functions for creating and working with ratings

@inline
let createRating = (~mu=1500.0, ~sigma=500.0, ()) => ratingWithValues({"mu": mu, "sigma": sigma})

@inline
let defaultRating = () => rating()

@inline
let getOrdinal = rating => ordinal(rating)

// Calculate new ratings after a game with balance=true
let rateGame = (winningTeam: array<rating>, losingTeam: array<rating>) => {
  let teams = [winningTeam, losingTeam]
  let modelOptions = {balance: true}
  let results = rateWithModel(teams, modelOptions)
  switch results {
  | [winnerUpdates, loserUpdates] => (winnerUpdates, loserUpdates)
  | _ => panic("Unexpected result from rate function")
  }
}

// Calculate win probability between two teams
let getWinProbability = (teamA: array<rating>, teamB: array<rating>) => {
  let probabilities = predictWin([teamA, teamB])
  Array.getUnsafe(probabilities, 0) // Return probability for first team
}

// Convert player to OpenSkill rating
let playerToRating = (player: Players.player) => {
  createRating(~mu=player.mu, ~sigma=player.sigma, ())
}

// Calculate team's average rating for display purposes
let getTeamAverageRating = (team: array<rating>) => {
  let totalMu = Array.reduce(team, 0.0, (acc, rating) => acc +. rating.mu)
  let totalSigma = Array.reduce(team, 0.0, (acc, rating) => acc +. rating.sigma)
  let teamSize = Array.length(team)->Int.toFloat
  
  if teamSize > 0.0 {
    createRating(~mu=totalMu /. teamSize, ~sigma=totalSigma /. teamSize, ())
  } else {
    defaultRating()
  }
}

// Apply margin multiplier based on score difference (similar to the Python PoC)
let applyMarginMultiplier = (scoreA: int, scoreB: int, baseChange: float) => {
  let scoreDiff = abs(scoreA - scoreB)->Int.toFloat
  let margin = Math.max(1.0, scoreDiff *. 0.5)
  baseChange *. margin
}