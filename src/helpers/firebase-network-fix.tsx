import { goOffline, goOnline, Database as RTDB } from "firebase/database";
import { database } from "./Database.bs.mjs";

function onNetworkGone() {
  if (typeof window === "undefined" || !database) return;
  goOffline((database as unknown) as RTDB);
}

function onNetworkBack() {
  if (typeof window === "undefined" || !database) return;
  // https://github.com/firebase/firebase-ios-sdk/issues/9682
  // We need to go offline first, because realtime database can get stuck when switching between wifi and cellular
  goOffline((database as unknown) as RTDB);
  goOnline((database as unknown) as RTDB);
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
