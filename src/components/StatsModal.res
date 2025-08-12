type point = {time: float, score: int}

@react.component
let make = (~show, ~setShow) => {
  let stats = Stats.useStats()
  let (daysWithoutName, daysWithoutDate) = DaysWithout.useDaysWithout()

  let daysSince = DateFns.differenceInDays(Date.make(), daysWithoutDate)

  let blue = Float.fromInt(stats.totalBlueWins)
  let red = Float.fromInt(stats.totalRedWins)

  let bluePercentages = (blue /. (blue +. red) *. 100.)->Float.toString

  let (playersForChart, setPlayersForChart) = React.useState(_ => [])
  let (seriesByPlayer, setSeriesByPlayer) = React.useState(_ => Js.Dict.empty())
  let (selectedPlayerKeys, setSelectedPlayerKeys) = React.useState(_ => [])
  let (isLoadingChart, setIsLoadingChart) = React.useState(_ => false)
  let (hasLoadedOnce, setHasLoadedOnce) = React.useState(_ => false)

  // Compute OpenSkill progression when modal opens
  React.useEffect(() => {
    if show && !hasLoadedOnce {
      setIsLoadingChart(_ => true)
      let _ = Games.fetchAllGames()->Promise.then(games => {
        Players.fetchAllPlayers()->Promise.then(playersDict => {
          // Prepare player list and reset ratings like recalculate
          let playersArray = Dict.keysToArray(playersDict)->Array.map(key => Dict.get(playersDict, key)->Option.getExn)
          // Sort by current rating (ordinal) desc
          let sortedPlayers = playersArray->Array.toSorted((a, b) => b.ordinal -. a.ordinal)

          // Default selected: top 5 by rating
          let defaultSelected = sortedPlayers->Array.slice(~start=0, ~end=5)->Array.map(p => p.key)

          // Build a working map of players with reset OpenSkill values
          let workingPlayers = Js.Dict.empty()
          Array.forEach(playersArray, p => {
            Js.Dict.set(workingPlayers, p.key, {
              ...p,
              mu: 25.0,
              sigma: 8.333,
              ordinal: 0.0,
              lastOpenSkillChange: 0.0,
            })
          })

          // Sort games chronologically by date (using timestamp)
          let orderedGames = games->Array.toSorted((a, b) => Date.getTime(a.date) -. Date.getTime(b.date))

          // Series store: playerKey -> array<point>
          let seriesMap: Js.Dict.t<array<point>> = Js.Dict.empty()

          Array.forEach(orderedGames, game => {
            // Determine winner/loser teams
            let blueWin = Rules.isBlueWin(game.redScore, game.blueScore)

            // Pull current player states
            let redPlayers = game.redTeam->Array.map(key => Js.Dict.get(workingPlayers, key)->Option.getExn)
            let bluePlayers = game.blueTeam->Array.map(key => Js.Dict.get(workingPlayers, key)->Option.getExn)

            let (newBlue, newRed, _points) = switch blueWin {
            | true => OpenSkillRating.calculateScore(bluePlayers, redPlayers, ~gameMode=Games.Foosball)
            | false => {
                let (r, b, points) = OpenSkillRating.calculateScore(redPlayers, bluePlayers, ~gameMode=Games.Foosball)
                (b, r, points)
              }
            }

            // Update working players and append to series with display scores
            let time = Date.getTime(game.date)
            Array.forEach(newBlue, player => {
              Js.Dict.set(workingPlayers, player.key, player)
              let score = OpenSkillRating.toDisplayOrdinal(player.ordinal)
              let prev: array<point> = Js.Dict.get(seriesMap, player.key)->Belt.Option.getWithDefault([])
              let next: array<point> = Array.concat(prev, [{time: time, score: score}])
              Js.Dict.set(seriesMap, player.key, next)
            })
            Array.forEach(newRed, player => {
              Js.Dict.set(workingPlayers, player.key, player)
              let score = OpenSkillRating.toDisplayOrdinal(player.ordinal)
              let prev: array<point> = Js.Dict.get(seriesMap, player.key)->Belt.Option.getWithDefault([])
              let next: array<point> = Array.concat(prev, [{time: time, score: score}])
              Js.Dict.set(seriesMap, player.key, next)
            })
          })

          setSeriesByPlayer(_ => seriesMap)
          setPlayersForChart(_ => sortedPlayers)
          setSelectedPlayerKeys(_ => defaultSelected)
          setIsLoadingChart(_ => false)
          setHasLoadedOnce(_ => true)
          Promise.resolve(())
        })
      })
    }
    None
  }, [show, hasLoadedOnce])

  // Helpers for SVG chart rendering
  let chartWidth = 720.0
  let chartHeight = 260.0
  let margin = 24.0

  // Hovered series key for tooltip
  let (hoverKey, setHoverKey) = React.useState(_ => None)

  let getDomain = () => {
    let times: array<float> = []
    let scores: array<float> = []
    Js.Dict.keys(seriesByPlayer)->Array.forEach(key => {
      let arr = Js.Dict.get(seriesByPlayer, key)->Option.getExn
      Array.forEach(arr, p => {
        let _ = Js.Array2.push(times, p.time)
        let _ = Js.Array2.push(scores, Float.fromInt(p.score))
      })
    })
    if Array.length(times) == 0 {
      (0.0, 1.0, 0.0, 1.0)
    } else {
      let initT = Array.getUnsafe(times, 0)
      let minT = Array.reduce(times, initT, (acc, v) => if v < acc {v} else {acc})
      let maxT = Array.reduce(times, initT, (acc, v) => if v > acc {v} else {acc})
      let initS = Array.getUnsafe(scores, 0)
      let minS = Array.reduce(scores, initS, (acc, v) => if v < acc {v} else {acc})
      let maxS = Array.reduce(scores, initS, (acc, v) => if v > acc {v} else {acc})
      (minT, maxT, minS, maxS)
    }
  }

  let (minT, maxT, minS, maxS) = getDomain()
  let spanT = if maxT -. minT == 0.0 {1.0} else {maxT -. minT}
  let spanS = if maxS -. minS == 0.0 {1.0} else {maxS -. minS}

  let scaleX = t => margin +. ((t -. minT) /. spanT *. (chartWidth -. 2.0 *. margin))
  let scaleY = s => (chartHeight -. margin) -. ((Float.fromInt(s) -. minS) /. spanS *. (chartHeight -. 2.0 *. margin))

  let buildPath = (points: array<point>) => {
    switch points->Array.length {
    | 0 => ""
    | _ => {
        let (_, acc) = points->Array.reduceWithIndex((true, ""), (acc, p, i) => {
          let (isFirst, str) = acc
          let x = scaleX(p.time)
          let y = scaleY(p.score)
          if isFirst {
            (false, "M " ++ Js.Float.toString(x) ++ " " ++ Js.Float.toString(y))
          } else {
            (false, str ++ " L " ++ Js.Float.toString(x) ++ " " ++ Js.Float.toString(y))
          }
        })
        acc
      }
    }
  }

  let renderSeriesWithColor = (key: string, color: string) => {
    switch Js.Dict.get(seriesByPlayer, key) {
    | None => React.null
    | Some(points) => {
        let lines = points->Array.mapWithIndex((p, i) => {
          if i == 0 {
            React.null
          } else {
            let prev = Array.getUnsafe(points, i - 1);
            <line
              key={Js.Int.toString(i)}
              x1={Js.Float.toString(scaleX(prev.time))}
              y1={Js.Float.toString(scaleY(prev.score))}
              x2={Js.Float.toString(scaleX(p.time))}
              y2={Js.Float.toString(scaleY(p.score))}
              stroke={color}
              strokeWidth="2"
            />
          }
        });
        <g
          key={key}
          onMouseEnter={_ => setHoverKey(_ => Some(key))}
          onMouseLeave={_ => setHoverKey(_ => None)}>
          {React.array(lines)}
        </g>
      }
    }
  }

  // Simple color palette cycling by index without using mod directly
  let getColorByIndex = idx => {
    let rec normalize = i => if i < 10 { i } else { normalize(i - 10) };
    let i10 = normalize(idx);
    switch i10 {
    | 0 => "#60a5fa"
    | 1 => "#f472b6"
    | 2 => "#34d399"
    | 3 => "#f59e0b"
    | 4 => "#a78bfa"
    | 5 => "#fb7185"
    | 6 => "#22d3ee"
    | 7 => "#fde047"
    | 8 => "#4ade80"
    | _ => "#f97316"
    }
  }
  let renderSeriesWithIndexColor = (key: string, idx: int) =>
    renderSeriesWithColor(key, getColorByIndex(idx))

  // Selection handling (toggle on option click)
  let isSelected = (key, sel) => sel->Array.some(v => v == key)
  let toggleSelection = key => {
    setSelectedPlayerKeys(sel => {
      if isSelected(key, sel) {
        Belt.Array.keep(sel, v => v != key)
      } else {
        Array.concat(sel, [key])
      }
    })
  }

  <div
    className="modal flex flex-col"
    style={ReactDOM.Style.make(~transform=show ? "translateX(0)" : "translateX(-100%)", ())}>
    <header>
      <Button onClick={_ => setShow(s => !s)} variant={Blue}> {React.string("Terug")} </Button>
    </header>
    <h2 className="pt-5 mb-4 block text-2xl"> {React.string("Foosball")} </h2>
    <ul className="grid grid-cols-2 gap-2">
      <li className="p-2 rounded border-white/20 border bg-white/5 flex justify-between">
        <strong> {React.string("Total games: ")} </strong>
        <span> {React.int(stats.totalGames)} </span>
      </li>
      <li className="p-2 rounded border-white/20 border bg-white/5 flex justify-between">
        <strong> {React.string("Blue wins: ")} </strong>
        <span> {React.int(stats.totalBlueWins)} </span>
      </li>
      <li className="p-2 rounded border-white/20 border bg-white/5 flex justify-between">
        <strong> {React.string("Red wins: ")} </strong>
        <span> {React.int(stats.totalRedWins)} </span>
      </li>
      <li className="p-2 rounded border-white/20 border bg-white/5 flex justify-between">
        <strong> {React.string("7-0's: ")} </strong>
        <span> {React.int(stats.totalAbsoluteWins)} </span>
      </li>
    </ul>
    <div>
      <div
        className="rounded-full aspect-square w-[300px] my-4 mx-auto shadow-inner shadow-orange-50"
        style={ReactDOM.Style.make(
          ~background=`conic-gradient(#86b7ff, #1c77ff ${bluePercentages}%, #ff3e6e ${bluePercentages}%, #ff0055)`,
          (),
        )}
      />
    </div>
    <hr />

    <div className="mt-6">
      <h3 className="mb-2 block text-xl"> {React.string("OpenSkill progression")} </h3>
      <div className="rounded border border-white/20 bg-white/5 p-3 relative">
        {switch hoverKey {
        | Some(k) => {
            let name = switch playersForChart->Array.find(p => p.key == k) {
            | Some(p) => p.name
            | None => k
            }
            let idx = Belt.Array.getIndexBy(selectedPlayerKeys, kk => kk == k)->Belt.Option.getWithDefault(0)
            let color = getColorByIndex(idx)
            <div className="absolute top-2 right-2 px-2 py-1 rounded bg-black/60 text-white text-xs flex items-center gap-2">
              <span style={ReactDOM.Style.make(~backgroundColor=color, ())} className="inline-block w-2 h-2 rounded-full" />
              {React.string(name)}
            </div>
          }
        | None => React.null
        }}
        {(switch (isLoadingChart, Array.length(playersForChart)) {
        | (true, _) => <div className="text-center py-8 opacity-70"> {React.string("Loading chart...")} </div>
        | (false, 0) => <div className="text-center py-8 opacity-70"> {React.string("No data") } </div>
        | (false, _) =>
          <svg
            width={Js.Int.toString(chartWidth->Js.Math.round->Belt.Float.toInt)}
            height={Js.Int.toString(chartHeight->Js.Math.round->Belt.Float.toInt)}
            viewBox={"0 0 " ++ Js.Int.toString(chartWidth->Js.Math.round->Belt.Float.toInt) ++ " " ++ Js.Int.toString(chartHeight->Js.Math.round->Belt.Float.toInt)}
            preserveAspectRatio="none"
            className="w-full h-64">
            <line x1={Js.Float.toString(margin)} y1={Js.Float.toString(chartHeight -. margin)} x2={Js.Float.toString(chartWidth -. margin)} y2={Js.Float.toString(chartHeight -. margin)} stroke="#ffffff22" strokeWidth="1" />
            <line x1={Js.Float.toString(margin)} y1={Js.Float.toString(margin)} x2={Js.Float.toString(margin)} y2={Js.Float.toString(chartHeight -. margin)} stroke="#ffffff22" strokeWidth="1" />

            {selectedPlayerKeys->Array.mapWithIndex((key, idx) => renderSeriesWithIndexColor(key, idx))->React.array}
          </svg>
        })}
      </div>
      <div className="mt-3">
        <label className="block mb-2 text-sm opacity-80"> {React.string("Players to show (multi-select)")} </label>
        <select multiple=true className="w-full bg-white/5 border border-white/20 rounded p-2 min-h-[140px]">
          {playersForChart->Array.map(p => {
            let sel = selectedPlayerKeys->Array.some(k => k == p.key)
            <option
              key={p.key}
              value={p.key}
              selected={sel}
              onClick={_ => toggleSelection(p.key)}>
              {React.string(p.name)}
            </option>
          })->React.array}
        </select>
      </div>
    </div>

    <div>
      <h2 className="pt-5 mb-4 block text-2xl"> {React.string("Darts")} </h2>
      <ul className="grid grid-cols-2 gap-2">
        <li className="p-2 rounded border-white/20 border bg-white/5 flex justify-between">
          <strong> {React.string("Total games: ")} </strong>
          <span> {React.int(stats.totalDartsGames)} </span>
        </li>
      </ul>
      <br />
    </div>
    <hr />
    <div className="flex justify-center items-center flex-col gap-2">
      <h2 className="pt-5 text-3xl text-center"> {React.string(daysWithoutName)} </h2>
      <div className="text-[160px] font-handwritten"> {React.string(Int.toString(daysSince))} </div>
      <Button
        variant={Blue}
        onClick={_ => {
          let _ = DaysWithout.reset()
        }}>
        {React.string("Reset")}
      </Button>
    </div>
    <div className="flex-1" />
    <div>
      <a href="https://github.com/cornedor/creeplogger"> {React.string("Contribute on GitHub")} </a>
    </div>
  </div>
}
