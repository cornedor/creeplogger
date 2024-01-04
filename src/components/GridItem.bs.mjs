// Generated by ReScript, PLEASE EDIT WITH CARE

import * as JsxRuntime from "react/jsx-runtime";

function GridItem(props) {
  var __className = props.className;
  var className = __className !== undefined ? __className : "";
  return JsxRuntime.jsx("div", {
              children: props.children,
              className: className,
              style: {
                gridColumn: "auto span 1",
                gridRow: "auto / span 1",
                transitionDuration: "0.2s",
                transitionProperty: "all",
                transitionTimingFunction: "ease-in-out",
                transform: "scale(" + (
                  props.active ? "1.02" : "1"
                ) + ")"
              }
            });
}

var make = GridItem;

export {
  make ,
}
/* react/jsx-runtime Not a pure module */
