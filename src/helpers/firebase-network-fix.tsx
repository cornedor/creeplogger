import { goOffline, goOnline } from "firebase/database";
import { database } from "./Database.bs.mjs";

function onNetworkGone() {
  goOffline(database);
}

function onNetworkBack() {
  // https://github.com/firebase/firebase-ios-sdk/issues/9682
  // We need to go offline first, because realtime database can get stuck when switching between wifi and cellular
  goOffline(database);
  goOnline(database);
}

export function useFirebaseNetworkFix() {
  if (typeof window === "undefined") {
    return () => {};
  }
  window.addEventListener("offline", onNetworkGone);
  window.addEventListener("online", onNetworkBack);

  return () => {
    window.removeEventListener("offline", onNetworkGone);
    window.removeEventListener("online", onNetworkBack);
  };
}
