@module external styles: {..} = "./button.module.css"

type variant = Blue | Grey | Red

@react.component
let make = (~className="", ~variant, ~onClick=?, ~children, ~type_="button", ~disabled=false) => {
  <button
    ?onClick
    type_
    disabled
    className={Cn.make([
      styles["button"],
      switch variant {
      | Blue => styles["buttonBlue"]
      | Grey => styles["buttonGrey"]
      | Red => styles["buttonRed"]
      },
      className,
    ])}>
    children
  </button>
}
