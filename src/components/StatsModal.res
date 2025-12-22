@val external document: {.."addEventListener": (string, Js.t<'a> => unit) => unit, "removeEventListener": (string, Js.t<'a> => unit) => unit} = "document"

@react.component
let make = (~show, ~setShow) => {
  let stats = Stats.useStats()
  let (daysWithoutName, daysWithoutDate) = DaysWithout.useDaysWithout()

  let daysSince = DateFns.differenceInDays(Date.make(), daysWithoutDate)

  let blue = Float.fromInt(stats.totalBlueWins)
  let red = Float.fromInt(stats.totalRedWins)

  let bluePercentages = (blue /. (blue +. red) *. 100.)->Float.toString

  // Handle Escape key to close modal
  React.useEffect(() => {
    if show {
      let handleKeyDown = (event: Js.t<'a>) => {
        let key = event["key"]->Js.Nullable.toOption->Option.getOr("")
        if key == "Escape" {
          setShow(_ => false)
        }
      }
      
      let _ = document["addEventListener"]("keydown", handleKeyDown)
      Some(() => {
        let _ = document["removeEventListener"]("keydown", handleKeyDown)
        ()
      })
    } else {
      None
    }
  }, [show])

  <>
    {if show {
      <div
        className="fixed inset-0 z-[199] bg-black/20"
        onClick={_ => setShow(_ => false)}
      />
    } else {
      React.null
    }}
    <div
      className="modal flex flex-col"
      style={ReactDOM.Style.make(~transform=show ? "translateX(0)" : "translateX(-100%)", ())}
      onMouseDown={event => {
        // Stop propagation so clicking inside modal doesn't close it
        let _ = ReactEvent.Mouse.stopPropagation(event)
        ()
      }}>
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
  </>
}
