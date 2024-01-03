@react.component
let make = (~active: bool, ~children, ~className="") => {
  <div
    className
    style={ReactDOM.Style.make(
      ~gridColumn=`auto span 1`,
      ~gridRow=`auto / span 1`,
      ~transform=`scale(${active ? "1.02" : "1"})`,
      ~transitionDuration="0.6s",
      ~transitionTimingFunction="linear(0, 0.009, 0.035 2.1%, 0.141, 0.281 6.7%, 0.723 12.9%, 0.938 16.7%, 1.017, 1.077, 1.121, 1.149 24.3%, 1.159, 1.163, 1.161, 1.154 29.9%, 1.129 32.8%, 1.051 39.6%, 1.017 43.1%, 0.991, 0.977 51%, 0.974 53.8%, 0.975 57.1%, 0.997 69.8%, 1.003 76.9%, 1.004 83.8%, 1)",
      ~transitionProperty="transform, shadow",
      (),
    )}>
    children
  </div>
}
