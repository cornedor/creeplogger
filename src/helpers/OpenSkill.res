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
let createRating = (~mu=25.0, ~sigma=8.333, ()) => ratingWithValues({"mu": mu, "sigma": sigma})

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

// Calculate team skill variance to identify mismatched teams
let calculateTeamVariance = (team: array<rating>) => {
  let teamSize = Array.length(team)->Int.toFloat
  if teamSize <= 1.0 {
    0.0
  } else {
    let ordinals = Array.map(team, rating => ordinal(rating))
    let mean = Array.reduce(ordinals, 0.0, (acc, ord) => acc +. ord) /. teamSize
    let variance = Array.reduce(ordinals, 0.0, (acc, ord) => {
      let diff = ord -. mean
      acc +. (diff *. diff)
    }) /. teamSize
    Math.sqrt(variance) // Return standard deviation
  }
}

// Calculate team-vs-team strength difference
let calculateTeamStrengthDifference = (teamA: array<rating>, teamB: array<rating>) => {
  let avgA = Array.reduce(teamA, 0.0, (acc, rating) => acc +. ordinal(rating)) /. Int.toFloat(Array.length(teamA))
  let avgB = Array.reduce(teamB, 0.0, (acc, rating) => acc +. ordinal(rating)) /. Int.toFloat(Array.length(teamB))
  abs_float(avgA -. avgB)
}

// Smart rating multiplier that distinguishes between individual and team imbalances
let calculateSmartMultiplier = (winnerTeam: array<rating>, loserTeam: array<rating>) => {
  let winProbability = getWinProbability(winnerTeam, loserTeam)
  let winnerVariance = calculateTeamVariance(winnerTeam)
  let loserVariance = calculateTeamVariance(loserTeam)
  let maxInternalVariance = Math.max(winnerVariance, loserVariance)
  let teamStrengthDiff = calculateTeamStrengthDifference(winnerTeam, loserTeam)
  
  // Classify the type of imbalance
  let imbalanceType = if maxInternalVariance > 8.0 && teamStrengthDiff < 5.0 {
    // High internal variance, small team difference = Internal Mismatch (like Jasper+Twan)
    "internal"
  } else if maxInternalVariance < 6.0 && teamStrengthDiff > 8.0 {
    // Low internal variance, large team difference = Team Imbalance (Strong vs Weak teams)
    "team"
  } else {
    // Mixed or balanced
    "mixed"
  }
  
  let multiplier = switch imbalanceType {
  | "internal" => {
      // Internal mismatch: always dampen to protect individuals in unfair team compositions
      // Stronger dampening for higher variance (more unfair the composition)
      Math.max(0.4, 1.0 -. (maxInternalVariance -. 8.0) *. 0.12)
    }
  | "team" when winProbability < 0.3 => {
      // True team upset: full amplification
      Math.min(2.0, 1.0 +. (0.3 -. winProbability) *. 3.0)
    }
  | "team" when winProbability > 0.7 => {
      // Expected team result: slight dampening
      Math.max(0.9, 1.0 -. (winProbability -. 0.7) *. 0.3)
    }
  | "mixed" when winProbability < 0.3 => {
      // Mixed upset: moderate amplification
      Math.min(1.5, 1.0 +. (0.3 -. winProbability) *. 1.5)
    }
  | "mixed" when winProbability > 0.7 => {
      // Mixed expected: moderate dampening
      Math.max(0.7, 1.0 -. (winProbability -. 0.7) *. 0.8)
    }
  | _ => 1.0 // Balanced match or team category with balanced probability
  }
  
  multiplier
}