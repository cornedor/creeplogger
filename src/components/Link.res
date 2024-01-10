@module("next/link") @react.component
external make: (
  ~href: string,
  ~_as: string=?,
  ~prefetch: bool=?,
  ~replace: option<bool>=?,
  ~shallow: option<bool>=?,
  ~passHref: option<bool>=?,
  ~children: React.element,
  ~className: string=?,
) => React.element = "default"
