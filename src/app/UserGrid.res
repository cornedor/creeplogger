@module external styles: {..} = "./user-grid.module.css"

let mapPlayer = (players, key) => {
  let player = Players.playerByKey(players, key)

  switch player {
  | Some(player) => <li> {React.string(player.name)} </li>
  | None => <li> {React.string("...")} </li>
  }
}

@react.component
let make = (
  ~selectedUsers,
  ~setSelectedUsers,
  ~reset,
  ~setStep,
  ~players: array<Players.player>,
) => {
  let players = players->Js.Array2.map(item =>
    <GridItem
      key={item.key}
      active={Belt.Map.String.has(selectedUsers, item.key)}
      className={Cn.make([
        styles["gridItem"],
        switch Belt.Map.String.get(selectedUsers, item.key) {
        | Some(Players.Blue) => styles["blueTeamGridItem"]
        | Some(Players.Red) => styles["redTeamGridItem"]
        | _ => "noTeam"
        },
      ])}>
      <button
        onClick={_ => setSelectedUsers(s => Belt.Map.String.remove(s, item.key))}
        className={styles["button"]}>
        <b className={styles["creepsName"]}> {React.string(item.name)} </b>
      </button>
      <div className={styles["buttons"]}>
        <button
          onClick={_ => setSelectedUsers(s => Belt.Map.String.set(s, item.key, Players.Blue))}
          className={styles["buttonBlue"]}>
          {React.string("Blauw")}
        </button>
        <button
          onClick={_ => setSelectedUsers(s => Belt.Map.String.set(s, item.key, Players.Red))}
          className={styles["buttonRed"]}>
          {React.string("Rood")}
        </button>
      </div>
    </GridItem>
  )

  <>
    <Header
      step={LoggerStep.UserSelection}
      onNextStep={() => setStep(step => LoggerStep.getNextStep(step))}
      onReset={reset}
      disabled={Belt.Map.String.size(selectedUsers) <= 1}
    />
    <div className={styles["usersGrid"]}>
      {React.array(players)}
      <GridItem active={false}>
        <NewPlayerForm />
      </GridItem>
      <div className={styles["gridSpacer"]} />
      <div className={styles["gridSpacer"]} />
      <div className={styles["gridSpacer"]} />
      <div className={styles["gridSpacer"]} />
      <div className={styles["gridSpacer"]} />
    </div>
  </>
}
