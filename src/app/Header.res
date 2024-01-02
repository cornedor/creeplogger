@module external styles: {..} = "./header.module.css"

@react.component
let make = (~step: LoggerStep.step, ~onNextStep, ~onReset, ~disabled=false) => {
  let (showScores, setShowScores) = React.useState(_ => false)
  let isConnected = FirebaseStatus.useFirebaseStatus()

  let nextLabel = switch step {
  | LoggerStep.UserSelection | LoggerStep.Confirmation => "Verder"
  | LoggerStep.ScoreForm => "Opslaan"
  }

  <>
    <LeaderboardModal show={showScores} setShow={setShowScores} />
    <div className={styles["header"]}>
      <div className={styles["headerGrid"]}>
        <div className={styles["buttonWrapper"]}>
          <button className={styles["iconButton"]} onClick={_ => setShowScores(_ => true)}>
            <ListIcon />
          </button>
        </div>
        <div className={styles["buttonWrapper"]}>
          <span className={isConnected ? styles["connected"] : styles["disconnected"]} />
          <Button variant={Grey} onClick={_ => onReset()}> {React.string("Reset")} </Button>
          <Button variant={Blue} onClick={_ => onNextStep()} disabled={!isConnected || disabled}>
            {React.string(nextLabel)}
          </Button>
        </div>
      </div>
    </div>
  </>
}
