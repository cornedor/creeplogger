let mapUser = (players, key) => {
  let player = Players.playerByKey(players, key)

  switch player {
  | Some(player) => <li key={key}> {React.string(player.name)} </li>
  | None => <li key={key}> {React.string("...")} </li>
  }
}

let modes = [
  DartsGames.M301,
  DartsGames.M501,
  DartsGames.Bullen,
  DartsGames.Killer,
  DartsGames.AroundTheClock,
]

@react.component
let make = (~selectedUsers, ~setStep, ~reset, ~setEarnedPoints, ~players, ~gameMode) => {
  let (dartMode, setDartMode) = React.useState(_ => None)
  let (isSaving, setIsSaving) = React.useState(_ => false)

  let modeButtons = modes->Array.map(mode => {
    <Button
      className="w-[300px]"
      key={DartsGames.dartsModeToString(mode)}
      variant={dartMode == Some(mode) ? Blue : Grey}
      onClick={_ => setDartMode(_ => Some(mode))}>
      {React.string(DartsGames.dartsModeToString(mode))}
    </Button>
  })

  let mapUser = mapUser(players, ...)

  let selectedBlueUsers =
    Belt.Map.String.keep(selectedUsers, (_, value) =>
      value == Players.Blue
    )->Belt.Map.String.keysToArray
  let selectedRedUsers =
    Belt.Map.String.keep(selectedUsers, (_, value) =>
      value == Players.Red
    )->Belt.Map.String.keysToArray

  let blueUsers = selectedBlueUsers->Array.map(mapUser)

  let redUsers = selectedRedUsers->Array.map(mapUser)

  let redPlayers =
    selectedRedUsers->Array.map(key => Players.playerByKey(players, key)->Option.getExn)
  let bluePlayers =
    selectedBlueUsers->Array.map(key => Players.playerByKey(players, key)->Option.getExn)

  let sendUpdate = Mattermost.sendDartsUpdate(bluePlayers, redPlayers, ...)

  let saveGame = async () => {
    setIsSaving(_ => true)

    let _ = await DartsGames.addDartsGame({
      winners: selectedBlueUsers,
      losers: selectedRedUsers,
      date: Date.make(),
      mode: dartMode->Option.getExn,
    })

    let bluePlayers =
      selectedBlueUsers->Array.map(key => Players.playerByKey(players, key)->Option.getExn)
    let redPlayers =
      selectedRedUsers->Array.map(key => Players.playerByKey(players, key)->Option.getExn)
    let (winners, losers, points) = Elo.calculateScore(
      bluePlayers,
      redPlayers,
      ~gameMode=Games.Darts,
    )

    let roundedPoints = Elo.roundScore(points)

    setEarnedPoints(_ => roundedPoints)

    let _ = await Promise.all(
      Array.map(winners, async player => {
        Players.updateDartsGameStats(player.key, 1, player.elo)
      }),
    )

    let _ = await Promise.all(
      Array.map(losers, async player => {
        Players.updateDartsGameStats(player.key, 0, player.elo)
      }),
    )

    let _ = await Stats.updateDartsStats()

    let _ = await sendUpdate(
      roundedPoints,
      DartsGames.dartsModeToString(dartMode->Option.getOr(DartsGames.Unknown)),
    )

    setIsSaving(_ => false)
    setStep(step => LoggerStep.getNextStep(step))
  }

  <>
    <Header
      step={LoggerStep.ScoreForm}
      onNextStep={() => {
        let _ = saveGame()
      }}
      onReset={reset}
      disabled={isSaving || dartMode->Option.isNone}
      setShowQueueButtons={_ => ()}
      gameMode
      setGameMode={None}
    />
    <div className="flex flex-wrap content-padding gap-20">
      <div>
        <h2 className="font-bold text-3xl"> {React.string("Gamemode")} </h2>
        <div className="flex flex-col gap-4 pt-4"> {React.array(modeButtons)} </div>
      </div>
      <div>
        <h2 className="font-bold text-3xl"> {React.string("Winner")} </h2>
        <ol className="pl-5 pt-4 pb-8 list-decimal text-2xl"> {React.array(blueUsers)} </ol>
      </div>
      <div>
        <h2 className="font-bold text-3xl"> {React.string("Loser")} </h2>
        <ol className="pl-5 pt-4 pb-8 list-decimal text-2xl"> {React.array(redUsers)} </ol>
      </div>
    </div>
  </>
}
