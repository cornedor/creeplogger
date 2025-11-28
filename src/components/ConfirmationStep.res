let mapPlayer = (users, key) => {
  let creeper = Players.playerByKey(users, key)

  switch creeper {
  | Some(creep) => creep.name
  | None => "..."
  }
}

@react.component
let make = (~score, ~winners, ~reset, ~players, ~perPlayerDeltas: option<Js.Dict.t<int>>) => {
  let winnerNames =
    winners
    ->Array.map(winner => mapPlayer(players, winner))
    ->Array.join(" & ")

  <div className="flex justify-center items-center h-screen flex-col">
    <h1 className="text-3xl"> {React.string("Gefeliciteerd, " ++ winnerNames ++ "!")} </h1>
    <div
      className="text-lime-400 text-[160px]"
      style={{
        textShadow: "0 0 20px rgb(163 230 53)",
      }}>
      {React.string("+")}
      {React.int(score)}
    </div>
    {switch perPlayerDeltas {
    | Some(map) => {
        let items =
          winners
          ->Array.map(wKey => {
            let name = mapPlayer(players, wKey)
            let delta = Js.Dict.get(map, wKey)->Option.getOr(0)
            let sign = delta >= 0 ? "+" : ""
            <li key={wKey}> {React.string(name ++ ": " ++ sign ++ Int.toString(delta))} </li>
          })
        <ul className="mb-6"> {React.array(items)} </ul>
      }
    | None => React.null
    }}
    <Button variant={Blue} onClick={_ => reset()}> {React.string("Verder")} </Button>
  </div>
}
