// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Games from "./Games.bs.mjs";
import * as Players from "./Players.bs.mjs";
import * as PervasivesU from "rescript/lib/es6/pervasivesU.js";
import * as Core__Option from "@rescript/core/src/Core__Option.bs.mjs";

async function getDailyOverview(period) {
  var games = await Games.getTimePeriod(period);
  var players = await Players.fetchAllPlayers();
  var creepsMap = new Map();
  Object.values(games).forEach(function (game) {
        var winner = game.blueScore > game.redScore ? "Blue" : "Red";
        var isAbsolute = PervasivesU.abs(game.blueScore - game.redScore | 0) === 7;
        game.blueTeam.forEach(function (player) {
              var match = Core__Option.getOr(creepsMap.get(player), {
                    name: "",
                    creeps: 0,
                    games: 0,
                    score: 0
                  });
              var score = match.score;
              var games = match.games;
              var creeps = match.creeps;
              var match$1;
              match$1 = winner === "Blue" ? [
                  creeps + 0 | 0,
                  games + 1 | 0,
                  score + game.blueScore | 0
                ] : (
                  isAbsolute ? [
                      creeps + 2 | 0,
                      games + 1 | 0,
                      score - game.redScore | 0
                    ] : [
                      creeps + 1 | 0,
                      games + 1 | 0,
                      score - game.redScore | 0
                    ]
                );
              creepsMap.set(player, {
                    name: players[player].name,
                    creeps: match$1[0],
                    games: match$1[1],
                    score: match$1[2]
                  });
            });
        game.redTeam.forEach(function (player) {
              var match = Core__Option.getOr(creepsMap.get(player), {
                    name: "",
                    creeps: 0,
                    games: 0,
                    score: 0
                  });
              var score = match.score;
              var games = match.games;
              var creeps = match.creeps;
              var match$1;
              match$1 = winner === "Blue" ? (
                  isAbsolute ? [
                      creeps + 2 | 0,
                      games + 1 | 0,
                      score - game.blueScore | 0
                    ] : [
                      creeps + 1 | 0,
                      games + 1 | 0,
                      score - game.blueScore | 0
                    ]
                ) : [
                  creeps + 0 | 0,
                  games + 1 | 0,
                  score + game.redScore | 0
                ];
              creepsMap.set(player, {
                    name: players[player].name,
                    creeps: match$1[0],
                    games: match$1[1],
                    score: match$1[2]
                  });
            });
      });
  return creepsMap;
}

function toAPIObject(data) {
  return Object.fromEntries(data.entries());
}

export {
  getDailyOverview ,
  toAPIObject ,
}
/* Games Not a pure module */
