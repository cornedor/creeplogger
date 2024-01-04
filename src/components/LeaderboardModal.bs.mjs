// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Elo from "../helpers/Elo.bs.mjs";
import * as React from "react";
import * as Button from "./Button.bs.mjs";
import * as Players from "../helpers/Players.bs.mjs";
import * as JsxRuntime from "react/jsx-runtime";

function LeaderboardModal(props) {
  var setShow = props.setShow;
  var match = React.useState(function () {
        return true;
      });
  var setOrder = match[1];
  var order = match[0];
  var players = Players.useAllPlayers("elo", order);
  var position = {
    contents: 0
  };
  var previousScore = {
    contents: 0
  };
  return JsxRuntime.jsxs("div", {
              children: [
                JsxRuntime.jsx("header", {
                      children: JsxRuntime.jsx(Button.make, {
                            variant: "Blue",
                            onClick: (function (param) {
                                setShow(function (s) {
                                      return !s;
                                    });
                              }),
                            children: "Terug"
                          })
                    }),
                JsxRuntime.jsxs("table", {
                      children: [
                        JsxRuntime.jsx("thead", {
                              children: JsxRuntime.jsxs("tr", {
                                    children: [
                                      JsxRuntime.jsx("th", {
                                            children: "#",
                                            className: "text-lg text-left"
                                          }),
                                      JsxRuntime.jsx("th", {
                                            children: "Speler",
                                            className: "text-lg text-left"
                                          }),
                                      JsxRuntime.jsx("th", {
                                            children: JsxRuntime.jsx("button", {
                                                  children: "Score " + (
                                                    order ? "↑" : "↓"
                                                  ),
                                                  onClick: (function (param) {
                                                      setOrder(function (order) {
                                                            return !order;
                                                          });
                                                    })
                                                }),
                                            className: "text-lg text-left"
                                          }),
                                      JsxRuntime.jsx("th", {
                                            children: "Groei",
                                            className: "text-lg text-left"
                                          })
                                    ]
                                  })
                            }),
                        JsxRuntime.jsx("tbody", {
                              children: players.map(function (player) {
                                    var roundedElo = Elo.roundScore(player.elo);
                                    if (roundedElo !== previousScore.contents) {
                                      position.contents = position.contents + 1 | 0;
                                    }
                                    previousScore.contents = roundedElo;
                                    return JsxRuntime.jsxs("tr", {
                                                children: [
                                                  JsxRuntime.jsx("td", {
                                                        children: "#" + position.contents.toString()
                                                      }),
                                                  JsxRuntime.jsx("td", {
                                                        children: player.name
                                                      }),
                                                  JsxRuntime.jsx("td", {
                                                        children: roundedElo
                                                      }),
                                                  JsxRuntime.jsx("td", {
                                                        children: Elo.roundScore(player.lastEloChange),
                                                        className: player.lastEloChange > 0.0 ? "text-green-400" : "text-red-400"
                                                      })
                                                ]
                                              }, player.key);
                                  })
                            })
                      ],
                      className: "table-fixed w-full mt-8"
                    })
              ],
              className: "modal",
              style: {
                transform: props.show ? "translateX(0)" : "translateX(-100%)"
              }
            });
}

var make = LeaderboardModal;

export {
  make ,
}
/* react Not a pure module */
