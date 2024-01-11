// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Elo from "./Elo.bs.mjs";
import * as Games from "./Games.bs.mjs";
import * as React from "react";
import * as Schema from "./Schema.bs.mjs";
import * as Players from "./Players.bs.mjs";
import * as Database from "./Database.bs.mjs";
import * as Core__Array from "@rescript/core/src/Core__Array.bs.mjs";
import * as PervasivesU from "rescript/lib/es6/pervasivesU.js";
import * as Core__Option from "@rescript/core/src/Core__Option.bs.mjs";
import * as RescriptCore from "@rescript/core/src/RescriptCore.bs.mjs";
import * as Database$1 from "firebase/database";

var statsSchema = Schema.object(function (s) {
      return {
              totalGames: s.o("games", Schema.$$int, 0),
              totalRedWins: s.o("redWins", Schema.$$int, 0),
              totalBlueWins: s.o("blueWins", Schema.$$int, 0),
              totalAbsoluteWins: s.o("absoluteWins", Schema.$$int, 0)
            };
    });

var empty = {
  totalGames: 0,
  totalRedWins: 0,
  totalBlueWins: 0,
  totalAbsoluteWins: 0
};

var bucket = "stats";

async function fetchStats() {
  var stats = await Database$1.get(Database$1.ref(Database.database, bucket));
  var stats$1 = stats.val();
  if (stats$1 == null) {
    return ;
  }
  var stats$2 = Schema.parseWith(stats$1, statsSchema);
  if (stats$2.TAG === "Ok") {
    return stats$2._0;
  }
  console.error(stats$2._0);
}

function useStats() {
  var match = React.useState(function () {
        return empty;
      });
  var setStats = match[1];
  var statsRef = Database$1.ref(Database.database, bucket);
  React.useEffect((function () {
          return Database$1.onValue(statsRef, (function (snapshot) {
                        var stats = snapshot.val();
                        if (stats == null) {
                          return ;
                        }
                        var stats$1 = Schema.parseWith(stats, statsSchema);
                        if (stats$1.TAG === "Ok") {
                          var stats$2 = stats$1._0;
                          return setStats(function (param) {
                                      return stats$2;
                                    });
                        }
                        console.error(stats$1._0);
                      }), undefined);
        }), []);
  return match[0];
}

async function writeStats(stats) {
  var statsRef = Database$1.ref(Database.database, bucket);
  var data = Schema.serializeWith(stats, statsSchema);
  var data$1;
  if (data.TAG === "Ok") {
    var data$2 = data._0;
    console.log("Log", data$2);
    data$1 = data$2;
  } else {
    data$1 = RescriptCore.panic("Could not serialize stats");
  }
  return await Database$1.set(statsRef, data$1);
}

async function recalculateStats() {
  var games = await Games.fetchAllGames();
  var players = await Players.fetchAllPlayers();
  var playerKeys = Object.keys(players);
  playerKeys.forEach(function (key) {
        var player = Core__Option.getExn(players[key]);
        players[key] = {
          name: player.name,
          wins: player.wins,
          losses: player.losses,
          absoluteWins: player.absoluteWins,
          absoluteLosses: player.absoluteLosses,
          games: player.games,
          teamGoals: player.teamGoals,
          blueGames: player.blueGames,
          redGames: player.redGames,
          blueWins: player.blueWins,
          redWins: player.redWins,
          elo: 1000.0,
          lastEloChange: 0.0,
          key: player.key,
          mattermostHandle: player.mattermostHandle,
          lastGames: []
        };
      });
  var stats = Core__Array.reduce(games, empty, (function (stats, game) {
          var blueWin = game.blueScore > game.redScore;
          var redWin = game.redScore > game.blueScore;
          var isAbsolute = PervasivesU.abs(game.redScore - game.blueScore | 0) === 7;
          var redPlayers = game.redTeam.map(function (key) {
                return Core__Option.getExn(players[key]);
              });
          var bluePlayers = game.blueTeam.map(function (key) {
                return Core__Option.getExn(players[key]);
              });
          var match;
          if (blueWin) {
            match = Elo.calculateScore(bluePlayers, redPlayers);
          } else {
            var match$1 = Elo.calculateScore(redPlayers, bluePlayers);
            match = [
              match$1[1],
              match$1[0],
              match$1[2]
            ];
          }
          match[0].forEach(function (player) {
                var lastGames = player.lastGames;
                lastGames.push(blueWin ? 1 : 0);
                var lastGames$1 = lastGames.slice(-5);
                players[player.key] = {
                  name: player.name,
                  wins: player.wins,
                  losses: player.losses,
                  absoluteWins: player.absoluteWins,
                  absoluteLosses: player.absoluteLosses,
                  games: player.games,
                  teamGoals: player.teamGoals,
                  blueGames: player.blueGames,
                  redGames: player.redGames,
                  blueWins: player.blueWins,
                  redWins: player.redWins,
                  elo: player.elo,
                  lastEloChange: player.lastEloChange,
                  key: player.key,
                  mattermostHandle: player.mattermostHandle,
                  lastGames: lastGames$1
                };
              });
          match[1].forEach(function (player) {
                var lastGames = player.lastGames;
                lastGames.push(redWin ? 1 : 0);
                var lastGames$1 = lastGames.slice(-5);
                players[player.key] = {
                  name: player.name,
                  wins: player.wins,
                  losses: player.losses,
                  absoluteWins: player.absoluteWins,
                  absoluteLosses: player.absoluteLosses,
                  games: player.games,
                  teamGoals: player.teamGoals,
                  blueGames: player.blueGames,
                  redGames: player.redGames,
                  blueWins: player.blueWins,
                  redWins: player.redWins,
                  elo: player.elo,
                  lastEloChange: player.lastEloChange,
                  key: player.key,
                  mattermostHandle: player.mattermostHandle,
                  lastGames: lastGames$1
                };
              });
          return {
                  totalGames: stats.totalGames + 1 | 0,
                  totalRedWins: stats.totalRedWins + (
                    redWin ? 1 : 0
                  ) | 0,
                  totalBlueWins: stats.totalBlueWins + (
                    blueWin ? 1 : 0
                  ) | 0,
                  totalAbsoluteWins: stats.totalAbsoluteWins + (
                    isAbsolute ? 1 : 0
                  ) | 0
                };
        }));
  console.log(stats);
  console.log(players);
  await Promise.all(playerKeys.map(function (key) {
            var player = Core__Option.getExn(players[key]);
            return Players.writePlayer(player);
          }));
  await writeStats(stats);
  return stats;
}

export {
  statsSchema ,
  empty ,
  bucket ,
  fetchStats ,
  useStats ,
  writeStats ,
  recalculateStats ,
}
/* statsSchema Not a pure module */