// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Cn from "rescript-classnames/src/Cn.bs.mjs";
import * as JsxRuntime from "react/jsx-runtime";
import * as ButtonModuleCss from "./button.module.css";

var styles = ButtonModuleCss;

function Button(props) {
  var __disabled = props.disabled;
  var __type_ = props.type_;
  var __className = props.className;
  var className = __className !== undefined ? __className : "";
  var type_ = __type_ !== undefined ? __type_ : "button";
  var disabled = __disabled !== undefined ? __disabled : false;
  var tmp;
  switch (props.variant) {
    case "Blue" :
        tmp = styles.buttonBlue;
        break;
    case "Grey" :
        tmp = styles.buttonGrey;
        break;
    case "Red" :
        tmp = styles.buttonRed;
        break;
    
  }
  return JsxRuntime.jsx("button", {
              children: props.children,
              className: Cn.make([
                    styles.button,
                    tmp,
                    className
                  ]),
              disabled: disabled,
              type: type_,
              onClick: props.onClick
            });
}

var make = Button;

export {
  make ,
}
/* styles Not a pure module */
