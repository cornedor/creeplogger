@react.component
let make = (~show, ~setShow) => {
  let players = Players.useAllPlayers(~orderBy=#elo)

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
          <th className="text-lg text-left"> {React.string("Score")} </th>
          <th className="text-lg text-left"> {React.string("Groei")} </th>
        </tr>
      </thead>
      <tbody>
        {players
        ->Array.mapWithIndex((player, index) =>
          <tr key={player.key}>
            <td> {React.string(`#${Int.toString(index + 1)}`)} </td>
            <td> {React.string(player.name)} </td>
            <td> {React.float(Math.round(player.elo))} </td>
            <td className={player.lastEloChange > 0.0 ? "text-green-400" : "text-red-400"}>
              {React.float(Math.round(player.lastEloChange))}
            </td>
          </tr>
        )
        ->React.array}
      </tbody>
    </table>
  </div>
}
