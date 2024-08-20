open Firebase

type queueItem = {
  playerKey: string,
  until: float,
}

type queue = {players: array<queueItem>}

@inline
let bucket = "queue"

let queuePlayerSchema = Schema.object(s => {
  playerKey: s.field("playerKey", Schema.string),
  until: s.field("until", Schema.float),
})

let queueSchema = Schema.object(s => {
  players: s.field("players", Schema.array(queuePlayerSchema)),
})

let enqueuePlayer = async (playerKey, until) => {
  let playersRef = Firebase.Database.refPath(Database.database, bucket)
  let data = switch Schema.serializeWith(
    {
      playerKey,
      until,
    },
    queuePlayerSchema,
  ) {
  | Ok(data) => data
  | Error(_) => panic("Could not serialize queue player")
  }

  await Firebase.Database.pushValue(playersRef, data)
}
