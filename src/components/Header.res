@@directive("'use client';")
@module external styles: {..} = "./header.module.css"

@react.component
let make = (
  ~step: LoggerStep.step,
  ~onNextStep,
  ~onReset,
  ~disabled=false,
  ~setShowQueueButtons,
  ~gameMode,
  ~setGameMode,
  ~searchQuery,
  ~setSearchQuery,
) => {
  let user = Database.useUser()
  let (showScores, setShowScores) = React.useState(_ => false)
  let (showStats, setShowStats) = React.useState(_ => false)
  let (mounted, setMounted) = React.useState(_ => false)

  React.useEffect(() => {
    setMounted(_ => true)
    None
  }, [])

  let isConnected = FirebaseStatus.useFirebaseStatus()

  let nextLabel = switch step {
  | LoggerStep.UserSelection | LoggerStep.Confirmation => "Verder"
  | LoggerStep.ScoreForm => "Opslaan"
  }

  <>
    <LeaderboardModal
      show={showScores} setShow={setShowScores} gameMode={gameMode} setGameMode={setGameMode}
    />
    <StatsModal show={showStats} setShow={setShowStats} />
    <div
      className="px-4 lg:px-10 py-5 sticky top-0 z-40 bg-white/10 border-b border-white/10 backdrop-blur-xl backdrop-saturate-150 shadow-[inset_0_1px_0_rgba(255,255,255,0.1)]">
      <div className="flex justify-between flex-wrap text-white gap-5">
        <div className="flex items-center gap-5">
          <button
            className="text-white w-[44px] aspect-square text-[26px] flex justify-center items-center -ml-3 rounded-full bg-black/0 transition-all ease-in-out duration-200 shadow-none hover:bg-black/20 hover:shadow-icon-button hover:ring-8 ring-black/20 active:bg-black/20 active:shadow-icon-button active:ring-8 plausible-event-name=ShowScores"
            onClick={_ => setShowScores(_ => true)}>
            <ListIcon />
          </button>
          <button
            className="text-white w-[44px] aspect-square text-[26px] flex justify-center items-center -ml-3 rounded-full bg-black/0 transition-all ease-in-out duration-200 shadow-none hover:bg-black/20 hover:shadow-icon-button hover:ring-8 ring-black/20 active:bg-black/20 active:shadow-icon-button active:ring-8 plausible-event-name=ShowStats"
            onClick={_ => setShowStats(_ => true)}>
            <PieChartIcon />
          </button>
          {switch setGameMode {
          | Some(setGameMode) =>
            switch gameMode {
            | Games.Foosball =>
              <button
                className="text-white w-[44px] aspect-square text-[26px] flex justify-center items-center -ml-3 rounded-full bg-black/0 transition-all ease-in-out duration-200 shadow-none hover:bg-black/20 hover:shadow-icon-button hover:ring-8 ring-black/20 active:bg-black/20 active:shadow-icon-button active:ring-8  plausible-event-name=GameModeDarts"
                onClick={_ => setGameMode(_ => Games.Darts)}>
                <SoccerIcon />
              </button>
            | Games.Darts =>
              <button
                className="text-white w-[44px] aspect-square text-[26px] flex justify-center items-center -ml-3 rounded-full bg-black/0 transition-all ease-in-out duration-200 shadow-none hover:bg-black/20 hover:shadow-icon-button hover:ring-8 ring-black/20 active:bg-black/20 active:shadow-icon-button active:ring-8 "
                onClick={_ => setGameMode(_ => Games.Foosball)}>
                <DartsIcon />
              </button>
            }
          | None => <> </>
          }}
          <button
            className="text-white w-[44px] aspect-square text-[26px] hidden justify-center items-center -ml-3 rounded-full bg-black/0 transition-all ease-in-out duration-200 shadow-none hover:bg-black/20 hover:shadow-icon-button hover:ring-8 ring-black/20 active:bg-black/20 active:shadow-icon-button active:ring-8"
            onClick={_ => setShowQueueButtons(show => !show)}>
            <TicketIcon />
          </button>
          {mounted
            ? switch user {
              | Value(_) =>
                <Link
                  href="/admin"
                  className="text-white w-[44px] aspect-square text-[26px] flex justify-center items-center -ml-3 rounded-full bg-black/0 transition-all ease-in-out duration-200 shadow-none hover:bg-black/20 hover:shadow-icon-button hover:ring-8 ring-black/20 active:bg-black/20 active:shadow-icon-button active:ring-8 ">
                  <AdminIcon />
                </Link>
              | _ => <> </>
              }
            : <> </>
          }
        </div>
        <div className="flex-1 flex items-center justify-center">
          {switch (searchQuery, setSearchQuery) {
          | (Some(value), Some(setter)) =>
            <input
              className="w-full max-w-[600px] text-white placeholder-white/70 bg-white/10 border border-white/20 rounded-full px-5 py-2.5 text-lg shadow-inner focus:outline-none focus:ring-2 focus:ring-white/40 focus:border-white/40 backdrop-blur-md"
              placeholder="Zoek speler..."
              value={value}
              onChange={event => {
                let v = ReactEvent.Form.target(event)["value"]
                setter(_ => v)
              }}
            />
          | _ => <> </>
          }}
        </div>
        <div className="fixed lg:relative top-[calc(100vh_-_100%_+_1rem)] right-8 lg:bottom-0 flex items-center gap-5">
          {mounted ? <span className={isConnected ? styles["connected"] : styles["disconnected"]} /> : <span className={styles["disconnected"]}> </span>}
          <Button variant={Grey} onClick={_ => onReset()}> {React.string("Reset")} </Button>
          <Button
            variant={Blue}
            onClick={_ => onNextStep()}
            disabled={!isConnected || disabled}
            className="plausible-event-name=NextStep">
            {React.string(nextLabel)}
          </Button>
        </div>
      </div>
    </div>
  </>
}
