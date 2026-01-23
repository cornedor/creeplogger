@react.component
let make: (
  ~selectedUsers: Belt.Map.String.t<Players.team>,
  ~setStep: (LoggerStep.step => LoggerStep.step) => 'a,
  ~reset: unit => unit,
  ~blueState: int,
  ~setBlueState: (int => int) => unit,
  ~redState: int,
  ~setRedState: (int => int) => unit,
  ~setEarnedPoints: (float => float) => unit,
  ~setPerPlayerDeltas: (Js.Dict.t<int> => Js.Dict.t<int>) => unit,
  ~players: array<Players.player>,
  ~gameMode: Games.gameMode,
) => React.element
