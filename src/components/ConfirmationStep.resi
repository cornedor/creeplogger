@react.component
let make: (
  ~score: float,
  ~winners: array<string>,
  ~reset: unit => unit,
  ~players: array<Players.player>,
  ~perPlayerDeltas: option<Js.Dict.t<int>>,
) => React.element
