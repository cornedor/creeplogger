// Generated by ReScript, PLEASE EDIT WITH CARE

import * as React from "react";
import * as Schema from "./Schema.bs.mjs";
import * as Database from "./Database.bs.mjs";
import * as PervasivesU from "rescript/lib/es6/pervasivesU.js";
import * as RescriptCore from "@rescript/core/src/RescriptCore.bs.mjs";
import * as FirebaseSchema from "./FirebaseSchema.bs.mjs";
import * as Database$1 from "firebase/database";

var playerSchema = Schema.object(function (s) {
      return {
              name: s.f("name", Schema.string),
              wins: s.o("wins", Schema.$$int, 0),
              losses: s.o("losses", Schema.$$int, 0),
              absoluteWins: s.o("absoluteWins", Schema.$$int, 0),
              absoluteLosses: s.o("absoluteLosses", Schema.$$int, 0),
              games: s.o("games", Schema.$$int, 0),
              teamGoals: s.o("teamGoals", Schema.$$int, 0),
              blueGames: s.o("blueGames", Schema.$$int, 0),
              redGames: s.o("redGames", Schema.$$int, 0),
              blueWins: s.o("blueWins", Schema.$$int, 0),
              redWins: s.o("redWins", Schema.$$int, 0),
              elo: s.o("elo", Schema.$$float, 1000.0),
              lastEloChange: s.o("change", Schema.$$float, 0.0),
              key: s.f("key", Schema.string),
              mattermostHandle: s.f("mh", FirebaseSchema.nullableTransform(Schema.option(Schema.string))),
              lastGames: s.o("lastGames", Schema.array(Schema.$$int), [])
            };
    });

var playersSchema = Schema.dict(playerSchema);

async function addPlayer(name) {
  var playersRef = Database$1.ref(Database.database, "players");
  var data = Schema.serializeWith({
        name: name,
        wins: 0,
        losses: 0,
        absoluteWins: 0,
        absoluteLosses: 0,
        games: 0,
        teamGoals: 0,
        blueGames: 0,
        redGames: 0,
        blueWins: 0,
        redWins: 0,
        elo: 1000.0,
        lastEloChange: 0.0,
        key: "",
        mattermostHandle: undefined,
        lastGames: []
      }, playerSchema);
  var data$1;
  data$1 = data.TAG === "Ok" ? data._0 : RescriptCore.panic("Could not serialize player");
  var ref = await Database$1.push(playersRef, data$1);
  var key = ref.key;
  if (!(key == null)) {
    await Database$1.set(Database$1.ref(Database.database, "players/" + key + "/key"), key);
  }
  return ref;
}

function useAllPlayers(orderByOpt, ascOpt) {
  var orderBy = orderByOpt !== undefined ? orderByOpt : "games";
  var asc = ascOpt !== undefined ? ascOpt : true;
  var match = React.useState(function () {
        return [];
      });
  var setPlayers = match[1];
  var players = match[0];
  var playersRef = Database$1.query(Database$1.ref(Database.database, "players"), Database$1.orderByChild(orderBy));
  var sortFunction = asc ? (function (prim) {
        return prim.toReversed();
      }) : (function (a) {
        return a;
      });
  React.useEffect((function () {
          return Database$1.onValue(playersRef, (function (snapshot) {
                        var newPlayers = [];
                        snapshot.forEach(function (snap) {
                              var data = snap.val();
                              if (data == null) {
                                return ;
                              }
                              var player = Schema.parseWith(data, playerSchema);
                              if (player.TAG === "Ok") {
                                newPlayers.push(player._0);
                                return ;
                              }
                              console.error(player._0);
                            });
                        setPlayers(function (param) {
                              return newPlayers;
                            });
                      }), undefined);
        }), [setPlayers]);
  return React.useMemo((function () {
                return sortFunction(players);
              }), [
              players,
              asc
            ]);
}

async function fetchAllPlayers() {
  var playersRef = Database$1.ref(Database.database, "players");
  var data = await Database$1.get(playersRef);
  var empty = {};
  var data$1 = data.val();
  if (data$1 == null) {
    return empty;
  }
  var players = Schema.parseWith(data$1, playersSchema);
  if (players.TAG === "Ok") {
    return players._0;
  } else {
    return empty;
  }
}

async function fetchPlayerByKey(key) {
  var playerRef = Database$1.ref(Database.database, "players/" + key);
  var data = await Database$1.get(playerRef);
  var player = data.val();
  if (player == null) {
    return ;
  }
  var player$1 = Schema.parseWith(player, playerSchema);
  if (player$1.TAG === "Ok") {
    return player$1._0;
  }
  console.error(player$1._0);
}

function playerByKey(players, key) {
  return players.find(function (c) {
              return c.key === key;
            });
}

function updateGameStats(key, myTeamPoints, opponentTeamPoints, team, elo) {
  var isAbsolute = PervasivesU.abs(myTeamPoints - opponentTeamPoints | 0) === 7;
  var isWin = myTeamPoints > opponentTeamPoints;
  var isAbsoluteWin = isAbsolute && isWin;
  var isLoss = myTeamPoints < opponentTeamPoints;
  var isAbsoluteLoss = isAbsolute && isLoss;
  var isRedWin = team === "Red" && isWin;
  var isBlueWin = team === "Blue" && isWin;
  var playerRef = Database$1.ref(Database.database, "players/" + key);
  return Database$1.runTransaction(playerRef, (function (data) {
                var player = Schema.parseWith(data, playerSchema);
                if (player.TAG !== "Ok") {
                  return data;
                }
                var player$1 = player._0;
                var res = Schema.serializeWith({
                      name: player$1.name,
                      wins: isWin ? player$1.wins + 1 | 0 : player$1.wins,
                      losses: isLoss ? player$1.losses + 1 | 0 : player$1.losses,
                      absoluteWins: isAbsoluteWin ? player$1.absoluteWins + 1 | 0 : player$1.absoluteWins,
                      absoluteLosses: isAbsoluteLoss ? player$1.absoluteLosses + 1 | 0 : player$1.absoluteLosses,
                      games: player$1.games + 1 | 0,
                      teamGoals: player$1.teamGoals + myTeamPoints | 0,
                      blueGames: team === "Blue" ? player$1.blueGames + 1 | 0 : player$1.blueGames,
                      redGames: team === "Red" ? player$1.redGames + 1 | 0 : player$1.redGames,
                      blueWins: isBlueWin ? player$1.blueWins + 1 | 0 : player$1.blueWins,
                      redWins: isRedWin ? player$1.redWins + 1 | 0 : player$1.redWins,
                      elo: elo,
                      lastEloChange: elo - player$1.elo,
                      key: player$1.key,
                      mattermostHandle: player$1.mattermostHandle,
                      lastGames: player$1.lastGames
                    }, playerSchema);
                if (res.TAG === "Ok") {
                  return res._0;
                } else {
                  return data;
                }
              }));
}

export {
  addPlayer ,
  useAllPlayers ,
  fetchAllPlayers ,
  fetchPlayerByKey ,
  playerByKey ,
  updateGameStats ,
}
/* playerSchema Not a pure module */
