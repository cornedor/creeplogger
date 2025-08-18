let mapUser = (players, key) => {
  let player = Players.playerByKey(players, key)

  switch player {
  | Some(player) => <li key={key}> {React.string(player.name)} </li>
  | None => <li key={key}> {React.string("...")} </li>
  }
}

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
  ~setPerPlayerDeltas,
  ~players,
  ~gameMode,
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

  let sendCreepsUpdate = Mattermost.sendCreepsUpdate(bluePlayers, redPlayers, ...)

  let saveGame = async () => {
    setIsSaving(_ => true)
    let _ = await Games.addGame({
      blueScore: blueState,
      redScore: redState,
      redTeam: selectedRedUsers,
      blueTeam: selectedBlueUsers,
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

    // Calculate both OpenSkill and Elo outcomes
    let (blueOS, redOS, osPoints) = switch winningTeam {
    | Blue => OpenSkillRating.calculateScore(bluePlayers, redPlayers, ~gameMode=Games.Foosball)
    | Red => {
        let (red, blue, points) = OpenSkillRating.calculateScore(
          redPlayers,
          bluePlayers,
          ~gameMode=Games.Foosball,
        )
        (blue, red, points)
      }
    }

    let (blueElo, redElo, _eloPoints) = switch winningTeam {
    | Blue => Elo.calculateScore(bluePlayers, redPlayers, ~gameMode=Games.Foosball)
    | Red => {
        let (red, blue, points) = Elo.calculateScore(
          redPlayers,
          bluePlayers,
          ~gameMode=Games.Foosball,
        )
        (blue, red, points)
      }
    }

    let roundedPoints = OpenSkillRating.toDisplayDelta(osPoints)

    setEarnedPoints(_ => roundedPoints)

    // Collect per-player display deltas for winners and losers
    let deltas: Js.Dict.t<int> = Js.Dict.empty()
    blueOS->Array.forEach(player => {
      let delta = OpenSkillRating.toDisplayDelta(player.lastOpenSkillChange)
      Js.Dict.set(deltas, player.key, delta)
    })
    redOS->Array.forEach(player => {
      let delta = OpenSkillRating.toDisplayDelta(player.lastOpenSkillChange)
      Js.Dict.set(deltas, player.key, delta)
    })
    setPerPlayerDeltas(_ => deltas)

    // Persist OpenSkill fields
    let _ = await Promise.all(
      Array.map(blueOS, async player => {
        Players.updateOpenSkillGameStats(
          player.key,
          blueState,
          redState,
          Blue,
          player.mu,
          player.sigma,
          player.ordinal,
        )
      }),
    )
    let _ = await Promise.all(
      Array.map(redOS, async player => {
        Players.updateOpenSkillGameStats(
          player.key,
          redState,
          blueState,
          Red,
          player.mu,
          player.sigma,
          player.ordinal,
        )
      }),
    )

    // Persist Elo fields as well
    let _ = await Promise.all(
      Array.map(blueElo, async player => {
        Players.updateGameStats(player.key, blueState, redState, Blue, player.elo)
      }),
    )
    let _ = await Promise.all(
      Array.map(redElo, async player => {
        Players.updateGameStats(player.key, redState, blueState, Red, player.elo)
      }),
    )

    let _ = await Stats.updateStats(redState, blueState)

    let _ = await sendCreepsUpdate(blueState, redState, roundedPoints)

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
      disabled={isSaving}
      setShowQueueButtons={_ => ()}
      gameMode
      setGameMode={None}
      setSelectedUsers={None}
      searchQuery={None}
      setSearchQuery={None}
      onMatchFound={None}
    />
    <div className="flex flex-wrap content-padding gap-20">
      <div>
        <h2 className="font-bold text-xl"> {React.string("Team Blauw")} </h2>
        <ol className="pl-5 pt-4 pb-8 list-decimal"> {React.array(blueUsers)} </ol>
        <div className="grid gap-5 grid-cols-4"> {React.array(blueButtons)} </div>
      </div>
      <div>
        <h2 className="font-bold text-xl"> {React.string("Team Rood")} </h2>
        <ol className="pl-5 pt-4 pb-8 list-decimal"> {React.array(redUsers)} </ol>
        <div className="grid gap-5 grid-cols-4"> {React.array(redButtons)} </div>
      </div>
    </div>
  </>
}
