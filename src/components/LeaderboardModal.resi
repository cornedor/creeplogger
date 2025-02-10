@react.component
let make: (~show: bool, ~setShow: (bool => bool) => unit, ~gameMode: Games.gameMode) => Jsx.element
