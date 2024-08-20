@react.component
let make: (
  ~step: LoggerStep.step,
  ~onNextStep: unit => unit,
  ~onReset: unit => unit,
  ~disabled: bool=?,
  ~setShowQueueButtons: (bool => bool) => unit,
) => React.element
