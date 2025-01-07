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
        | Some(data) => switch Schema.parseWith(data, daysWithoutSchema) {
          | Ok(daysWithout) => {
              setName(_ => daysWithout.name)
              setDate(_ => daysWithout.date)
            }
          | Error(error) => Js.log(error)
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

  ()
}
