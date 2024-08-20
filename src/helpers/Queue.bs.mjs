// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Schema from "./Schema.bs.mjs";
import * as Database from "./Database.bs.mjs";
import * as RescriptCore from "@rescript/core/src/RescriptCore.bs.mjs";
import * as Database$1 from "firebase/database";

var queuePlayerSchema = Schema.object(function (s) {
      return {
              playerKey: s.f("playerKey", Schema.string),
              until: s.f("until", Schema.$$float)
            };
    });

var queueSchema = Schema.object(function (s) {
      return {
              players: s.f("players", Schema.array(queuePlayerSchema))
            };
    });

async function enqueuePlayer(playerKey, until) {
  var playersRef = Database$1.ref(Database.database, "queue");
  var data = Schema.serializeWith({
        playerKey: playerKey,
        until: until
      }, queuePlayerSchema);
  var data$1;
  data$1 = data.TAG === "Ok" ? data._0 : RescriptCore.panic("Could not serialize queue player");
  return await Database$1.push(playersRef, data$1);
}

export {
  queuePlayerSchema ,
  queueSchema ,
  enqueuePlayer ,
}
/* queuePlayerSchema Not a pure module */