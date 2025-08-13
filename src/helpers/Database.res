open Firebase

let databaseURL = %raw(`process.env.NEXT_PUBLIC_DATABASE_URL`)

let config: firebaseOptions = {
  "apiKey": %raw(`process.env.NEXT_PUBLIC_API_KEY`),
  "authDomain": %raw(`process.env.NEXT_PUBLIC_AUTH_DOMAIN`),
  "databaseURL": databaseURL,
  "projectId": %raw(`process.env.NEXT_PUBLIC_PROJECT_ID`),
  "storageBucket": %raw(`process.env.NEXT_PUBLIC_STORAGE_BUCKET`),
  "messagingSenderId": %raw(`process.env.NEXT_PUBLIC_MESSAGING_SENDER_ID`),
  "appId": %raw(`process.env.NEXT_PUBLIC_APP_ID`),
  "measurementId": %raw(`process.env.NEXT_PUBLIC_MEASUREMENT_ID`),
}

/* Avoid initializing Firebase during build/SSR to prevent invalid URL errors */
let isClient: bool = %raw("typeof window !== 'undefined'")
external unsafeCast: 'a => 'b = "%identity"

let app = if isClient {
  Firebase.initializeApp(config)
} else {
  unsafeCast(())
}

let database = if isClient {
  Firebase.Database.getDatabase1(app)
} else {
  unsafeCast(())
}

let auth = if isClient {
  Firebase.Auth.getAuth()
} else {
  unsafeCast(())
}

let useUser = () => {
  let initialUser = if isClient { auth["currentUser"] } else { Js.Nullable.null }
  let (user, setUser) = React.useState(_ => initialUser)

  React.useEffect(() => {
    if isClient {
      let unsubscribe = Firebase.Auth.onAuthStateChanged(
        auth,
        user => {
          setUser(_ => user)
        },
        (),
      )
      Some(unsubscribe)
    } else {
      None
    }
  }, [])

  user
}
