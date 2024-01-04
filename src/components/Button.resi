type variant = Blue | Grey | Red

@react.component
let make: (
  ~className: string=?,
  ~variant: variant,
  ~onClick: JsxEventU.Mouse.t => unit=?,
  ~children: React.element,
  ~type_: string=?,
  ~disabled: bool=?,
) => React.element
