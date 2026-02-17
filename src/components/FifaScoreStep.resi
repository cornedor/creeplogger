@react.component
let make: (
  ~selectedUsers: Belt.Map.String.t<Players.team>,
  ~setStep: (LoggerStep.step => LoggerStep.step) => 'a,
  ~reset: unit => unit,
  ~setRedState: (int => int) => unit,
  ~setBlueState: (int => int) => unit,
  ~setEarnedPoints: (float => float) => unit,
  ~setPerPlayerDeltas: (Js.Dict.t<int> => Js.Dict.t<int>) => unit,
  ~players: array<Players.player>,
  ~gameMode: Games.gameMode,
) => React.element
