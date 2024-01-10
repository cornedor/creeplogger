open Firebase

external prompt: string => Nullable.t<string> = "prompt"

@react.component
let make = () => {
  let user = Database.useUser()
  let (update, setUpdate) = React.useState(_ => "")
  let players = Players.useAllPlayers()

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
                  <td> {React.string(player.name)} </td>
                  <td> {React.string(player.mattermostHandle->Option.getOr("Undefined"))} </td>
                  <td className="flex gap-2">
                    <button
                      className="bg-slate-300 rounded py-1 px-3 text-black"
                      onClick={_ => {
                        let handle = prompt("New handle")->Js.toOption
                        let _ = Players.writePlayer({...player, mattermostHandle: handle})
                      }}>
                      {React.string("Set MH")}
                    </button>
                  </td>
                </tr>
              )->React.array}
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
