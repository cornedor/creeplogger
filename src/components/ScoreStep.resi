@react.component
let make: (
  ~selectedUsers: Belt.Map.String.t<Players.team>,
  ~setStep: (LoggerStep.step => LoggerStep.step) => 'a,
  ~reset: unit => unit,
  ~blueState: int,
  ~setBlueState: (int => int) => unit,
  ~redState: int,
  ~setRedState: (int => int) => unit,
  ~setEarnedPoints: (int => int) => unit,
  ~players: array<Players.player>,
  ~selectedGame: option<string>,
  ~setSelectedGame: (option<string> => option<string>) => unit,
) => React.element
