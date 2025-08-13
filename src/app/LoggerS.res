@react.component
let make = async () => {
  let players = await Fetch.fetch(`${Database.databaseURL}/${Players.bucket}.json`, {method: #GET})
  let players = switch (await Fetch.Response.json(players))->Schema.parseWith(
    Players.playersSchema,
  ) {
  | Ok(players) => {
    let cmpInsensitive = (a, b) => {
      let al = Js.String2.toLowerCase(a)
      let bl = Js.String2.toLowerCase(b)
      if al < bl { -1 } else if al > bl { 1 } else { 0 }
    }
    players->Js.Dict.values->Array.toSorted((a, b) => {
      let primary = Int.toFloat(b.games - a.games)
      if primary == 0.0 {
        let nameCmp = cmpInsensitive(a.name, b.name)
        if nameCmp == 0 { Int.toFloat(cmpInsensitive(a.key, b.key)) } else { Int.toFloat(nameCmp) }
      } else {
        primary
      }
    })
  }
  | _ => []
  }

  <>
    <Logger players={players} />
  </>
}
