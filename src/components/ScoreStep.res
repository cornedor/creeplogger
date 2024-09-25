@react.component
let make = (
  ~selectedUsers,
  ~setStep,
  ~reset,
  ~blueState,
  ~setBlueState,
  ~redState,
  ~setRedState,
  ~setEarnedPoints,
  ~players,
  ~selectedGame,
  ~setSelectedGame,
) => {
  let (isSaving, setIsSaving) = React.useState(_ => false)
  let redButtons = []
  let blueButtons = []
  for x in 0 to 7 {
    let str = Js.Int.toString(x)
    let _ = Js.Array2.push(
      redButtons,
      <Button
        className="!rounded-full w-[100px] h-[100px] !text-5xl font-semibold"
        key={str}
        variant={redState == x ? Red : Grey}
        onClick={_ => setRedState(_ => x)}>
        {React.string(str)}
      </Button>,
    )
    let _ = Js.Array2.push(
      blueButtons,
      <Button
        className="!rounded-full w-[100px] h-[100px] !text-5xl font-semibold"
        key={str}
        variant={blueState == x ? Blue : Grey}
        onClick={_ => setBlueState(_ => x)}>
        {React.string(str)}
      </Button>,
    )
  }

  let winner = selectedUsers->Belt.Map.String.findFirstBy((_, value) => value == Players.Blue)
  let winner = switch winner {
  | Some((key, _)) => {
      let p = Players.playerByKey(players, key)->Option.getExn
      p.name
    }
  | None => ""
  }
  let loser = selectedUsers->Belt.Map.String.findFirstBy((_, value) => value == Players.Red)
  let loser = switch loser {
  | Some((key, _)) => {
      let p = Players.playerByKey(players, key)->Option.getExn
      p.name
    }
  | None => ""
  }

  let selectedBlueUsers =
    Belt.Map.String.keep(selectedUsers, (_, value) =>
      value == Players.Blue
    )->Belt.Map.String.keysToArray
  let selectedRedUsers =
    Belt.Map.String.keep(selectedUsers, (_, value) =>
      value == Players.Red
    )->Belt.Map.String.keysToArray

  let redPlayers =
    selectedRedUsers->Array.map(key => Players.playerByKey(players, key)->Option.getExn)
  let bluePlayers =
    selectedBlueUsers->Array.map(key => Players.playerByKey(players, key)->Option.getExn)

  let sendCreepsUpdate = Mattermost.sendCreepsUpdate(bluePlayers, redPlayers, ...)

  let saveGame = async (selectedGame: string) => {
    setIsSaving(_ => true)
    let blueState = 1
    let redState = 0
    let _ = await Games.addGame({
      blueScore: blueState,
      redScore: redState,
      redTeam: selectedRedUsers,
      blueTeam: selectedBlueUsers,
      game: selectedGame,
      date: Date.make(),
      modifiers: redPlayers->Array.length == 1 && bluePlayers->Array.length == 1
        ? Some([Games.OneVOne])
        : Some([]),
    })

    let winningTeam = switch (blueState, redState) {
    | (b, r) if b > r => Players.Blue
    | (b, r) if r > b => Players.Red
    | (_b, _r) => panic("Tie not implemented")
    }

    let redPlayers =
      selectedRedUsers->Array.map(key => Players.playerByKey(players, key)->Option.getExn)
    let bluePlayers =
      selectedBlueUsers->Array.map(key => Players.playerByKey(players, key)->Option.getExn)

    let (bluePlayers, redPlayers, points) = switch winningTeam {
    | Blue => Elo.calculateScore(bluePlayers, redPlayers)
    | Red => {
        let (red, blue, points) = Elo.calculateScore(redPlayers, bluePlayers)
        (blue, red, points)
      }
    }

    let roundedPoints = Elo.roundScore(points)

    setEarnedPoints(_ => roundedPoints)

    let _ = await Promise.all(
      Array.map(bluePlayers, async player => {
        Players.updateGameStats(player.key, blueState, redState, Blue, player.elo)
      }),
    )
    let _ = await Promise.all(
      Array.map(redPlayers, async player => {
        Players.updateGameStats(player.key, redState, blueState, Red, player.elo)
      }),
    )

    let _ = await Stats.updateStats(redState, blueState)

    let _ = await sendCreepsUpdate(blueState, redState, roundedPoints)

    setIsSaving(_ => false)
    setStep(step => LoggerStep.getNextStep(step))
  }

  let gameTypes = GameTypes.useGameTypes()->Array.map(gameType =>
    <Button
      // className="!rounded-full w-[100px] h-[100px] !text-5xl font-semibold"
      key={gameType.name}
      variant={selectedGame == Some(gameType.name) ? Blue : Grey}
      onClick={_ => setSelectedGame(_ => Some(gameType.name))}>
      {React.string(gameType.name)}
    </Button>
  )

  <>
    <Header
      step={LoggerStep.ScoreForm}
      onNextStep={() => {
        switch selectedGame {
        | Some(gameType) =>
          let _ = saveGame(gameType)
        | None => ()
        }
      }}
      onReset={reset}
      disabled={isSaving || Option.isNone(selectedGame)}
      setShowQueueButtons={_ => ()}
    />
    <div className="content-padding">
      <h2 className="text-3xl">
        {React.string("In welk spel heeft ")}
        <span className="font-bold"> {winner->React.string} </span>
        {React.string(" van ")}
        <span className="font-bold"> {loser->React.string} </span>
        {React.string(" gewonnen?")}
      </h2>
      <div className="flex flex-col gap-5 max-w-80 mt-4"> {React.array(gameTypes)} </div>
    </div>
  </>
}
