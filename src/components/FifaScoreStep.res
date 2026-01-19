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
  let (playerScores, setPlayerScores) = React.useState(_ => Js.Dict.empty())

  let mapUser = mapUser(players, ...)

  let selectedPlayerKeys = Belt.Map.String.keysToArray(selectedUsers)

  let allPlayers =
    selectedPlayerKeys->Array.map(key => Players.playerByKey(players, key)->Option.getExn)

  let sendUpdate = Mattermost.sendFifaUpdate(allPlayers, ...)

  let handleScoreChange = (playerKey, value) => {
    let newScores = Js.Dict.fromArray(Js.Dict.entries(playerScores))
    switch Int.fromString(value) {
    | Some(score) => Js.Dict.set(newScores, playerKey, score)
    | None => Js.Dict.set(newScores, playerKey, 0)
    }
    setPlayerScores(_ => newScores)
  }

  let allScoresEntered = selectedPlayerKeys->Array.every(key =>
    Js.Dict.get(playerScores, key)->Option.isSome
  )

  let saveGame = async () => {
    setIsSaving(_ => true)

    // Create player scores array
    let playerScoresArray =
      selectedPlayerKeys->Array.map(key => {
        let score = Js.Dict.get(playerScores, key)->Option.getOr(0)
        {FifaGames.playerKey: key, score: score}
      })

    let _ = await FifaGames.addFifaGame({
      playerScores: playerScoresArray,
      date: Date.make(),
    })

    // Calculate Elo for FIFA games
    let maxScore =
      playerScoresArray
      ->Array.map(ps => ps.score)
      ->Array.reduce(0, (acc, score) => acc > score ? acc : score)

    // Calculate new Elo ratings for all players
    let updatedPlayers = selectedPlayerKeys->Array.map(key => {
      let player = Players.playerByKey(players, key)->Option.getExn
      let myScore = Js.Dict.get(playerScores, key)->Option.getOr(0)

      // Calculate average opponent ELO
      let opponentPlayers =
        selectedPlayerKeys
        ->Array.filter(k => k != key)
        ->Array.filterMap(k => Players.playerByKey(players, k))

      let opponentAvgElo = switch Array.length(opponentPlayers) {
      | 0 => 1000.0
      | n =>
        opponentPlayers
        ->Array.reduce(0.0, (acc, p) => acc +. p.fifaElo) /. Int.toFloat(n)
      }

      // Calculate average opponent score
      let opponentScores =
        playerScoresArray
        ->Array.filter(ps => ps.playerKey != key)
        ->Array.map(ps => ps.score)

      let opponentAvgScore = switch Array.length(opponentScores) {
      | 0 => 0.0
      | n =>
        opponentScores
        ->Array.reduce(0, (acc, score) => acc + score)
        ->Int.toFloat /. Int.toFloat(n)
      }

      // Calculate actual score (1.0 for win, 0.5 for draw, 0.0 for loss)
      let actualScore = if Int.toFloat(myScore) > opponentAvgScore {
        1.0
      } else if Int.toFloat(myScore) == opponentAvgScore {
        0.5
      } else {
        0.0
      }

      // Standard ELO formula with proper opponent ELO
      let expectedScore = 1.0 /. (1.0 +. 10.0 ** ((opponentAvgElo -. player.fifaElo) /. 400.0))
      let k = 32.0
      let eloChange = k *. (actualScore -. expectedScore)
      let newElo = player.fifaElo +. eloChange

      {...player, fifaElo: newElo, fifaLastEloChange: eloChange}
    })

    // Calculate points earned (using the winner's score)
    setEarnedPoints(_ => maxScore)

    // Update all player stats
    let _ = await Promise.all(
      updatedPlayers->Array.map(async player => {
        let myScore = Js.Dict.get(playerScores, player.key)->Option.getOr(0)
        let totalOpponentScore =
          playerScoresArray
          ->Array.filter(ps => ps.playerKey != player.key)
          ->Array.reduce(0, (acc, ps) => acc + ps.score)

        let avgOpponentScore = switch Array.length(playerScoresArray) - 1 {
        | 0 => 0
        | n => totalOpponentScore / n
        }

        Players.updateFifaGameStats(player.key, myScore, avgOpponentScore, player.fifaElo)
      }),
    )

    let _ = await sendUpdate(playerScores)

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
        <h2 className="font-bold text-3xl"> {React.string("FIFA Scores")} </h2>
        <div className="flex flex-col gap-4 pt-4">
          {selectedPlayerKeys
          ->Array.map(key => {
            let player = Players.playerByKey(players, key)
            switch player {
            | Some(player) =>
              <div key={key} className="flex items-center gap-4">
                <label className="text-xl w-32"> {React.string(player.name)} </label>
                <input
                  type_="number"
                  min="0"
                  className="w-24 px-3 py-2 text-2xl text-white bg-white/10 rounded mr-4"
                  value={Js.Dict.get(playerScores, key)
                  ->Option.map(score => Int.toString(score))
                  ->Option.getOr("")}
                  onChange={e => {
                    let value = (e->ReactEvent.Form.target)["value"]
                    handleScoreChange(key, value)
                  }}
                />
              </div>
            | None => React.null
            }
          })
          ->React.array}
        </div>
      </div>
      <div>
        <h2 className="font-bold text-3xl"> {React.string("Players")} </h2>
        <ol className="pl-5 pt-4 pb-8 list-decimal text-2xl">
          {selectedPlayerKeys->Array.map(mapUser)->React.array}
        </ol>
      </div>
    </div>
  </>
}
