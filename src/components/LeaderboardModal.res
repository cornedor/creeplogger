@react.component
let make = (~show, ~setShow, ~gameMode, ~setGameMode) => {
  let (ascOrder, setOrder) = React.useState(_ => false)
  let players = Players.useAllPlayers(
    ~orderBy=gameMode == Games.Darts ? #dartsElo : #rating,
    ~asc=ascOrder,
  )

  let position = ref(0)
  let previousScore = ref(0)
  let skipped = ref(0)

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
            className="text-white w-[44px] aspect-square text-[26px] flex justify-center items-center rounded-full bg-black/0 transition-all ease-in-out duration-200 shadow-none hover:bg-black/20 hover:shadow-icon-button hover:ring-8 ring-black/20 active:bg-black/20 active:shadow-icon-button active:ring-8"
            onClick={_ => setGameMode(_ => Games.Darts)}>
            <SoccerIcon />
          </button>
        | Games.Darts =>
          <button
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
          <th className="text-lg text-left">
            <button onClick={_ => setOrder(order => !order)}>
              {React.string("Score " ++ (ascOrder ? "↑" : "↓"))}
            </button>
          </th>
          <th className="text-lg text-left"> {React.string("Last 5")} </th>
          <th className="text-lg text-left"> {React.string("G/W")} </th>
          <th className="text-lg text-left"> {React.string("Win%")} </th>
        </tr>
      </thead>
      <tbody>
        {players
        ->Array.filter(player => {
          let isHidden = switch player.hidden {
          | Some(true) => false
          | Some(false) => true
          | None => true
          }

          let (playerRating, games) = switch gameMode {
          | Games.Darts => (player.dartsElo, player.dartsGames)
          | _ => (player.ordinal, player.games)
          }

          let isLowGameCount = games > 5
          let isLowRating = playerRating > 0.0

          isHidden && isLowGameCount && isLowRating
        })
        ->Array.map(player => {
          let (displayScore, lastChange, lastGames, wins, games) = switch gameMode {
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
          let roundedScore = OpenSkillRating.roundScore(displayScore)

          // When the scores are the same, both players get the same position
          // The next player will continue the count as if no position was skipped.
          switch (roundedScore, previousScore.contents, skipped.contents) {
          | (a, b, _) if a == b =>
            // Previous score was the same as the current score, so we skip the position
            skipped := skipped.contents + 1
          | (_, _, s) if s > 0 =>
            // We skipped a position, so we continue the count
            position := position.contents + skipped.contents + 1
            skipped := 0
          | (_, _, _) => position := position.contents + 1
          }
          previousScore := roundedScore

          <tr key={player.key}>
            <td className="font-semibold">
              {React.string(`${position.contents->Int.toString}`)}
            </td>
            <td> {React.string(player.name)} </td>
            <td>
              {React.int(roundedScore)}
              {React.string(" ")}
              {switch gameMode {
              | Games.Darts =>
                <small className={lastChange > 0.0 ? "text-green-400" : "text-red-400"}>
                  {React.int(Elo.roundScore(lastChange))}
                </small>
              | Games.Foosball =>
                <small
                  title={`Elo: ${player.elo->Float.toInt->Int.toString}`}
                  className={lastChange > 0.0 ? "text-green-400" : "text-red-400"}>
                  {React.int(OpenSkillRating.roundScore(lastChange))}
                </small>
              }}
            </td>
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
            <td>
              {React.int(games)}
              {React.string(":")}
              {React.int(wins)}
            </td>
            <td>
              {React.float((Float.fromInt(wins) /. Float.fromInt(games) *. 100.)->Math.round)}
              {React.string("%")}
            </td>
          </tr>
        })
        ->React.array}
      </tbody>
    </table>
  </div>
}
