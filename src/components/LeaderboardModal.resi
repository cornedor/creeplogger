@react.component
let make: (
  ~show: bool,
  ~setShow: (bool => bool) => unit,
  ~gameMode: Games.gameMode,
  ~setGameMode: option<(Games.gameMode => Games.gameMode) => unit>,
) => Jsx.element
