open Firebase

let config: firebaseOptions = {
  "apiKey": %raw(`process.env.NEXT_PUBLIC_API_KEY`),
  "authDomain": %raw(`process.env.NEXT_PUBLIC_AUTH_DOMAIN`),
  "databaseURL": %raw(`process.env.NEXT_PUBLIC_DATABASE_URL`),
  "projectId": %raw(`process.env.NEXT_PUBLIC_PROJECT_ID`),
  "storageBucket": %raw(`process.env.NEXT_PUBLIC_STORAGE_BUCKET`),
  "messagingSenderId": %raw(`process.env.NEXT_PUBLIC_MESSAGING_SENDER_ID`),
  "appId": %raw(`process.env.NEXT_PUBLIC_APP_ID`),
  "measurementId": %raw(`process.env.NEXT_PUBLIC_MEASUREMENT_ID`),
}

let app = Firebase.initializeApp(config)

let database = Firebase.Database.getDatabase1(app)

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
