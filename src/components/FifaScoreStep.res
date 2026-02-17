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
  ~setRedState,
  ~setBlueState,
  ~setEarnedPoints,
  ~setPerPlayerDeltas,
  ~players,
  ~gameMode,
) => {
  let (isSaving, setIsSaving) = React.useState(_ => false)
  let (blueScore, setBlueScore) = React.useState(_ => "")
  let (redScore, setRedScore) = React.useState(_ => "")

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

  let blueScoreInt = Int.fromString(blueScore)->Option.getOr(0)
  let redScoreInt = Int.fromString(redScore)->Option.getOr(0)

  let saveGame = async () => {
    setIsSaving(_ => true)

    let _ = await FifaGames.addFifaGame({
      blueScore: blueScoreInt,
      redScore: redScoreInt,
      redTeam: selectedRedUsers,
      blueTeam: selectedBlueUsers,
      date: Date.make(),
    })

    let winningTeam = switch (blueScoreInt, redScoreInt) {
    | (b, r) if b > r => Players.Blue
    | (b, r) if r > b => Players.Red
    | (_b, _r) => panic("Tie not implemented for FIFA")
    }

    // Calculate OpenSkill outcomes
    let (blueOS, redOS, osPoints) = switch winningTeam {
    | Blue => OpenSkillRating.calculateScore(bluePlayers, redPlayers, ~gameMode=Games.Fifa)
    | Red => {
        let (r, b, p) = OpenSkillRating.calculateScore(redPlayers, bluePlayers, ~gameMode=Games.Fifa)
        (b, r, p)
      }
    }

    // Scale points for display (same as foosball)
    let roundedPoints = OpenSkillRating.toDisplayDelta(osPoints)
    setEarnedPoints(_ => Int.toFloat(roundedPoints))

    // Pass scores up to parent for correct winner determination
    setRedState(_ => redScoreInt)
    setBlueState(_ => blueScoreInt)

    // Collect per-player display deltas
    let deltas: Js.Dict.t<int> = Js.Dict.empty()
    blueOS->Array.forEach(player => {
      let delta = OpenSkillRating.toDisplayDelta(player.fifaLastOpenSkillChange)
      Js.Dict.set(deltas, player.key, delta)
    })
    redOS->Array.forEach(player => {
      let delta = OpenSkillRating.toDisplayDelta(player.fifaLastOpenSkillChange)
      Js.Dict.set(deltas, player.key, delta)
    })
    setPerPlayerDeltas(_ => deltas)

    // Update all player stats
    let _ = await Promise.all(
      Array.concat(
        blueOS->Array.map(async player => {
          Players.updateFifaGameStats(
            player.key,
            blueScoreInt,
            redScoreInt,
            player.fifaMu,
            player.fifaSigma,
            player.fifaOrdinal,
            player.fifaLastOpenSkillChange,
          )
        }),
        redOS->Array.map(async player => {
          Players.updateFifaGameStats(
            player.key,
            redScoreInt,
            blueScoreInt,
            player.fifaMu,
            player.fifaSigma,
            player.fifaOrdinal,
            player.fifaLastOpenSkillChange,
          )
        }),
      ),
    )

    // Send Mattermost notification with updated player objects
    let _ = await Mattermost.sendFifaUpdate(blueOS, redOS, blueScoreInt, redScoreInt)

    setIsSaving(_ => false)
    setStep(step => LoggerStep.getNextStep(step))
  }

  let allScoresEntered = blueScore != "" && redScore != ""

  <>
    <Header
      step={LoggerStep.ScoreForm}
      onNextStep={() => {
        let _ = saveGame()
      }}
      onReset={reset}
      disabled={isSaving || !allScoresEntered}
      setShowQueueButtons={_ => ()}
      gameMode
      setGameMode={None}
      setSelectedUsers={None}
      searchQuery={None}
      setSearchQuery={None}
      onMatchFound={None}
    />
    <div className="flex flex-wrap content-padding gap-10">
      <div>
        <h2 className="font-bold text-3xl text-[#ff8686]"> {React.string("Rood")} </h2>
        <ol className="pl-5 pt-4 pb-8 list-decimal text-2xl"> {React.array(redUsers)} </ol>
        <input
          type_="number"
          min="0"
          placeholder="Score"
          className="w-32 px-4 py-3 text-3xl text-white bg-white/10 rounded"
          value={redScore}
          onChange={e => {
            let value = (e->ReactEvent.Form.target)["value"]
            setRedScore(_ => value)
          }}
        />
      </div>
      <div>
        <h2 className="font-bold text-3xl text-[#ffeb3b]"> {React.string("Geel")} </h2>
        <ol className="pl-5 pt-4 pb-8 list-decimal text-2xl"> {React.array(blueUsers)} </ol>
        <input
          type_="number"
          min="0"
          placeholder="Score"
          className="w-32 px-4 py-3 text-3xl text-white bg-white/10 rounded"
          value={blueScore}
          onChange={e => {
            let value = (e->ReactEvent.Form.target)["value"]
            setBlueScore(_ => value)
          }}
        />
      </div>
    </div>
  </>
}
