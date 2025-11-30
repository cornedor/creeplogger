open Firebase

type daysWithout = {
  name: string,
  date: Date.t,
}

let daysWithoutSchema = Schema.object(s => {
  name: s.fieldOr("name", Schema.string, "Days without an accident"),
  date: s.field(
    "date",
    Schema.float->Schema.transform(_ => {
      parser: Date.fromTime,
      serializer: Date.getTime,
    }),
  ),
})

let useDaysWithout = () => {
  let (name, setName) = React.useState(_ => "")
  let (date, setDate) = React.useState(_ => Date.make())

  React.useEffect(() => {
    let daysWithoutRef = Firebase.Database.refPath(Database.database, "daysWithout")
    let unsubscribe = Firebase.Database.onValue(
      daysWithoutRef,
      snapshot => {
        switch Firebase.Database.Snapshot.val(snapshot)->Js.toOption {
        | Some(data) =>
          try {
            let daysWithout = data->Schema.parseOrThrow(daysWithoutSchema)
            setName(_ => daysWithout.name)
            setDate(_ => daysWithout.date)
          } catch {
          | error => Js.log(error)
          }
        | None => Js.log("No data")
        }
      },
      (),
    )

    Some(unsubscribe)
  }, [])

  (name, date)
}

let reset = async () => {
  let daysWithoutRef = Firebase.Database.refPath(Database.database, "daysWithout/date")
  await Firebase.Database.set(daysWithoutRef, Date.now())

  let daysWithoutRef = Firebase.Database.refPath(Database.database, "daysWithout")
  let daysWithoutVal = await Firebase.Database.get(daysWithoutRef)

  let name = try {
    let val = daysWithoutVal->Firebase.Database.Snapshot.val->Js.toOption
    switch val {
    | Some(data) => (data->Schema.parseOrThrow(daysWithoutSchema)).name
    | None => "Days without an accident"
    }
  } catch {
  | _ => "Days without an accident"
  }

  /* Send notification to Mattermost */
  let _ = Mattermost.sendDaysWithoutReset(name)
}
