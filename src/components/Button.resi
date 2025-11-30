type variant = Blue | Grey | Red

@react.component
let make: (
  ~className: string=?,
  ~variant: variant,
  ~onClick: JsxEvent.Mouse.t => unit=?,
  ~children: React.element,
  ~type_: string=?,
  ~disabled: bool=?,
) => React.element
