open Firebase

type gameType = {name: string}

let gameTypeSchema = Schema.object(s => {
  name: s.field("name", Schema.string),
})

let gameTypesSchema = Schema.array(gameTypeSchema)

let bucket = "gameTypes"

let fetchGameTypes = async () => {
  let gameTypesRef = Firebase.Database.refPath(Database.database, bucket)
  let data = await Firebase.Database.get(gameTypesRef)
  switch Firebase.Database.Snapshot.val(data)->Js.toOption {
  | Some(data) =>
    switch data->Schema.parseWith(gameTypesSchema) {
    | Ok(gameTypes) => gameTypes
    | Error(_) => []
    }
  | None => []
  }
}

external snapshotToArray: dataSnapshot => array<dataSnapshot> = "%identity"

let useGameTypes = () => {
  let (gameTypes, setGameTypes) = React.useState(_ => [])
  let gameTypesRef = Firebase.Database.refPath(Database.database, bucket)

  React.useEffect(() => {
    let unsubscribe = Firebase.Database.onValue(
      gameTypesRef,
      snapshot => {
        let newGameTypes = []
        Array.forEach(snapshotToArray(snapshot), snap => {
          let data = Firebase.Database.Snapshot.val(snap)
          switch data->Js.toOption {
          | Some(data) =>
            switch data->Schema.parseWith(gameTypeSchema) {
            | Ok(gameType) => Array.push(newGameTypes, gameType)
            | Error(e) => Console.error(e)
            }
          | None => ()
          }
        })
        setGameTypes(_ => newGameTypes)
      },
      (),
    )

    Some(unsubscribe)
  }, [setGameTypes])

  gameTypes
}
