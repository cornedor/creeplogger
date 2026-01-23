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
  ~setEarnedPoints,
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

  let sendUpdate = Mattermost.sendFifaUpdate(bluePlayers, redPlayers, ...)

  let blueScoreInt = Int.fromString(blueScore)->Option.getOr(0)
  let redScoreInt = Int.fromString(redScore)->Option.getOr(0)

  let saveGame = async () => {
    setIsSaving(_ => true)

    let gameData: FifaGames.fifaGame = {
      blueScore: blueScoreInt,
      redScore: redScoreInt,
      redTeam: selectedRedUsers,
      blueTeam: selectedBlueUsers,
      date: Date.make(),
    }

    Console.log("FIFA Game - Saving game to Firebase:")
    Console.log2("Game data:", gameData)

    let _ = await FifaGames.addFifaGame(gameData)

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

    setEarnedPoints(_ => osPoints)

    // Update all player stats
    Console.log("FIFA Game - Updating player stats:")
    blueOS->Array.forEach(player => {
      Console.log2("Blue player update:", {
        "key": player.key,
        "name": player.name,
        "goalsFor": blueScoreInt,
        "goalsAgainst": redScoreInt,
        "fifaMu": player.fifaMu,
        "fifaSigma": player.fifaSigma,
        "fifaOrdinal": player.fifaOrdinal,
        "fifaLastOpenSkillChange": player.fifaLastOpenSkillChange,
      })
    })
    redOS->Array.forEach(player => {
      Console.log2("Red player update:", {
        "key": player.key,
        "name": player.name,
        "goalsFor": redScoreInt,
        "goalsAgainst": blueScoreInt,
        "fifaMu": player.fifaMu,
        "fifaSigma": player.fifaSigma,
        "fifaOrdinal": player.fifaOrdinal,
        "fifaLastOpenSkillChange": player.fifaLastOpenSkillChange,
      })
    })

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

    let _ = await sendUpdate(blueScoreInt, redScoreInt)

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
        <h2 className="font-bold text-3xl text-[#86b7ff]"> {React.string("Blauw")} </h2>
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
    </div>
  </>
}
