open Firebase

let useFirebaseStatus = () => {
  let (status, setStatus) = React.useState(_ => false)

  React.useEffect(() => {
    let ref = Firebase.Database.refPath(Database.database, ".info/connected")
    let unsub = Firebase.Database.onValue(
      ref,
      snap => {
        switch Firebase.Database.Snapshot.val(snap)->Js.toOption {
        | Some(value) =>
          switch Js.Json.decodeBoolean(value) {
          | Some(true) => setStatus(_ => true)
          | Some(false) | None => setStatus(_ => false)
          }
        | None => setStatus(_ => false)
        }
      },
      (),
    )

    Some(unsub)
  }, [])

  status
}
