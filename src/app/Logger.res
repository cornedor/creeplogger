@@directive("'use client';")
type nextFont = {className: string}
@module("../helpers/fonts") external inter: nextFont = "inter"

@react.component
let make = (~players: array<Players.player>) => {
  let (gameMode, setGameMode) = React.useState(_ => Games.Foosball)
  let livePlayers = Players.useAllPlayers(~orderBy=#games, ~asc=false)
  let ssrPlayers = players
  let useLive = Array.length(livePlayers) >= Array.length(ssrPlayers)
  let players = useLive ? livePlayers : ssrPlayers
  let (selectedUsers, setSelectedUsers) = React.useState(_ => Belt.Map.String.empty)
  let (step, setStep) = React.useState(_ => LoggerStep.UserSelection)
  let (redState, setRedState) = React.useState(_ => -1)
  let (blueState, setBlueState) = React.useState(_ => -1)
  let (earnedPoints, setEarnedPoints) = React.useState(_ => 0)

  let reset = () => {
    setStep(_ => LoggerStep.UserSelection)
    setSelectedUsers(_ => Belt.Map.String.empty)
    setBlueState(_ => -1)
    setRedState(_ => -1)
    setEarnedPoints(_ => 0)
  }

  let _ = Games.getTimePeriod(Daily)

  let winnerTeam = redState > blueState ? Players.Red : Players.Blue
  let winners =
    Belt.Map.String.keep(selectedUsers, (_, value) =>
      value == winnerTeam
    )->Belt.Map.String.keysToArray

  let stepComponent = switch (step, gameMode) {
  | (UserSelection, _) =>
    <UserGrid selectedUsers setSelectedUsers reset setStep players gameMode setGameMode />
  | (ScoreForm, Games.Darts) =>
    <DartsGameModeStep selectedUsers setStep reset setEarnedPoints players gameMode />
  | (ScoreForm, _) =>
    <ScoreStep
      selectedUsers
      setStep
      reset
      redState
      setRedState
      blueState
      setBlueState
      setEarnedPoints
      players
      gameMode
    />
  | (Confirmation, _) => <ConfirmationStep winners={winners} score={earnedPoints} reset players />
  }

  <div
    className="bg-blobs bg-darkbg bg-no-repeat bg-left text-white flex flex-col min-h-screen w-full">
    stepComponent
  </div>
}
