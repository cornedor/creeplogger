@react.component
let make = (~show, ~setShow) => {
  let (order, setOrder) = React.useState(_ => true)
  let players = Players.useAllPlayers(~orderBy=#elo, ~asc=order)

  let position = ref(0)
  let previousScore = ref(0)

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
          <th className="text-lg text-left"> {React.string("Groei")} </th>
          <th className="text-lg text-left"> {React.string("G/W")} </th>
        </tr>
      </thead>
      <tbody>
        {players
        ->Array.map(player => {
          let roundedElo = Elo.roundScore(player.elo)
          if roundedElo != previousScore.contents {
            position := position.contents + 1
          }
          previousScore := roundedElo

          <tr key={player.key}>
            <td className="font-semibold">
              {React.string(`${position.contents->Int.toString}`)}
            </td>
            <td> {React.string(player.name)} </td>
            <td> {React.int(roundedElo)} </td>
            <td className={player.lastEloChange > 0.0 ? "text-green-400" : "text-red-400"}>
              {React.int(Elo.roundScore(player.lastEloChange))}
            </td>
            <td>
              <div className="flex items-center gap-2">
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
                {React.int(player.games)}
                {React.string(":")}
                {React.int(player.wins)}
              </div>
            </td>
          </tr>
        })
        ->React.array}
      </tbody>
    </table>
  </div>
}
