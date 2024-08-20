@react.component
let make = (~show, ~setShow) => {
  let stats = Stats.useStats()

  let blue = Float.fromInt(stats.totalBlueWins)
  let red = Float.fromInt(stats.totalRedWins)

  let bluePercentages = (blue /. (blue +. red) *. 100.)->Float.toString

  <div
    className="modal flex flex-col"
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
    <div>
      <div
        className="rounded-full aspect-square w-[300px] my-4 mx-auto shadow-inner shadow-orange-50"
        style={ReactDOM.Style.make(
          ~background=`conic-gradient(#86b7ff, #1c77ff ${bluePercentages}%, #ff3e6e ${bluePercentages}%, #ff0055)`,
          (),
        )}
      />
    </div>
    <div className="flex-1" />
  </div>
}
