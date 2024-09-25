@module external styles: {..} = "./new-player-form.module.css"

@rhf
type inputs = {name: string}

type formState = Hidden | Visible | Loading | Finished

@react.component
let make = () => {
  let (formState, setFormState) = React.useState(() => Hidden)
  let {register, handleSubmit, reset} = useFormOfInputs()

  let addCreeper = async name => {
    setFormState(_ => Loading)
    let _ = await Players.addPlayer(name)
    setFormState(_ => Finished)
  }

  let onSubmit = (data: inputs) => {
    let _ = addCreeper(data.name)
  }

  React.useEffect(() => {
    switch formState {
    | Finished => {
        reset()
        let timeoutId = setTimeout(() => {
          setFormState(_ => Hidden)
        }, 4000)
        Some(() => clearTimeout(timeoutId))
      }
    | _ => None
    }
  }, [formState])

  let showForm = _ => setFormState(_ => Visible)

  let content = switch formState {
  | Hidden =>
    <button onClick=showForm className={styles["addCreeperButton"]}> {React.string("+")} </button>
  | Visible =>
    <form onSubmit={handleSubmit(onSubmit)} className={styles["form"]}>
      <input
        {...register(Name, ~options={required: true})}
        placeholder="Naam"
        className={styles["input"] ++ " text-black rounded"}
      />
      <Button className={styles["submit"]} type_="submit" variant={Grey}>
        {React.string("Speler toevoegen")}
      </Button>
    </form>
  | Loading => <div className={styles["status"]}> {React.string("...")} </div>
  | Finished => <div className={styles["status"]} onClick=showForm> {React.string("✔︎")} </div>
  }

  <GridItem className={styles["addCreeper"]} active={false}> content </GridItem>
}
