@react.component
let make = (~active: bool, ~children, ~className="") => {
  <div
    className
    style={ReactDOM.Style.make(
      ~gridColumn=`auto span 1`,
      ~gridRow=`auto / span 1`,
      ~transform=`scale(${active ? "1.02" : "1"})`,
      ~transitionDuration="0.2s",
      ~transitionTimingFunction="ease-in-out",
      ~transitionProperty="all",
      (),
    )}>
    children
  </div>
}
