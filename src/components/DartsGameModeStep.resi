@react.component
let make: (
  ~selectedUsers: Belt.Map.String.t<Players.team>,
  ~setStep: (LoggerStep.step => LoggerStep.step) => 'a,
  ~reset: unit => unit,
  ~setEarnedPoints: (float => float) => unit,
  ~players: array<Players.player>,
  ~gameMode: Games.gameMode,
) => React.element
