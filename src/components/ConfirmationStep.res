let mapPlayer = (users, key) => {
  let creeper = Players.playerByKey(users, key)

  switch creeper {
  | Some(creep) => creep.name
  | None => "..."
  }
}

@react.component
let make = (~score, ~winners, ~reset, ~players) => {
  let winners = winners->Array.map(winner => mapPlayer(players, winner))

  let winnerNames = Array.joinWith(winners, " & ")

  <div className="flex justify-center items-center h-screen flex-col">
    <h1 className="text-3xl"> {React.string("Gefeliciteerd, " ++ winnerNames ++ "!")} </h1>
    <div
      className="text-lime-400 text-[160px]"
      style={ReactDOM.Style.make(~textShadow="0 0 20px rgb(163 230 53)", ())}>
      {React.string("+")}
      {React.int(score)}
    </div>
    <Button variant={Blue} onClick={_ => reset()}> {React.string("Verder")} </Button>
  </div>
}
