// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Schema from "./Schema.bs.mjs";
import * as Caml_option from "rescript/lib/es6/caml_option.js";

function nullableTransform(t) {
  return Schema.transform(t, (function (param) {
                return {
                        p: (function (value) {
                            return value;
                          }),
                        s: (function (value) {
                            if (value !== undefined) {
                              return Caml_option.some(Caml_option.valFromOption(value));
                            } else {
                              return null;
                            }
                          })
                      };
              }));
}

export {
  nullableTransform ,
}
/* Schema Not a pure module */
