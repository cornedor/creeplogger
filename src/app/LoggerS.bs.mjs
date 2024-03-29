// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Logger from "./Logger.bs.mjs";
import * as Schema from "../helpers/Schema.bs.mjs";
import * as Js_dict from "rescript/lib/es6/js_dict.js";
import * as Players from "../helpers/Players.bs.mjs";
import * as Database from "../helpers/Database.bs.mjs";
import * as Caml_option from "rescript/lib/es6/caml_option.js";
import * as JsxRuntime from "react/jsx-runtime";

async function make(param) {
  var players = await fetch(Database.databaseURL + "/" + Players.bucket + ".json", {
        method: "GET"
      });
  var players$1 = Schema.parseWith(await players.json(), Players.playersSchema);
  var players$2;
  players$2 = players$1.TAG === "Ok" ? Js_dict.values(players$1._0).toReversed().toSorted(function (a, b) {
          return b.games - a.games | 0;
        }) : [];
  return JsxRuntime.jsx(JsxRuntime.Fragment, {
              children: Caml_option.some(JsxRuntime.jsx(Logger.make, {
                        players: players$2
                      }))
            });
}

var LoggerS = make;

var make$1 = LoggerS;

export {
  make$1 as make,
}
/* Logger Not a pure module */
