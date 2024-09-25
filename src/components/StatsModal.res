@react.component
let make = (~show, ~setShow) => {
  let gameTypes = GameTypes.useGameTypes()
  let players = Players.useAllPlayers()

  let gameTypeHead = gameTypes->Array.map(gameType => {
    <th key={gameType.name} className="text-center py-2 even:bg-slate-50/10 ">
      <span className="vertical-lr whitespace-nowrap"> {React.string(gameType.name)} </span>
    </th>
  })

  let playerRows = players->Array.map(player => {
    let gamesPlayed = gameTypes->Array.map(gameType => {
      let hasPlayed = player.gameTypes->Array.includes(gameType.name)
      switch hasPlayed {
      | true =>
        <td key={gameType.name} className="text-center even:bg-slate-50/10">
          {React.string("✅")}
        </td>
      | false =>
        <td key={gameType.name} className="text-center even:bg-slate-50/10">
          {React.string("❌")}
        </td>
      }
    })

    <tr key={player.key} className="odd:bg-slate-50/15">
      <th className="p-2 text-left "> {React.string(player.name)} </th>
      {React.array(gamesPlayed)}
    </tr>
  })

  <div
    className="modal flex flex-col"
    style={ReactDOM.Style.make(~transform=show ? "translateX(0)" : "translateX(-100%)", ())}>
    <header>
      <Button onClick={_ => setShow(s => !s)} variant={Blue}> {React.string("Terug")} </Button>
    </header>
    <table className="table-auto">
      <thead>
        <tr>
          <th className="vertical-lr"> {React.string("")} </th>
          {React.array(gameTypeHead)}
        </tr>
      </thead>
      <tbody> {React.array(playerRows)} </tbody>
    </table>
    <div className="flex-1" />
  </div>
}
