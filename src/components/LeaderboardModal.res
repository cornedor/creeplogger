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
          <th className="text-lg text-left"> {React.string("#")} </th>
          <th className="text-lg text-left"> {React.string("Speler")} </th>
          <th className="text-lg text-left">
            <button onClick={_ => setOrder(order => !order)}>
              {React.string("Score " ++ (order ? "↑" : "↓"))}
            </button>
          </th>
          <th className="text-lg text-left"> {React.string("Groei")} </th>
        </tr>
      </thead>
      <tbody>
        {players
        ->Array.map(player => {
          let roundedElo = player.elo->Math.round->Float.toInt
          if roundedElo != previousScore.contents {
            position := position.contents + 1
          }
          previousScore := roundedElo

          <tr key={player.key}>
            <td> {React.string(`#${position.contents->Int.toString}`)} </td>
            <td> {React.string(player.name)} </td>
            <td> {React.int(roundedElo)} </td>
            <td className={player.lastEloChange > 0.0 ? "text-green-400" : "text-red-400"}>
              {React.float(Math.round(player.lastEloChange))}
            </td>
          </tr>
        })
        ->React.array}
      </tbody>
    </table>
  </div>
}
