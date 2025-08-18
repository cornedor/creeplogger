@react.component
let make = (
  ~show,
  ~setShow,
  ~setSelectedUsers: option<((Belt.Map.String.t<Players.team> => Belt.Map.String.t<Players.team>) => unit)>,
  ~setGameMode: option<((Games.gameMode => Games.gameMode) => unit)>,
  ~onMatchFound: option<(array<Players.player>, array<Players.player>, float) => unit>=?,
) => {
  let players = Players.useAllPlayers(~orderBy=#rating, ~asc=false)
  let stats = Stats.useStats()

  // Local selection state: map key -> selected
  let (selected, setSelected) = React.useState(_ => Belt.Map.String.empty)

  let toggleSelected = key =>
    setSelected(s => switch Belt.Map.String.get(s, key) {
      | Some(true) => Belt.Map.String.set(s, key, false)
      | _ => Belt.Map.String.set(s, key, true)
    })

  let clearSelection = () => setSelected(_ => Belt.Map.String.empty)

  // Convert key map to array of players
  let getSelectedPlayers = () => {
    let keys = Belt.Map.String.keep(selected, (_, v) => v == true)->Belt.Map.String.keysToArray
    let opts = keys->Array.map(key => Players.playerByKey(players, key))
    let filtered = opts->Array.filter(Option.isSome)
    filtered->Array.map(opt => opt->Option.getExn)
  }

  let playerToRating = (p: Players.player) => OpenSkill.playerToRating(p)

  // Compute best pairing for a given array of exactly 4 players
  let bestPairingOfFour = (ps: array<Players.player>) => {
    let p0 = Array.getUnsafe(ps, 0)
    let p1 = Array.getUnsafe(ps, 1)
    let p2 = Array.getUnsafe(ps, 2)
    let p3 = Array.getUnsafe(ps, 3)

    let pairs: array<((array<Players.player>, array<Players.player>), float)> = [
      (([p0, p1], [p2, p3]), {
        let teamA = [playerToRating(p0), playerToRating(p1)]
        let teamB = [playerToRating(p2), playerToRating(p3)]
        let p = OpenSkill.getWinProbability(teamA, teamB)
        Js.Math.abs_float(p -. 0.5)
      }),
      (([p0, p2], [p1, p3]), {
        let teamA = [playerToRating(p0), playerToRating(p2)]
        let teamB = [playerToRating(p1), playerToRating(p3)]
        let p = OpenSkill.getWinProbability(teamA, teamB)
        Js.Math.abs_float(p -. 0.5)
      }),
      (([p0, p3], [p1, p2]), {
        let teamA = [playerToRating(p0), playerToRating(p3)]
        let teamB = [playerToRating(p1), playerToRating(p2)]
        let p = OpenSkill.getWinProbability(teamA, teamB)
        Js.Math.abs_float(p -. 0.5)
      }),
    ]

    // Pick the pairing with minimum deviation from 0.5
    Array.reduce(pairs, Array.getUnsafe(pairs, 0), (best, cur) => {
      let (_, bestDev) = best
      let (_, curDev) = cur
      if curDev < bestDev { cur } else { best }
    })
  }

  // From N>=4 selected players, choose subset of 4 and pairing with minimal deviation
  let chooseBestMatch = (sel: array<Players.player>) => {
    let n = Array.length(sel)
    if n < 4 {
      None
    } else if n == 4 {
      let ((a, b), _dev) = bestPairingOfFour(sel)
      Some((a, b))
    } else {
      let best: ref<option<((array<Players.player>, array<Players.player>), float)>> = ref(None)
      for i in 0 to n - 4 {
        for j in i + 1 to n - 3 {
          for k in j + 1 to n - 2 {
            for l in k + 1 to n - 1 {
              let ps = [
                Array.getUnsafe(sel, i),
                Array.getUnsafe(sel, j),
                Array.getUnsafe(sel, k),
                Array.getUnsafe(sel, l),
              ]
              let ((a, b), dev) = bestPairingOfFour(ps)
              best.contents = switch best.contents {
              | None => Some(((a, b), dev))
              | Some((_, bestDev)) => if dev < bestDev { Some(((a, b), dev)) } else { best.contents }
              }
            }
          }
        }
      }
      switch best.contents { | Some((teams, _)) => Some(teams) | None => None }
    }
  }

  // Decide color assignment using global blue/red win bias
  let assignColors = (teamA: array<Players.player>, teamB: array<Players.player>) => {
    // Compute which team is stronger according to OpenSkill
    let pA = OpenSkill.getWinProbability(teamA->Array.map(playerToRating), teamB->Array.map(playerToRating))
    let teamAIsStronger = pA >= 0.5

    let total = stats.totalBlueWins + stats.totalRedWins
    let blueStronger = if total > 0 { Float.fromInt(stats.totalBlueWins) /. Float.fromInt(total) > 0.5 } else { false }

    // Assign stronger team to the historically stronger color
    switch (blueStronger, teamAIsStronger) {
    | (true, true) => (/*Blue*/ teamA, /*Red*/ teamB)
    | (true, false) => (/*Blue*/ teamB, /*Red*/ teamA)
    | (false, true) => (/*Blue*/ teamB, /*Red*/ teamA)
    | (false, false) => (/*Blue*/ teamA, /*Red*/ teamB)
    }
  }

  let makeMatch = () => {
    let selPlayers = getSelectedPlayers()
    switch chooseBestMatch(selPlayers) {
    | Some((teamA, teamB)) => {
        let (blueTeam, redTeam) = assignColors(teamA, teamB)

        // Apply to grid selection
        switch setSelectedUsers {
        | Some(setter) => setter(_ => {
            let empty = Belt.Map.String.empty
            let withBlue = Array.reduce(blueTeam, empty, (m, p) => Belt.Map.String.set(m, p.key, Players.Blue))
            let withRed = Array.reduce(redTeam, withBlue, (m, p) => Belt.Map.String.set(m, p.key, Players.Red))
            withRed
          })
        | None => ()
        }

        // Ensure Foosball mode
        switch setGameMode { | Some(setGM) => setGM(_ => Games.Foosball) | None => () }

        // Notify about match with win percentages for display
        let pBlue = OpenSkill.getWinProbability(
          blueTeam->Array.map(playerToRating),
          redTeam->Array.map(playerToRating),
        )
        switch onMatchFound { | Some(cb) => cb(blueTeam, redTeam, pBlue) | None => () }

        // Close and clear for next use
        clearSelection()
        setShow(s => !s)
      }
    | None => ()
    }
  }

  let numSelected = Belt.Map.String.keep(selected, (_, v) => v == true)->Belt.Map.String.size

  <div
    className="modal flex flex-col"
    style={ReactDOM.Style.make(~transform=show ? "translateX(0)" : "translateX(-100%)", ())}>
    <header className="flex items-center gap-4">
      <Button onClick={_ => setShow(s => !s)} variant={Blue}> {React.string("Terug")} </Button>
      <div className="flex-1" />
      <Button
        variant={Blue}
        onClick={_ => makeMatch()}
        disabled={numSelected < 4}>
        {React.string("Make a match")}
      </Button>
    </header>

    <h2 className="pt-5 mb-4 block text-2xl"> {React.string("Select players (min 4)")} </h2>
    <div className="text-white/70 mb-2"> {React.string("Selected: ")} {React.int(numSelected)} </div>

    <ul className="grid grid-cols-1 md:grid-cols-2 gap-2 overflow-auto">
      {React.array(
        players->Array.map(p => {
          let isSelected = switch Belt.Map.String.get(selected, p.key) { | Some(true) => true | _ => false }
          <li key={p.key} className="p-2 rounded border-white/20 border bg-white/5 flex justify-between items-center">
            <button className="text-left flex-1" onClick={_ => toggleSelected(p.key)}>
              <strong> {React.string(p.name)} </strong>
              <span className="ml-2 text-white/60"> {React.string(OpenSkillRating.toDisplayOrdinal(p.ordinal)->Int.toString)} </span>
            </button>
            <input
              ariaLabel={p.name}
              className="w-5 h-5"
              type_="checkbox"
              checked={isSelected}
              onChange={_ => toggleSelected(p.key)}
            />
          </li>
        })
      )}
    </ul>

    <div className="mt-4 flex gap-2">
      <Button variant={Grey} onClick={_ => clearSelection()}> {React.string("Clear")} </Button>
    </div>
  </div>
}