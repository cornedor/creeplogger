@react.component
let make: (
  ~step: LoggerStep.step,
  ~onNextStep: unit => unit,
  ~onReset: unit => unit,
  ~disabled: bool=?,
) => React.element
