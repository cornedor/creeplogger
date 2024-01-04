@react.component
let make: (
  ~score: int,
  ~winners: array<string>,
  ~reset: unit => unit,
  ~players: array<Players.player>,
) => React.element
