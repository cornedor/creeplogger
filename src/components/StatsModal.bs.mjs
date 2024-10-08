// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Stats from "../helpers/Stats.bs.mjs";
import * as Button from "./Button.bs.mjs";
import * as JsxRuntime from "react/jsx-runtime";

function StatsModal(props) {
  var setShow = props.setShow;
  var stats = Stats.useStats();
  var blue = stats.totalBlueWins;
  var red = stats.totalRedWins;
  var bluePercentages = (blue / (blue + red) * 100).toString();
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
                JsxRuntime.jsx("em", {
                      children: "WIP: Misschien komt hier ooit wat mooiers voor, maar hier is alvast wat.",
                      className: "py-2 inline-block"
                    }),
                JsxRuntime.jsxs("ul", {
                      children: [
                        JsxRuntime.jsxs("li", {
                              children: [
                                JsxRuntime.jsx("strong", {
                                      children: "Total games: "
                                    }),
                                JsxRuntime.jsx("span", {
                                      children: stats.totalGames
                                    })
                              ],
                              className: "p-2 rounded border-white/20 border bg-white/5 flex justify-between"
                            }),
                        JsxRuntime.jsxs("li", {
                              children: [
                                JsxRuntime.jsx("strong", {
                                      children: "Blue wins: "
                                    }),
                                JsxRuntime.jsx("span", {
                                      children: stats.totalBlueWins
                                    })
                              ],
                              className: "p-2 rounded border-white/20 border bg-white/5 flex justify-between"
                            }),
                        JsxRuntime.jsxs("li", {
                              children: [
                                JsxRuntime.jsx("strong", {
                                      children: "Red wins: "
                                    }),
                                JsxRuntime.jsx("span", {
                                      children: stats.totalRedWins
                                    })
                              ],
                              className: "p-2 rounded border-white/20 border bg-white/5 flex justify-between"
                            }),
                        JsxRuntime.jsxs("li", {
                              children: [
                                JsxRuntime.jsx("strong", {
                                      children: "7-0's: "
                                    }),
                                JsxRuntime.jsx("span", {
                                      children: stats.totalAbsoluteWins
                                    })
                              ],
                              className: "p-2 rounded border-white/20 border bg-white/5 flex justify-between"
                            })
                      ],
                      className: "grid grid-cols-2 gap-2"
                    }),
                JsxRuntime.jsx("div", {
                      children: JsxRuntime.jsx("div", {
                            className: "rounded-full aspect-square w-[300px] my-4 mx-auto shadow-inner shadow-orange-50",
                            style: {
                              background: "conic-gradient(#86b7ff, #1c77ff " + bluePercentages + "%, #ff3e6e " + bluePercentages + "%, #ff0055)"
                            }
                          })
                    }),
                JsxRuntime.jsx("div", {
                      className: "flex-1"
                    }),
                JsxRuntime.jsx("div", {
                      children: JsxRuntime.jsx("a", {
                            children: "Contribute on GitHub",
                            href: "https://github.com/cornedor/creeplogger"
                          })
                    })
              ],
              className: "modal flex flex-col",
              style: {
                transform: props.show ? "translateX(0)" : "translateX(-100%)"
              }
            });
}

var make = StatsModal;

export {
  make ,
}
/* Stats Not a pure module */
