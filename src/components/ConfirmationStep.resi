@react.component
let make: (
  ~score: int,
  ~winners: array<string>,
  ~reset: unit => unit,
  ~players: array<Players.player>,
  ~perPlayerDeltas: option<Js.Dict.t<int>>=?,
) => React.element
