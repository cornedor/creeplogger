type firebaseOptions = {
  "apiKey": string,
  "authDomain": string,
  "databaseURL": string,
  "projectId": string,
  "storageBucket": string,
  "messagingSenderId": string,
  "appId": string,
  "measurementId": string,
}

@genType
type firebaseApp = {
  "name": string,
  "automaticDataCollectionEnabled": bool,
  "options": firebaseOptions,
}

type authConfig = {
  "apiKey": string,
  "apiHost": string,
  "apiScheme": string,
  "tokenApiHost": string,
  "sdkClientVersion": string,
  "authDomain": string,
}

type emulatorConfig = {"protocol": string, "host": string, "port": Nullable.t<int>}

type authSettings = {"appVerificationDisabledForTesting": bool}

type userMetadata = {"creationTime": Nullable.t<string>, "lastSignInTime": Nullable.t<string>}

type userInfo = {
  "displayName": Nullable.t<string>,
  "email": Nullable.t<string>,
  "phoneNumber": Nullable.t<string>,
  "photoURL": Nullable.t<string>,
  "providerId": string,
  "uid": string,
}

type user = {
  ...userInfo,
  "emailVerified": bool,
  "isAnonymous": bool,
  "metadata": userMetadata,
  "providerData": array<userInfo>,
  "refreshToken": string,
  "tenantId": Nullable.t<string>,
}

type userCredential = {
  "user": user,
  "providerId": Nullable.t<string>,
  "operationType": Nullable.t<[#link | #reauthenticate | #signIn]>,
}

@genType
type auth = {
  "app": firebaseApp,
  "name": string,
  "config": authConfig,
  "languageCode": Nullable.t<string>,
  "tenantId": Nullable.t<string>,
  "settings": authSettings,
  "currentUser": Nullable.t<user>,
  "emulatorConfig": Nullable.t<emulatorConfig>,
}

@genType
type database = {"app": firebaseApp, "type": [#database]}

@genType
type rec databaseReference = {
  "ref": databaseReference,
  "isEqual": Nullable.t<query> => bool,
  "toJSON": unit => string,
  "toString": unit => string,
  "key": Nullable.t<string>,
  "parent": Nullable.t<databaseReference>,
  "root": Nullable.t<databaseReference>,
}
and query = {
  "ref": databaseReference,
  "isEqual": Nullable.t<query> => bool,
  "toJSON": unit => string,
  "toString": unit => string,
}

type queryConstraintType = [
  | #endAt
  | #endBefore
  | #startAt
  | #startAfter
  | #limitToFirst
  | #limitToLast
  | #orderByChild
  | #orderByKey
  | #orderByPriority
  | #orderByValue
  | #equalTo
]
type queryConstraint = {\"type": queryConstraintType}

type priority = String(string) | Number(int) | Float(float)

type rec dataSnapshot = {
  "ref": databaseReference,
  "priority": Nullable.t<priority>,
  "key": Nullable.t<string>,
  "size": int,
}

type listenOptions = {onlyOnce?: bool}

type unsubscribe = unit => unit

type observer<'a> = {"next": 'a => unit, "error": Js.Exn.t => unit, "complete": unit => unit}

module Firebase = {
  @module("firebase/app")
  external initializeApp: firebaseOptions => firebaseApp = "initializeApp"

  module Auth = {
    @module("firebase/auth")
    external getAuth: unit => auth = "getAuth"
    @module("firebase/auth")
    external setPersistence: (auth, [#SESSION | #LOCAL | #NONE]) => Js.Promise.t<unit> =
      "setPersistence"
    @module("firebase/auth")
    external onAuthStateChanged: (
      auth,
      Nullable.t<user> => 'a,
      ~error: Js.Exn.t => unit=?,
      ~complete: unit => unit=?,
      unit,
    ) => unsubscribe = "onAuthStateChanged"
    @module("firebase/auth")
    external observeOnAuthStateChange: (auth, observer<Nullable.t<user>>) => unsubscribe =
      "onAuthStateChanged"
    @module("firebase/auth")
    external beforeAuthStateChanged: (
      auth,
      Nullable.t<user> => unit,
      ~onAbort: unit => unit=?,
      unit,
    ) => unsubscribe = "onAuthStateChanged"
    @module("firebase/auth")
    external onIdTokenChanged: (
      auth,
      Nullable.t<user> => 'a,
      ~error: Js.Exn.t => unit=?,
      ~complete: unit => unit=?,
      unit,
    ) => unsubscribe = "onIdTokenChanged"
    @module("firebase/auth")
    external observeOnIdTokenChange: (auth, observer<Nullable.t<user>>) => unsubscribe =
      "onIdTokenChanged"
    @module("firebase/auth")
    external updateCurrentUser: (auth, Nullable.t<user>) => Js.Promise.t<unit> =
      "updateCurrentUser"
    @module("firebase/auth")
    external useDeviceLanguage: auth => unit = "useDeviceLanguage"
    @module("firebase/auth")
    external signOut: auth => Js.Promise.t<unit> = "signOut"

    @module("firebase/auth")
    external createUserWithEmailAndPassword: (auth, string, string) => Js.Promise.t<user> =
      "createUserWithEmailAndPassword"
    @module("firebase/auth")
    external deleteUser: auth => Js.Promise.t<unit> = "deleteUser"
    @module("firebase/auth")
    external getIdToken: (user, bool) => Js.Promise.t<string> = "getIdToken"

    @module("firebase/auth")
    external signInWithEmailAndPassword: (auth, string, string) => Js.Promise.t<userCredential> =
      "signInWithEmailAndPassword"
  }

  module Database = {
    @module("firebase/database")
    external getDatabase: unit => database = "getDatabase"
    @module("firebase/database")
    external getDatabase1: firebaseApp => database = "getDatabase"
    @module("firebase/database")
    external getDatabase2: (firebaseApp, string) => database = "getDatabase"

    @module("firebase/database")
    external ref: database => databaseReference = "ref"
    @module("firebase/database")
    external refPath: (database, string) => databaseReference = "ref"

    @module("firebase/database")
    external query1: (databaseReference, queryConstraint) => databaseReference = "query"
    @module("firebase/database")
    external query2: (databaseReference, queryConstraint, queryConstraint) => databaseReference =
      "query"
    @module("firebase/database")
    external query3: (
      databaseReference,
      queryConstraint,
      queryConstraint,
      queryConstraint,
    ) => databaseReference = "query"

    @module("firebase/database")
    external endAt: 'a => queryConstraint = "endAt"
    @module("firebase/database")
    external endBefore: 'a => queryConstraint = "endBefore"
    @module("firebase/database")
    external startAt: 'a => queryConstraint = "startAt"
    @module("firebase/database")
    external startAfter: 'a => queryConstraint = "startAfter"
    @module("firebase/database")
    external limitToFirst: 'a => queryConstraint = "limitToFirst"
    @module("firebase/database")
    external limitToLast: 'a => queryConstraint = "limitToLast"
    @module("firebase/database")
    external orderByChild: 'a => queryConstraint = "orderByChild"
    @module("firebase/database")
    external orderByKey: 'a => queryConstraint = "orderByKey"
    @module("firebase/database")
    external orderByPriority: 'a => queryConstraint = "orderByPriority"
    @module("firebase/database")
    external orderByValue: 'a => queryConstraint = "orderByValue"
    @module("firebase/database")
    external equalTo: 'a => queryConstraint = "equalTo"

    @module("firebase/database")
    external onValue: (
      databaseReference,
      dataSnapshot => 'a,
      ~onError: Js.Exn.t => 'a=?,
      unit,
    ) => unsubscribe = "onValue"
    @module("firebase/database")
    external onValueOnce: (
      databaseReference,
      dataSnapshot => 'a,
      ~onError: Js.Exn.t => 'a=?,
      ~options: listenOptions=?,
      unit,
    ) => unsubscribe = "onValue"
    @module("firebase/database")
    external pushValue: (databaseReference, 'a) => Js.Promise.t<databaseReference> = "push"
    @module("firebase/database")
    external set: (databaseReference, 'a) => Js.Promise.t<unit> = "set"
    @module("firebase/database")
    external remove: databaseReference => Js.Promise.t<unit> = "remove"
    @module("firebase/database")
    external get: databaseReference => Js.Promise.t<'a> = "get"
    @module("firebase/database")
    external runTransaction: (databaseReference, 'a) => 'a = "runTransaction"

    module Snapshot = {
      type t

      @send external child: dataSnapshot => dataSnapshot = "child"
      @send external exists: dataSnapshot => bool = "exists"
      @send external exportVal: dataSnapshot => JSON.t = "exportVal"
      @send external forEach: (dataSnapshot, dataSnapshot => bool) => bool = "forEach"
      @send external hasChild: (dataSnapshot, string) => bool = "hasChild"
      @send external hasChildren: dataSnapshot => bool = "hasChildren"
      @send external toJSON: dataSnapshot => Nullable.t<JSON.t> = "toJSON"
      @send external val: dataSnapshot => Nullable.t<JSON.t> = "val"
      @val external snapshot: dataSnapshot = "snapshot"
    }
  }
}

// type testShape = {"foo": string, "bar": string}

// type dd = TestData(testShape)

// let test = () => {
//   let db = Firebase.Database.getDatabase()
//   let r = Firebase.Database.ref(db)
//   let onError = e => Js.log(e)
//   let unsub = Firebase.Database.onValue(
//     r,
//     myData => {
//       let _ = Firebase.Database.Snapshot.forEach(myData, _s => {
//         false
//       })

//       let data = Firebase.Database.Snapshot.val(myData)

//       switch Js.Nullable.toOption(data) {
//       | Some(data) =>
//         switch Js.Json.classify(data) {
//         | Js.Json.JSONString(value) => Js.log(value)
//         | _ => failwith("Expected a string")
//         }

//       | _ => ()
//       }
//     },
//     ~onError,
//   )

//   unsub()
// }
