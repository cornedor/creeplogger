let nullableTransform = t =>
  Schema.transform(t, _ => {
    parser: value => value,
    serializer: value =>
      switch value {
      | None => %raw(`null`)
      | Some(value) => Some(value)
      },
  })
