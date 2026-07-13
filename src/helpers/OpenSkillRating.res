// OpenSkill rating system to replace Elo calculations for Foosball

type team = array<Players.player>

@inline
let getOpenSkillRating = (player: Players.player, ~gameMode: Games.gameMode=Games.Foosball) =>
  switch gameMode {
  | Games.Fifa => OpenSkill.createRating(~mu=player.fifaMu, ~sigma=player.fifaSigma, ())
  | _ => OpenSkill.createRating(~mu=player.mu, ~sigma=player.sigma, ())
  }

@inline
let calculateOrdinal = (mu: float, sigma: float) => mu -. 3.0 *. sigma

// Convert team of players to array of OpenSkill ratings
let teamToRatings = (team: team, ~gameMode: Games.gameMode=Games.Foosball) =>
  Array.map(team, player => getOpenSkillRating(player, ~gameMode))

// A 7-0 creep says more about the players than a 7-6 nail-biter, so the skill update is
// scaled by the goal difference: 1.0x for a single goal up to 1.5x for a 7 goal creep.
let marginMultiplier = (scoreDiff: int) => {
  let diff = abs(scoreDiff)->Int.clamp(~min=1, ~max=7)->Int.toFloat
  1.0 +. (diff -. 1.0) /. 6.0 *. 0.5
}

// Scale how far the skill estimate moves, but leave sigma exactly as OpenSkill calculated
// it so uncertainty keeps converging at its own pace.
let applyMargin = (
  previous: OpenSkill.rating,
  next: OpenSkill.rating,
  multiplier: float,
): OpenSkill.rating => {
  mu: previous.mu +. (next.mu -. previous.mu) *. multiplier,
  sigma: next.sigma,
}

// Update a player with new OpenSkill values
let updatePlayerRating = (
  player: Players.player,
  newRating: OpenSkill.rating,
  ~gameMode: Games.gameMode=Games.Foosball,
) => {
  let newOrdinal = calculateOrdinal(newRating.mu, newRating.sigma)

  switch gameMode {
  | Games.Fifa => {
      let osDelta = newOrdinal -. player.fifaOrdinal
      {
        ...player,
        fifaMu: newRating.mu,
        fifaSigma: newRating.sigma,
        fifaOrdinal: newOrdinal,
        fifaLastOpenSkillChange: osDelta,
      }
    }
  | _ => {
      let osDelta = newOrdinal -. player.ordinal
      {
        ...player,
        mu: newRating.mu,
        sigma: newRating.sigma,
        ordinal: newOrdinal,
        lastOpenSkillChange: osDelta,
      }
    }
  }
}

// Scale OpenSkill values to a familiar 1500-based display
@inline
let displayBase = 1500

@inline
let displayScale = 60.0

@inline
let toDisplayOrdinal = (ordinal: float) =>
  displayBase + (ordinal *. displayScale)->Js.Math.round->Float.toInt

@inline
let toDisplayDelta = (delta: float) => (delta *. displayScale)->Js.Math.round->Float.toInt

// Calculate new ratings for both teams after a game
// Returns (updated winners, updated losers, points change for display)
let calculateScore = (
  winners: team,
  losers: team,
  ~scoreDiff: int,
  ~gameMode: Games.gameMode=Games.Foosball,
) =>
  // A game without an opponent cannot be rated: OpenSkill happily hands out points for
  // beating an empty team.
  if Array.length(winners) == 0 || Array.length(losers) == 0 {
    (winners, losers, 0.0)
  } else {
    // Convert teams to OpenSkill ratings
    let winnerRatings = teamToRatings(winners, ~gameMode)
    let loserRatings = teamToRatings(losers, ~gameMode)

    // Calculate new ratings
    let (newWinnerRatings, newLoserRatings) = OpenSkill.rateGame(winnerRatings, loserRatings)
    let multiplier = marginMultiplier(scoreDiff)

    // Update players with new ratings
    let updatedWinners = Array.mapWithIndex(winners, (player, index) => {
      let newRating = applyMargin(
        Array.getUnsafe(winnerRatings, index),
        Array.getUnsafe(newWinnerRatings, index),
        multiplier,
      )
      updatePlayerRating(player, newRating, ~gameMode)
    })

    let updatedLosers = Array.mapWithIndex(losers, (player, index) => {
      let newRating = applyMargin(
        Array.getUnsafe(loserRatings, index),
        Array.getUnsafe(newLoserRatings, index),
        multiplier,
      )
      updatePlayerRating(player, newRating, ~gameMode)
    })

    // Calculate average rating change for display (using OpenSkill delta)
    let avgWinnerChange = switch gameMode {
    | Games.Fifa =>
      Array.reduce(updatedWinners, 0.0, (acc, player) => acc +. player.fifaLastOpenSkillChange) /.
      Int.toFloat(Array.length(updatedWinners))
    | _ =>
      Array.reduce(updatedWinners, 0.0, (acc, player) => acc +. player.lastOpenSkillChange) /.
      Int.toFloat(Array.length(updatedWinners))
    }

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
