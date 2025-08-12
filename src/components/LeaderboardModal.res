@react.component
let make = (~show, ~setShow, ~gameMode, ~setGameMode) => {
  let (ascOrder, setOrder) = React.useState(_ => false)
  let players = Players.useAllPlayers(
    ~orderBy=gameMode == Games.Darts ? #dartsElo : #rating,
    ~asc=ascOrder,
  )

  // Prepare filtered, visible players once
  let visiblePlayers: array<Players.player> = React.useMemo(() =>
    players
    ->Array.filter(player => {
      let (_, games) = switch gameMode {
      | Games.Darts => (player.dartsElo, player.dartsGames)
      | _ => (player.ordinal, player.games)
      }

      let isVisible = switch player.hidden {
      | Some(true) => false
      | Some(false) => true
      | None => true
      }

      let hasEnoughGames = games > 5
      isVisible && hasEnoughGames
    })
  , (players, gameMode))

  // Helpers to get current and previous comparison values per mode
  let getCurrentCompareValue = (player: Players.player) =>
    switch gameMode {
    | Games.Darts => Elo.roundScore(player.dartsElo)
    | Games.Foosball => OpenSkillRating.toDisplayOrdinal(player.ordinal)
    }

  let getPreviousCompareValue = (player: Players.player) =>
    switch gameMode {
    | Games.Darts => Elo.roundScore(player.dartsElo -. player.dartsLastEloChange)
    | Games.Foosball => OpenSkillRating.toDisplayOrdinal(player.ordinal -. player.lastOpenSkillChange)
    }

  // Compute position maps (key -> rank) with tie handling
  let computePositions = (arr: array<Players.player>, getValue: Players.player => int) => {
    let posByKey: Js.Dict.t<int> = Js.Dict.empty()
    let position = ref(0)
    let skipped = ref(0)
    let previousValue: ref<option<int>> = ref(None)

    Array.forEach(arr, player => {
      let value = getValue(player)
      switch previousValue.contents {
      | Some(prev) when prev == value => skipped := skipped.contents + 1
      | Some(_prev) when skipped.contents > 0 => {
          position := position.contents + skipped.contents + 1
          skipped := 0
        }
      | _ => position := position.contents + 1
      }
      previousValue := Some(value)
      Js.Dict.set(posByKey, player.key, position.contents)
    })

    posByKey
  }

  // Current positions follow the already sorted order in visiblePlayers
  let currentPositions = React.useMemo(() => computePositions(visiblePlayers, getCurrentCompareValue), (visiblePlayers, gameMode))

  // Previous positions: sort by previous compare value with same asc/desc
  let previousPositions = React.useMemo(() => {
    let sortedPrev = visiblePlayers->Array.toSorted((a, b) => {
      let (a1, b1) = ascOrder ? (a, b) : (b, a)
      Int.toFloat(getPreviousCompareValue(a1) - getPreviousCompareValue(b1))
    })
    computePositions(sortedPrev, getPreviousCompareValue)
  }, (visiblePlayers, ascOrder, gameMode))

  // Helper for formatting floats to 2 decimals
  let round2 = v => (v *. 100.0)->Js.Math.round /. 100.0

  <div
    className="modal"
    style={ReactDOM.Style.make(~transform=show ? "translateX(0)" : "translateX(-100%)", ())}>
    <header className="flex items-center gap-5">
      <Button onClick={_ => setShow(s => !s)} variant={Blue}> {React.string("Terug")} </Button>
      {switch setGameMode {
      | Some(setGameMode) =>
        switch gameMode {
        | Games.Foosball =>
          <button
            ariaLabel="Switch to Darts leaderboard"
            className="text-white w-[44px] aspect-square text-[26px] flex justify-center items-center rounded-full bg-black/0 transition-all ease-in-out duration-200 shadow-none hover:bg-black/20 hover:shadow-icon-button hover:ring-8 ring-black/20 active:bg-black/20 active:shadow-icon-button active:ring-8"
            onClick={_ => setGameMode(_ => Games.Darts)}>
            <SoccerIcon />
          </button>
        | Games.Darts =>
          <button
            ariaLabel="Switch to Foosball leaderboard"
            className="text-white w-[44px] aspect-square text-[26px] flex justify-center items-center rounded-full bg-black/0 transition-all ease-in-out duration-200 shadow-none hover:bg-black/20 hover:shadow-icon-button hover:ring-8 ring-black/20 active:bg-black/20 active:shadow-icon-button active:ring-8"
            onClick={_ => setGameMode(_ => Games.Foosball)}>
            <DartsIcon />
          </button>
        }
      | None => React.null
      }}
    </header>
    <table className="table-fixed w-full mt-8">
      <thead>
        <tr>
          <th className="text-lg text-left" style={ReactDOM.Style.make(~width="40px", ())}>
            {React.string("#")}
          </th>
          <th className="text-lg text-left"> {React.string("Speler")} </th>
          {switch gameMode {
          | Games.Foosball =>
            <>
              <th className="text-lg text-left">
                <button ariaLabel="Toggle sort order" onClick={_ => setOrder(order => !order)}>
                  {React.string("Score " ++ (ascOrder ? "↑" : "↓"))}
                </button>
              </th>
              <th className="text-lg text-left"> {React.string("Δ")} </th>
            </>
          | Games.Darts =>
            <>
              <th className="text-lg text-left">
                <button ariaLabel="Toggle sort order" onClick={_ => setOrder(order => !order)}>
                  {React.string("Elo " ++ (ascOrder ? "↑" : "↓"))}
                </button>
              </th>
              <th className="text-lg text-left"> {React.string("Δ")} </th>
            </>
          }}
          <th className="text-lg text-left"> {React.string("Last 5")} </th>
          <th className="text-lg text-left hidden min-[1200px]:table-cell"> {React.string("G/W")} </th>
          <th className="text-lg text-left hidden min-[1200px]:table-cell"> {React.string("Win%")} </th>
        </tr>
      </thead>
      <tbody>
        {visiblePlayers
        ->Array.map(player => {
          let (_, _lastChange, lastGames, wins, games) = switch gameMode {
          | Games.Darts => (
              player.dartsElo,
              player.dartsLastEloChange,
              player.dartsLastGames,
              player.dartsWins,
              player.dartsGames,
            )
          | Games.Foosball => (
              player.ordinal,
              player.lastOpenSkillChange,
              player.lastGames,
              player.wins,
              player.games,
            )
          }

          // Derive current and previous positions
          let currentPos = Js.Dict.get(currentPositions, player.key)->Option.getOr(0)
          let previousPos = Js.Dict.get(previousPositions, player.key)->Option.getOr(currentPos)
          let delta = previousPos - currentPos
          let deltaAbs = abs(delta)
          let deltaColor = delta == 0 ? "text-gray-400" : delta > 0 ? "text-green-400" : "text-red-400"

          <tr key={player.key}>
            <td className="font-semibold">
              {React.string(`${currentPos->Int.toString}`)}
            </td>
            <td> {React.string(player.name)} </td>
            {switch gameMode {
            | Games.Darts =>
              <>
                <td> {React.int(Elo.roundScore(player.dartsElo))} </td>
                <td>
                  <small className={deltaColor}>
                    {delta == 0 ? React.string("-") : React.int(deltaAbs)}
                  </small>
                </td>
              </>
            | Games.Foosball =>
              <>
                <td title={"μ=" ++ round2(player.mu)->Js.Float.toString ++ " σ=" ++ round2(player.sigma)->Js.Float.toString ++ " ELO=" ++ round2(player.elo)->Js.Float.toString}>
                  {React.float(round2(player.ordinal))}
                </td>
                <td>
                  <small className={deltaColor}>
                    {delta == 0 ? React.string("-") : React.int(deltaAbs)}
                  </small>
                </td>
              </>
            }}
            <td>
              <div className="inline-flex gap-1 w-9">
                {lastGames
                ->Array.mapWithIndex((win, i) =>
                  <span
                    className={"w-1 h-1 rounded block " ++ (
                      win == 1 ? "bg-green-400" : "bg-red-400"
                    )}
                    key={i->Int.toString}
                  />
                )
                ->React.array}
              </div>
            </td>
            <td className="hidden min-[1200px]:table-cell">
              {React.int(games)}
              {React.string(":")}
              {React.int(wins)}
            </td>
            <td className="hidden min-[1200px]:table-cell">
              {React.float((games > 0 ? (Float.fromInt(wins) /. Float.fromInt(games) *. 100.) : 0.0)->Math.round)}
              {React.string("%")}
            </td>
          </tr>
        })
        ->React.array}
      </tbody>
    </table>
  </div>
}
