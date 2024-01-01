@react.component
let make = (~active: bool, ~children, ~className="") => {
  <div
    className
    style={ReactDOM.Style.make(
      ~gridColumn=`auto span 1`,
      ~gridRow=`auto / span 1`,
      ~transform=`scale(${active ? "1.07" : "1"})`,
      ~transition="transform 0.2s ease",
      (),
    )}>
    children
  </div>
}
