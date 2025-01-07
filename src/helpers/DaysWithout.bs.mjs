// Generated by ReScript, PLEASE EDIT WITH CARE

import * as React from "react";
import * as Schema from "./Schema.bs.mjs";
import * as Database from "./Database.bs.mjs";
import * as Database$1 from "firebase/database";

var daysWithoutSchema = Schema.object(function (s) {
      return {
              name: s.fieldOr("name", Schema.string, "Days without an accident"),
              date: s.f("date", Schema.transform(Schema.$$float, (function (param) {
                          return {
                                  p: (function (prim) {
                                      return new Date(prim);
                                    }),
                                  s: (function (prim) {
                                      return prim.getTime();
                                    })
                                };
                        })))
            };
    });

function useDaysWithout() {
  var match = React.useState(function () {
        return "";
      });
  var setName = match[1];
  var match$1 = React.useState(function () {
        return new Date();
      });
  var setDate = match$1[1];
  React.useEffect((function () {
          var daysWithoutRef = Database$1.ref(Database.database, "daysWithout");
          return Database$1.onValue(daysWithoutRef, (function (snapshot) {
                        var data = snapshot.val();
                        if (data == null) {
                          console.log("No data");
                          return ;
                        }
                        var daysWithout = Schema.parseWith(data, daysWithoutSchema);
                        if (daysWithout.TAG === "Ok") {
                          var daysWithout$1 = daysWithout._0;
                          setName(function (param) {
                                return daysWithout$1.name;
                              });
                          return setDate(function (param) {
                                      return daysWithout$1.date;
                                    });
                        }
                        console.log(daysWithout._0);
                      }), undefined);
        }), []);
  return [
          match[0],
          match$1[0]
        ];
}

async function reset() {
  var daysWithoutRef = Database$1.ref(Database.database, "daysWithout/date");
  await Database$1.set(daysWithoutRef, Date.now());
}

export {
  reset ,
  useDaysWithout ,
}
/* daysWithoutSchema Not a pure module */