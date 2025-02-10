open Firebase

external prompt: string => Nullable.t<string> = "prompt"
external confirm: string => bool = "confirm"

@react.component
let make = () => {
  let user = Database.useUser()
  let (update, setUpdate) = React.useState(_ => "")
  let players = Players.useAllPlayers()
  let games = Games.useLastGames()
  let dartsGames = DartsGames.useLastGames()
  // let (games, setGames) = React.useState(_ => empty)

  // React.useEffect(() => {
  //   let _ = Games.getTimePeriod(Games.Weekly)->Promise.then(games => {
  //     Console.log(games)
  //     setGames(_ => games)
  //     Promise.resolve()
  //   })
  //   None
  // }, [])

  let content = switch user {
  | Value(user) => {
      let email = user["email"]->Js.Nullable.toOption->Option.getOr("??@??")
      let name = user["displayName"]->Js.Nullable.toOption->Option.getOr(email)
      <div>
        {React.string("Welcome, " ++ name)}
        <h2 className="py-2 text-xl font-semibold"> {React.string("Actions")} </h2>
        <div className="text-green-300 py-2"> {React.string(update)} </div>
        <div className="flex gap-4">
          <Button
            variant={Grey}
            onClick={_ => {
              setUpdate(_ => "Recalculating...")
              let _ = Stats.recalculateStats()->Promise.then(_ => {
                let _ = setUpdate(_ => "Recalculating finished")
                Promise.resolve()
              })
            }}>
            {React.string("Recalculate scores & stats")}
          </Button>
          <Button
            variant={Grey}
            onClick={_ => {
              let _ = Firebase.Auth.signOut(Database.auth)
            }}>
            {React.string("Logout")}
          </Button>
        </div>
        <details>
          <summary className="p-2 bg-white/5 mt-2 hover:bg-white/10 select-none rounded">
            {React.string("Players")}
          </summary>
          <table>
            <thead>
              <tr>
                <th> {React.string("Name")} </th>
                <th> {React.string("Mattermost Handle")} </th>
                <th> {React.string("Actions")} </th>
              </tr>
            </thead>
            <tbody>
              {Array.map(players, player =>
                <tr key={player.key}>
                  <td className="px-2 py-1"> {React.string(player.name)} </td>
                  <td className="px-2 py-1">
                    {React.string(player.mattermostHandle->Option.getOr("Undefined"))}
                  </td>
                  <td className="px-2 py-1 flex gap-2">
                    <button
                      className="bg-slate-300 rounded py-1 px-3 text-black"
                      onClick={_ => {
                        let handle = prompt("New handle")->Js.toOption
                        let _ = Players.writePlayer({...player, mattermostHandle: handle})
                      }}>
                      {React.string("Set MH")}
                    </button>
                    <button
                      className="bg-slate-300 rounded py-1 px-3 text-black"
                      onClick={_ => {
                        if confirm("Are you sure you want to remove " ++ player.name ++ "?") {
                          let _ = Players.removePlayer(player.key)
                        }
                      }}>
                      {React.string("Remove")}
                    </button>
                  </td>
                </tr>
              )->React.array}
            </tbody>
          </table>
        </details>
        <details>
          <summary className="p-2 bg-white/5 mt-2 hover:bg-white/10 select-none rounded">
            {React.string("Last games")}
          </summary>
          <table>
            <thead>
              <tr>
                <th> {React.string("Blue team")} </th>
                <th> {React.string("Red team")} </th>
                <th> {React.string("When")} </th>
                <th> {React.string("Score")} </th>
                <th> {React.string("Actions")} </th>
              </tr>
            </thead>
            <tbody>
              {games
              ->Js.Dict.entries
              ->Array.toReversed
              ->Array.map(((key, game)) => {
                let bluePlayers = Array.map(game.blueTeam, player => {
                  switch Array.find(players, p => p.key == player) {
                  | Some(player) => player.name
                  | None => "..."
                  }
                })
                let redPlayers = Array.map(game.redTeam, player => {
                  switch Array.find(players, p => p.key == player) {
                  | Some(player) => player.name
                  | None => "..."
                  }
                })
                <tr key={game.date->Date.toString}>
                  <td className="px-2 py-1"> {React.string(Array.join(bluePlayers, ", "))} </td>
                  <td className="px-2 py-1"> {React.string(Array.join(redPlayers, ", "))} </td>
                  <td className="px-2 py-1"> {React.string(Date.toISOString(game.date))} </td>
                  <td className="px-2 py-1">
                    {React.string(
                      "Blue " ++
                      game.blueScore->Int.toString ++
                      ":" ++
                      game.redScore->Int.toString ++ " Red",
                    )}
                  </td>
                  <td className="px-2 py-1 flex gap-2">
                    <button
                      className="bg-slate-300 rounded py-1 px-3 text-black"
                      onClick={_ => {
                        if confirm("Are you sure you want to remove this (" ++ key ++ ") game?") {
                          Console.log("Ok")
                          let _ = Games.removeGame(key)
                        }
                      }}>
                      {React.string("Remove")}
                    </button>
                  </td>
                </tr>
              })
              ->React.array}
            </tbody>
          </table>
        </details>
        <details>
          <summary className="p-2 bg-white/5 mt-2 hover:bg-white/10 select-none rounded">
            {React.string("Last darts games")}
          </summary>
          <table>
            <thead>
              <tr>
                <th> {React.string("Winners")} </th>
                <th> {React.string("Losers")} </th>
                <th> {React.string("When")} </th>
                <th> {React.string("Mode")} </th>
                <th> {React.string("Actions")} </th>
              </tr>
            </thead>
            <tbody>
              {dartsGames
              ->Js.Dict.entries
              ->Array.toReversed
              ->Array.map(((key, game)) => {
                let winners = Array.map(game.winners, player => {
                  switch Array.find(players, p => p.key == player) {
                  | Some(player) => player.name
                  | None => "..."
                  }
                })
                let losers = Array.map(game.losers, player => {
                  switch Array.find(players, p => p.key == player) {
                  | Some(player) => player.name
                  | None => "..."
                  }
                })
                <tr key={game.date->Date.toString}>
                  <td className="px-2 py-1"> {React.string(Array.join(winners, ", "))} </td>
                  <td className="px-2 py-1"> {React.string(Array.join(losers, ", "))} </td>
                  <td className="px-2 py-1"> {React.string(Date.toISOString(game.date))} </td>
                  <td className="px-2 py-1">
                    {React.string(DartsGames.dartsModeToString(game.mode))}
                  </td>
                  <td className="px-2 py-1 flex gap-2">
                    <button
                      className="bg-slate-300 rounded py-1 px-3 text-black"
                      onClick={_ => {
                        if confirm("Are you sure you want to remove this (" ++ key ++ ") game?") {
                          let _ = DartsGames.removeGame(key)
                        }
                      }}>
                      {React.string("Remove")}
                    </button>
                  </td>
                </tr>
              })
              ->React.array}
            </tbody>
          </table>
        </details>
      </div>
    }
  | _ => <LoginForm />
  }

  <div
    className="bg-blobs bg-darkbg bg-no-repeat bg-left text-white flex flex-col min-h-screen w-full p-10">
    <h1 className="text-3xl pb-2 font-bold">
      <Link href="/" className="font-thin"> {React.string("← Back - ")} </Link>
      {React.string("Admin dashboard")}
    </h1>
    {content}
  </div>
}
