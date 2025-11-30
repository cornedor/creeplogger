@react.component
let make = async () => {
  let players = await Fetch.fetch(`${Database.databaseURL}/${Players.bucket}.json`, {method: #GET})
  let players = try {
    (await Fetch.Response.json(players))->Schema.parseOrThrow(Players.playersSchema)
    ->Js.Dict.values->Array.toReversed->Array.toSorted((a, b) => float(b.games - a.games))
  } catch {
  | _ => []
  }

  <>
    <Logger players={players} />
  </>
}
