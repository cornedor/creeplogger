// Generated by ReScript, PLEASE EDIT WITH CARE

import * as React from "react";
import * as Button from "./Button.bs.mjs";
import * as Database from "../helpers/Database.bs.mjs";
import * as ListIcon from "./ListIcon.bs.mjs";
import * as AdminIcon from "./AdminIcon.bs.mjs";
import Link from "next/link";
import * as StatsModal from "./StatsModal.bs.mjs";
import * as PieChartIcon from "./PieChartIcon.bs.mjs";
import * as FirebaseStatus from "../helpers/FirebaseStatus.bs.mjs";
import * as LeaderboardModal from "./LeaderboardModal.bs.mjs";
import * as JsxRuntime from "react/jsx-runtime";
import * as HeaderModuleCss from "./header.module.css";

var styles = HeaderModuleCss;

function Header(props) {
  var __disabled = props.disabled;
  var onReset = props.onReset;
  var onNextStep = props.onNextStep;
  var disabled = __disabled !== undefined ? __disabled : false;
  var user = Database.useUser();
  var match = React.useState(function () {
        return false;
      });
  var setShowScores = match[1];
  var match$1 = React.useState(function () {
        return false;
      });
  var setShowStats = match$1[1];
  var isConnected = FirebaseStatus.useFirebaseStatus();
  var nextLabel;
  switch (props.step) {
    case "ScoreForm" :
        nextLabel = "Opslaan";
        break;
    case "UserSelection" :
    case "Confirmation" :
        nextLabel = "Verder";
        break;
    
  }
  var tmp;
  tmp = user === null || user === undefined ? JsxRuntime.jsx(JsxRuntime.Fragment, {}) : JsxRuntime.jsx(Link, {
          href: "/admin",
          children: JsxRuntime.jsx(AdminIcon.make, {}),
          className: "text-white w-[44px] aspect-square text-[26px] flex justify-center items-center -ml-3 rounded-full bg-black/0 transition-all ease-in-out duration-200 shadow-none hover:bg-black/20 hover:shadow-icon-button hover:ring-8 ring-black/20 active:bg-black/20 active:shadow-icon-button active:ring-8 "
        });
  return JsxRuntime.jsxs(JsxRuntime.Fragment, {
              children: [
                JsxRuntime.jsx(LeaderboardModal.make, {
                      show: match[0],
                      setShow: setShowScores
                    }),
                JsxRuntime.jsx(StatsModal.make, {
                      show: match$1[0],
                      setShow: setShowStats
                    }),
                JsxRuntime.jsx("div", {
                      children: JsxRuntime.jsxs("div", {
                            children: [
                              JsxRuntime.jsxs("div", {
                                    children: [
                                      JsxRuntime.jsx("button", {
                                            children: JsxRuntime.jsx(ListIcon.make, {}),
                                            className: "text-white w-[44px] aspect-square text-[26px] flex justify-center items-center -ml-3 rounded-full bg-black/0 transition-all ease-in-out duration-200 shadow-none hover:bg-black/20 hover:shadow-icon-button hover:ring-8 ring-black/20 active:bg-black/20 active:shadow-icon-button active:ring-8 ",
                                            onClick: (function (param) {
                                                setShowScores(function (param) {
                                                      return true;
                                                    });
                                              })
                                          }),
                                      JsxRuntime.jsx("button", {
                                            children: JsxRuntime.jsx(PieChartIcon.make, {}),
                                            className: "text-white w-[44px] aspect-square text-[26px] flex justify-center items-center -ml-3 rounded-full bg-black/0 transition-all ease-in-out duration-200 shadow-none hover:bg-black/20 hover:shadow-icon-button hover:ring-8 ring-black/20 active:bg-black/20 active:shadow-icon-button active:ring-8 ",
                                            onClick: (function (param) {
                                                setShowStats(function (param) {
                                                      return true;
                                                    });
                                              })
                                          }),
                                      tmp
                                    ],
                                    className: "flex items-center gap-5"
                                  }),
                              JsxRuntime.jsxs("div", {
                                    children: [
                                      JsxRuntime.jsx("span", {
                                            className: isConnected ? styles.connected : styles.disconnected
                                          }),
                                      JsxRuntime.jsx(Button.make, {
                                            variant: "Grey",
                                            onClick: (function (param) {
                                                onReset();
                                              }),
                                            children: "Reset"
                                          }),
                                      JsxRuntime.jsx(Button.make, {
                                            variant: "Blue",
                                            onClick: (function (param) {
                                                onNextStep();
                                              }),
                                            children: nextLabel,
                                            disabled: !isConnected || disabled
                                          })
                                    ],
                                    className: "flex items-center gap-5"
                                  })
                            ],
                            className: "flex justify-between flex-wrap text-white gap-5"
                          }),
                      className: "px-10 py-5 sticky top-0 bg-overlay z-40 backdrop-blur-overlay backdrop-saturate-overlay"
                    })
              ]
            });
}

var make = Header;

export {
  make ,
}
/* styles Not a pure module */
