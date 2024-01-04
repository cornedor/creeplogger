@react.component
let make: (
  ~selectedUsers: Belt.Map.String.t<Players.team>,
  ~setSelectedUsers: (Belt.Map.String.t<Players.team> => Belt.Map.String.t<Players.team>) => unit,
  ~reset: unit => unit,
  ~setStep: (LoggerStep.step => LoggerStep.step) => unit,
  ~players: array<Players.player>,
) => React.element
