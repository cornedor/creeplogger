// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Rules from "./Rules.bs.mjs";
import * as React from "react";
import * as Schema from "./Schema.bs.mjs";
import * as Caml_obj from "rescript/lib/es6/caml_obj.js";
import * as Database from "./Database.bs.mjs";
import * as RescriptCore from "@rescript/core/src/RescriptCore.bs.mjs";
import * as FirebaseSchema from "./FirebaseSchema.bs.mjs";
import * as Database$1 from "firebase/database";

var playerSchema = Schema.object(function (s) {
      return {
              name: s.f("name", Schema.string),
              wins: s.fieldOr("wins", Schema.$$int, 0),
              losses: s.fieldOr("losses", Schema.$$int, 0),
              absoluteWins: s.fieldOr("absoluteWins", Schema.$$int, 0),
              absoluteLosses: s.fieldOr("absoluteLosses", Schema.$$int, 0),
              games: s.fieldOr("games", Schema.$$int, 0),
              teamGoals: s.fieldOr("teamGoals", Schema.$$int, 0),
              teamGoalsAgainst: s.fieldOr("tga", Schema.$$int, 0),
              blueGames: s.fieldOr("blueGames", Schema.$$int, 0),
              redGames: s.fieldOr("redGames", Schema.$$int, 0),
              blueWins: s.fieldOr("blueWins", Schema.$$int, 0),
              redWins: s.fieldOr("redWins", Schema.$$int, 0),
              elo: s.fieldOr("elo", Schema.$$float, 1000.0),
              lastEloChange: s.fieldOr("change", Schema.$$float, 0.0),
              key: s.f("key", Schema.string),
              mattermostHandle: s.f("mh", FirebaseSchema.nullableTransform(Schema.option(Schema.string))),
              lastGames: s.fieldOr("lastGames", Schema.array(Schema.$$int), []),
              hidden: s.f("hidden", FirebaseSchema.nullableTransform(Schema.option(Schema.bool))),
              dartsElo: s.fieldOr("dartsElo", Schema.$$float, 1000.0),
              dartsLastEloChange: s.fieldOr("dartsChange", Schema.$$float, 0.0),
              dartsGames: s.fieldOr("dartsGames", Schema.$$int, 0),
              dartsWins: s.fieldOr("dartsWins", Schema.$$int, 0),
              dartsLosses: s.fieldOr("dartsLosses", Schema.$$int, 0),
              dartsLastGames: s.fieldOr("dartsLastGames", Schema.array(Schema.$$int), [])
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
        teamGoalsAgainst: 0,
        blueGames: 0,
        redGames: 0,
        blueWins: 0,
        redWins: 0,
        elo: 1000.0,
        lastEloChange: 0.0,
        key: "",
        mattermostHandle: undefined,
        lastGames: [],
        hidden: undefined,
        dartsElo: 1000.0,
        dartsLastEloChange: 0.0,
        dartsGames: 0,
        dartsWins: 0,
        dartsLosses: 0,
        dartsLastGames: []
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
  var asc = ascOpt !== undefined ? ascOpt : false;
  var match = React.useState(function () {
        return [];
      });
  var setPlayers = match[1];
  var players = match[0];
  var playersRef = Database$1.query(Database$1.ref(Database.database, "players"), Database$1.orderByChild("games"));
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
                return players.toSorted(function (a, b) {
                            var match = asc ? [
                                a,
                                b
                              ] : [
                                b,
                                a
                              ];
                            var b$1 = match[1];
                            var a$1 = match[0];
                            if (orderBy === "elo") {
                              return a$1.elo - b$1.elo;
                            } else if (orderBy === "games") {
                              return a$1.games - b$1.games | 0;
                            } else {
                              return a$1.dartsElo - b$1.dartsElo;
                            }
                          });
              }), [
              players,
              asc,
              orderBy
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

function writePlayer(player) {
  var playerRef = Database$1.ref(Database.database, "players/" + player.key);
  return Database$1.set(playerRef, Schema.reverseConvertToJsonWith(player, playerSchema));
}

function getLastGames(lastGames, win) {
  var newGames = lastGames.concat([win ? 1 : 0]);
  return newGames.slice(-5);
}

function updateGameStats(key, myTeamPoints, opponentTeamPoints, team, elo) {
  var isAbsolute = Rules.isAbsolute(myTeamPoints, opponentTeamPoints);
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
                var newrecord = Caml_obj.obj_dup(player$1);
                var res = Schema.serializeWith((newrecord.lastGames = getLastGames(player$1.lastGames, isWin), newrecord.lastEloChange = elo - player$1.elo, newrecord.elo = elo, newrecord.redWins = isRedWin ? player$1.redWins + 1 | 0 : player$1.redWins, newrecord.blueWins = isBlueWin ? player$1.blueWins + 1 | 0 : player$1.blueWins, newrecord.redGames = team === "Red" ? player$1.redGames + 1 | 0 : player$1.redGames, newrecord.blueGames = team === "Blue" ? player$1.blueGames + 1 | 0 : player$1.blueGames, newrecord.teamGoalsAgainst = player$1.teamGoals + opponentTeamPoints | 0, newrecord.teamGoals = player$1.teamGoals + myTeamPoints | 0, newrecord.games = player$1.games + 1 | 0, newrecord.absoluteLosses = isAbsoluteLoss ? player$1.absoluteLosses + 1 | 0 : player$1.absoluteLosses, newrecord.absoluteWins = isAbsoluteWin ? player$1.absoluteWins + 1 | 0 : player$1.absoluteWins, newrecord.losses = isLoss ? player$1.losses + 1 | 0 : player$1.losses, newrecord.wins = isWin ? player$1.wins + 1 | 0 : player$1.wins, newrecord), playerSchema);
                if (res.TAG === "Ok") {
                  return res._0;
                } else {
                  return data;
                }
              }));
}

function updateDartsGameStats(key, myTeamPoints, elo) {
  var isWin = myTeamPoints === 1;
  var isLoss = myTeamPoints === 0;
  var playerRef = Database$1.ref(Database.database, "players/" + key);
  return Database$1.runTransaction(playerRef, (function (data) {
                var player = Schema.parseWith(data, playerSchema);
                if (player.TAG !== "Ok") {
                  return data;
                }
                var player$1 = player._0;
                var newrecord = Caml_obj.obj_dup(player$1);
                var res = Schema.serializeWith((newrecord.dartsLastGames = getLastGames(player$1.dartsLastGames, isWin), newrecord.dartsLosses = isLoss ? player$1.dartsLosses + 1 | 0 : player$1.dartsLosses, newrecord.dartsWins = isWin ? player$1.dartsWins + 1 | 0 : player$1.dartsWins, newrecord.dartsGames = player$1.dartsGames + 1 | 0, newrecord.dartsLastEloChange = elo - player$1.dartsElo, newrecord.dartsElo = elo, newrecord), playerSchema);
                if (res.TAG === "Ok") {
                  return res._0;
                } else {
                  return data;
                }
              }));
}

function removePlayer(playerKey) {
  return Database$1.remove(Database$1.ref(Database.database, "players/" + playerKey));
}

var bucket = "players";

export {
  bucket ,
  addPlayer ,
  useAllPlayers ,
  fetchAllPlayers ,
  fetchPlayerByKey ,
  playerByKey ,
  updateGameStats ,
  updateDartsGameStats ,
  writePlayer ,
  getLastGames ,
  playersSchema ,
  removePlayer ,
}
/* playerSchema Not a pure module */
