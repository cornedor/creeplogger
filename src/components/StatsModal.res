@react.component
let make = (~show, ~setShow) => {
  let stats = Stats.useStats()

  <div
    className="modal"
    style={ReactDOM.Style.make(~transform=show ? "translateX(0)" : "translateX(-100%)", ())}>
    <header>
      <Button onClick={_ => setShow(s => !s)} variant={Blue}> {React.string("Terug")} </Button>
    </header>
    <em className="py-2 inline-block">
      {React.string("WIP: Misschien komt hier ooit wat mooiers voor, maar hier is alvast wat.")}
    </em>
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
  </div>
}
