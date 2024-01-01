@@directive("'use server';")
let url = %raw(`process.env.MATTERMOST_URL`)
let isEnabled = %raw(`process.env.MATTERMOST_ENABLED`) == "true"

type mattermostMessage = {text: string}

let publishMessage = (message: string) => {
  switch (url, isEnabled) {
  | (None, true) => panic("MATTERMOST_URL not set")
  | (Some(url), true) => {
      Js.log(Fetch.Body.string(JSON.stringifyAny(message)->Option.getExn))
      Some(
        Fetch.fetch(
          url,
          {
            method: #POST,
            body: Fetch.Body.string(
              JSON.stringifyAny({
                text: message,
              })->Option.getExn,
            ),
          },
        ),
      )
    }
  | _ => None
  }
}

let sendCreepsUpdate = async (
  bluePlayers: array<Players.player>,
  redPlayers: array<Players.player>,
  blueScore: int,
  redScore: int,
  points: int,
) => {
  let blueNames =
    bluePlayers
    ->Array.map(player =>
      switch player.mattermostHandle {
      | Some(handle) => `@${handle}`
      | None => player.name
      }
    )
    ->Array.joinWith(", ")
  let redNames =
    redPlayers
    ->Array.map(player =>
      switch player.mattermostHandle {
      | Some(handle) => `@${handle}`
      | None => player.name
      }
    )
    ->Array.joinWith(", ")

  let bluePoints = blueScore > redScore ? 0 - points : points
  let redPoints = blueScore < redScore ? 0 - points : points

  let message = `### Nieuw potje geregistreerd!

| Team | Goals | Punten |
| ---- | ----- | ------ |
| ${blueNames} | ${blueScore->Int.toString} | ${bluePoints->Int.toString} |
| ${redNames} | ${redScore->Int.toString} | ${redPoints->Int.toString} |
`

  switch publishMessage(message) {
  | Some(promise) =>
    let _ = await promise
  | None => ()
  }

  0
}
