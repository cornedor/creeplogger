// ReScript bindings for the openskill npm package

type rating = {
  mu: float,
  sigma: float,
}

// External bindings for the openskill JavaScript library
@module("openskill") external rating: unit => rating = "rating"
@module("openskill") external ratingWithValues: {.."mu": float, "sigma": float} => rating = "rating"

@module("openskill") external rate: array<array<rating>> => array<array<rating>> = "rate"

@module("openskill") external ordinal: rating => float = "ordinal"

@module("openskill") external predictWin: array<array<rating>> => array<float> = "predictWin"

// Helper functions for creating and working with ratings

@inline
let createRating = (~mu=25.0, ~sigma=8.333, ()) => ratingWithValues({"mu": mu, "sigma": sigma})

@inline
let defaultRating = () => rating()

@inline
let getOrdinal = rating => ordinal(rating)

// OpenSkill reads a team's strength as the sum of its players, so in a 1v2 the solo
// player appears to be up against an opponent of double their own strength: they are
// given a 0.01% chance of winning, gain a lot for a win and lose almost nothing for a
// loss. Repeating the smaller team's players until both sides fill the same number of
// slots puts the two teams on equal footing. The repeated copies are identical, so they
// get an identical update and the originals can be read straight back out of the result.
let padTeam = (team: array<rating>, size: int) => {
  let count = Array.length(team)
  if count == 0 || count >= size {
    team
  } else {
    Array.fromInitializer(~length=size, index => Array.getUnsafe(team, mod(index, count)))
  }
}

let balanceTeams = (teamA: array<rating>, teamB: array<rating>) => {
  let size = max(Array.length(teamA), Array.length(teamB))
  (padTeam(teamA, size), padTeam(teamB, size))
}

// Calculate new ratings after a game
let rateGame = (winningTeam: array<rating>, losingTeam: array<rating>) => {
  let winnerCount = Array.length(winningTeam)
  let loserCount = Array.length(losingTeam)
  let (paddedWinners, paddedLosers) = balanceTeams(winningTeam, losingTeam)

  switch rate([paddedWinners, paddedLosers]) {
  | [winnerUpdates, loserUpdates] => (
      winnerUpdates->Array.slice(~start=0, ~end=winnerCount),
      loserUpdates->Array.slice(~start=0, ~end=loserCount),
    )
  | _ => panic("Unexpected result from rate function")
  }
}

// Calculate win probability between two teams
let getWinProbability = (teamA: array<rating>, teamB: array<rating>) => {
  let (paddedA, paddedB) = balanceTeams(teamA, teamB)
  let probabilities = predictWin([paddedA, paddedB])
  Array.getUnsafe(probabilities, 0) // Return probability for first team
}

// Convert player to OpenSkill rating
let playerToRating = (player: Players.player) => {
  createRating(~mu=player.mu, ~sigma=player.sigma, ())
}
