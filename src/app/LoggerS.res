@react.component
let make = async () => {
  let players = await Fetch.fetch(`${Database.databaseURL}/${Players.bucket}.json`, {method: #GET})
  let players = switch (await Fetch.Response.json(players))->Schema.parseWith(
    Players.playersSchema,
  ) {
  | Ok(players) =>
    players->Js.Dict.values->Array.toReversed->Array.toSorted((a, b) => float(b.games - a.games))
  | _ => []
  }

  <>
    <Logger players={players} />
  </>
}
