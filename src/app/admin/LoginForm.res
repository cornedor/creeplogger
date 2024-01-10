open Firebase

@rhf
type inputs = {email: string, password: string}

@react.component
let make = () => {
  let {register, handleSubmit} = useFormOfInputs()

  let onSubmit = (data: inputs) => {
    let _ = Firebase.Auth.signInWithEmailAndPassword(Database.auth, data.email, data.password)
  }

  <form onSubmit={handleSubmit(onSubmit)} className="flex gap-2 flex-col w-96">
    <input
      {...register(Email, ~options={required: true})}
      type_="email"
      placeholder="E-mail"
      className="p-2 rounded border-white/20 border"
    />
    <input
      {...register(Password, ~options={required: true})}
      type_="password"
      placeholder="Password"
      className="p-2 rounded border-white/20 border"
    />
    <Button type_="submit" variant={Blue}> {React.string("Login")} </Button>
  </form>
}
