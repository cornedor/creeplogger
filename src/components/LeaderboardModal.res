@react.component
let make = (~show, ~setShow) => {
  let (order, setOrder) = React.useState(_ => true)
  let players = Players.useAllPlayers(~orderBy=#elo, ~asc=order)

  let position = ref(0)
  let previousScore = ref(0)
  let skipped = ref(0)

  <div
    className="modal"
    style={ReactDOM.Style.make(~transform=show ? "translateX(0)" : "translateX(-100%)", ())}>
    <header>
      <Button onClick={_ => setShow(s => !s)} variant={Blue}> {React.string("Terug")} </Button>
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
              {React.string("Score " ++ (order ? "↑" : "↓"))}
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

          let isLowGameCount = player.games > 0
          let isLowElo = player.elo > 0.0

          isHidden && isLowGameCount && isLowElo
        })
        ->Array.map(player => {
          let roundedElo = Elo.roundScore(player.elo)

          // When the scores are the same, both players get the same position
          // The next player will continue the count as if no position was skipped.
          switch (roundedElo, previousScore.contents, skipped.contents) {
          | (a, b, _) if a == b =>
            // Previous score was the same as the current score, so we skip the position
            skipped := skipped.contents + 1
          | (_, _, s) if s > 0 =>
            // We skipped a position, so we continue the count
            position := position.contents + skipped.contents + 1
            skipped := 0
          | (_, _, _) => position := position.contents + 1
          }
          previousScore := roundedElo

          <tr key={player.key}>
            <td className="font-semibold">
              {React.string(`${position.contents->Int.toString}`)}
            </td>
            <td> {React.string(player.name)} </td>
            <td>
              {React.int(roundedElo)}
              {React.string(" ")}
              <small className={player.lastEloChange > 0.0 ? "text-green-400" : "text-red-400"}>
                {React.int(Elo.roundScore(player.lastEloChange))}
              </small>
            </td>
            <td>
              <div className="inline-flex gap-1 w-9">
                {player.lastGames
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
              {React.int(player.games)}
              {React.string(":")}
              {React.int(player.wins)}
            </td>
            <td>
              {React.float(
                (Float.fromInt(player.wins) /. Float.fromInt(player.games) *. 100.)->Math.round,
              )}
              {React.string("%")}
            </td>
          </tr>
        })
        ->React.array}
      </tbody>
    </table>
  </div>
}
