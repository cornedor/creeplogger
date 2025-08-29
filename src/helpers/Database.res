open Firebase

let databaseURL = %raw(`process.env.NEXT_PUBLIC_FIREBASE_DATABASE_URL || process.env.NEXT_PUBLIC_DATABASE_URL`)

let config: firebaseOptions = {
  "apiKey": %raw(`process.env.NEXT_PUBLIC_FIREBASE_API_KEY || process.env.NEXT_PUBLIC_API_KEY`),
  "authDomain": %raw(`process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN || process.env.NEXT_PUBLIC_AUTH_DOMAIN`),
  "databaseURL": databaseURL,
  "projectId": %raw(`process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID || process.env.NEXT_PUBLIC_PROJECT_ID`),
  "storageBucket": %raw(`process.env.NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET || process.env.NEXT_PUBLIC_STORAGE_BUCKET`),
  "messagingSenderId": %raw(`process.env.NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID || process.env.NEXT_PUBLIC_MESSAGING_SENDER_ID`),
  "appId": %raw(`process.env.NEXT_PUBLIC_FIREBASE_APP_ID || process.env.NEXT_PUBLIC_APP_ID`),
  "measurementId": %raw(`process.env.NEXT_PUBLIC_MEASUREMENT_ID`),
}

let app = Firebase.initializeApp(config)

let database = Firebase.Database.getDatabase1(app)

// Connect to emulator if configured
@module("./EmulatorSetup.js") external setupFirebaseEmulator: 'a => bool = "setupFirebaseEmulator"
let _ = setupFirebaseEmulator(database)

let auth = Firebase.Auth.getAuth()

let useUser = () => {
  let (user, setUser) = React.useState(_ => auth["currentUser"])

  React.useEffect(() => {
    let unsubscribe = Firebase.Auth.onAuthStateChanged(
      auth,
      user => {
        setUser(_ => user)
      },
      (),
    )

    Some(unsubscribe)
  }, [])

  user
}
