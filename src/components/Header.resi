@react.component
let make: (
  ~step: LoggerStep.step,
  ~onNextStep: unit => unit,
  ~onReset: unit => unit,
  ~disabled: bool=?,
  ~setShowQueueButtons: (bool => bool) => unit,
  ~gameMode: Games.gameMode,
  ~setGameMode: option<(Games.gameMode => Games.gameMode) => unit>,
  ~searchQuery: option<string>,
  ~setSearchQuery: option<(string => string) => unit>,
  ~setSelectedUsers: option<((Belt.Map.String.t<Players.team> => Belt.Map.String.t<Players.team>) => unit)>,
) => React.element
