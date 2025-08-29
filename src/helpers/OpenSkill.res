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

// Calculate expectation-aware score margin multiplier
let calculateExpectationAwareScoreMultiplier = (
  winnerScore: int, 
  loserScore: int,
  winProbability: float  // Winner's pre-match win probability
) => {
  let scoreDiff = winnerScore - loserScore
  let loserScoreRatio = Int.toFloat(loserScore) /. 7.0  // How close loser got to winning
  
  // Base score impact: gradual curve where every point matters
  // 7-6: base 0.7, 7-4: base 1.0, 7-2: base 1.2, 7-0: base 1.5
  let baseMultiplier = 0.7 +. (Int.toFloat(scoreDiff) -. 1.0) *. 0.1
  
  // Adjust based on expectations
  let expectationAdjustment = if winProbability > 0.8 {
    // Heavy favorite winning
    if loserScoreRatio > 0.7 {
      // Almost lost to underdog! (7-6, 7-5)
      0.5  // Massive reduction - lucky to win
    } else if loserScoreRatio > 0.4 {
      // Closer than expected (7-4, 7-3)
      0.8  // Some reduction
    } else {
      // Dominated as expected (7-2, 7-0)
      1.0  // Normal
    }
  } else if winProbability > 0.6 {
    // Moderate favorite
    if loserScoreRatio > 0.7 {
      // Very close
      0.7  // Significant reduction
    } else if loserScoreRatio < 0.3 {
      // Dominated underdog
      1.2  // Bonus for dominance
    } else {
      1.0  // Normal
    }
  } else if winProbability < 0.3 {
    // Underdog winning
    if loserScoreRatio < 0.3 {
      // Dominated the favorite! (7-2, 7-0)
      1.5  // Big bonus for dominant upset
    } else if loserScoreRatio > 0.7 {
      // Barely won (7-6)
      1.1  // Small bonus - still an upset
    } else {
      1.3  // Good upset bonus
    }
  } else {
    // Balanced match (30-70% range)
    if scoreDiff == 1 {
      0.9  // Close games less impactful
    } else if scoreDiff >= 6 {
      1.3  // Spankings more impactful
    } else {
      1.0  // Normal impact
    }
  }
  
  baseMultiplier *. expectationAdjustment
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
  
  // Calculate continuous imbalance factors using tanh for smooth transitions
  // Internal imbalance factor (0 = balanced teams internally, 1 = maximum internal imbalance)
  let internalImbalanceFactor = Math.tanh(maxInternalVariance /. 10.0)
  
  // Team strength imbalance factor (0 = equal team strengths, 1 = maximum difference)
  let teamImbalanceFactor = Math.tanh(teamStrengthDiff /. 15.0)
  
  // Calculate relative weights of internal vs team imbalance
  // When internal variance is high relative to team difference, we weight it more
  let totalImbalance = internalImbalanceFactor +. teamImbalanceFactor +. 0.1
  let internalWeight = internalImbalanceFactor /. totalImbalance
  let teamWeight = 1.0 -. internalWeight
  
  // Check if winner was favored
  let isWinnerFavored = winProbability > 0.5
  
  let multiplier = if internalWeight > 0.6 {
    // Primarily internal mismatch - reduce impact significantly
    // The more internal imbalance, the more we dampen (minimum 0.3x for extreme cases)
    let baseDampening = 1.0 -. (0.7 *. internalImbalanceFactor)
    
    // If the internally mismatched team was expected to lose anyway, dampen even more
    if isWinnerFavored && winProbability > 0.7 {
      baseDampening *. 0.8  // Additional 20% reduction for expected results
    } else {
      baseDampening
    }
  } else if teamWeight > 0.6 {
    // Primarily team strength difference
    if winProbability < 0.3 {
      // Upset victory - amplify based on team difference
      1.0 +. (0.5 *. teamImbalanceFactor)
    } else if winProbability > 0.7 {
      // Expected result - slight dampening
      1.0 -. (0.2 *. teamImbalanceFactor)
    } else {
      1.0  // Balanced probability
    }
  } else {
    // Mixed scenario - proportional adjustments
    // The more balanced the win probability, the more we consider internal imbalance
    let balanceFactor = 1.0 -. Math.abs(0.5 -. winProbability) *. 2.0
    1.0 -. (0.3 *. internalImbalanceFactor *. balanceFactor)
  }
  
  // Ensure multiplier stays within reasonable bounds [0.3, 1.5]
  Math.max(0.3, Math.min(1.5, multiplier))
}