// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Button from "../../components/Button.bs.mjs";
import * as Caml_obj from "rescript/lib/es6/caml_obj.js";
import * as Database from "../../helpers/Database.bs.mjs";
import * as Auth from "firebase/auth";
import * as ReactHookForm from "react-hook-form";
import * as JsxRuntime from "react/jsx-runtime";

function LoginForm(props) {
  var match = ReactHookForm.useForm(undefined);
  var register = match.register;
  var onSubmit = function (data) {
    Auth.signInWithEmailAndPassword(Database.auth, data.email, data.password);
  };
  var newrecord = Caml_obj.obj_dup(register("email", {
            required: true
          }));
  var newrecord$1 = Caml_obj.obj_dup(register("password", {
            required: true
          }));
  return JsxRuntime.jsxs("form", {
              children: [
                JsxRuntime.jsx("input", (newrecord.type = "email", newrecord.placeholder = "E-mail", newrecord.className = "p-2 rounded border-white/20 border", newrecord)),
                JsxRuntime.jsx("input", (newrecord$1.type = "password", newrecord$1.placeholder = "Password", newrecord$1.className = "p-2 rounded border-white/20 border", newrecord$1)),
                JsxRuntime.jsx(Button.make, {
                      variant: "Blue",
                      children: "Login",
                      type_: "submit"
                    })
              ],
              className: "flex gap-2 flex-col w-96",
              onSubmit: match.handleSubmit(onSubmit)
            });
}

var make = LoginForm;

export {
  make ,
}
/* Button Not a pure module */
