@module external headerStyles: {..} = "./header.module.css"

@react.component
let make = (
  ~selectedUsers,
  ~setSelectedUsers,
  ~reset,
  ~setStep,
  ~players: array<Players.player>,
  ~gameMode,
  ~setGameMode,
) => {
  let (showQueueButtons, setShowQueueButtons) = React.useState(_ => false)
  let (searchQuery, setSearchQuery) = React.useState(_ => "")
  let (banner, setBanner) = React.useState(() => (None: option<(array<Players.player>, array<Players.player>, float)>))
  let closeBanner = () => setBanner(_ => None)
  let sorted = switch gameMode {
  | Games.Foosball => players->Array.toSorted((a, b) => Int.toFloat(b.games - a.games))
  | Games.Darts => players->Array.toSorted((a, b) => Int.toFloat(b.dartsGames - a.dartsGames))
  }
  let sorted =
    sorted->Array.filter(item =>
      item.name->String.toLowerCase->String.includes(searchQuery->String.toLowerCase)
    )
  let players = sorted->Js.Array2.map(item =>
    <GridItem
      key={item.key}
      active={Belt.Map.String.has(selectedUsers, item.key)}
      className={Cn.make([
        "rounded-2xl bg-white/10 border border-white/10 backdrop-blur-md shadow-lg hover:shadow-2xl hover:-translate-y-1 transform grid grid-rows-user auto-rows-[1fr] h-[160px] lg:h-[220px] transition-all duration-200 ease-out relative overflow-hidden",
        switch (Belt.Map.String.get(selectedUsers, item.key), gameMode) {
        | (Some(Players.Blue), Games.Foosball) => "ring-6 ring-blue"
        | (Some(Players.Blue), Games.Darts) => "ring-6 ring-green-500"
        | (Some(Players.Red), _) => "ring-6 ring-red"
        | _ => "ring-0"
        },
      ])}>
      <button
        onClick={_ => setSelectedUsers(s => Belt.Map.String.remove(s, item.key))}
        className="text-white text-2xl lg:text-3xl min-w-0 max-w-full plausible-event-name=ResetUser">
        <b className="text-ellipsis max-w-full overflow-hidden inline-block p-2 lg:p-3">
          {React.string(item.name)}
        </b>
      </button>
      {switch (gameMode, showQueueButtons) {
      | (_, true) =>
        <div className="grid grid-cols-4">
          <button
            onClick={_ => setSelectedUsers(s => Belt.Map.String.set(s, item.key, Players.Blue))}
            className="bg-gray-400 border-none cursor-pointer text-3xl text-black rounded-bl ring-inset ring-white hover:ring">
            {React.string("15m")}
          </button>
          <button
            onClick={_ => setSelectedUsers(s => Belt.Map.String.set(s, item.key, Players.Blue))}
            className="bg-gray-500 border-none cursor-pointer text-3xl text-black ring-inset ring-white hover:ring">
            {React.string("30m")}
          </button>
          <button
            onClick={_ => setSelectedUsers(s => Belt.Map.String.set(s, item.key, Players.Blue))}
            className="bg-gray-600 border-none cursor-pointer text-3xl text-white ring-inset ring-white hover:ring">
            {React.string("1h")}
          </button>
          <button
            onClick={_ => setSelectedUsers(s => Belt.Map.String.set(s, item.key, Players.Blue))}
            className="bg-gray-700 border-none cursor-pointer text-3xl text-white rounded-br ring-inset ring-white hover:ring">
            {React.string("2h")}
          </button>
        </div>
      | (Games.Darts, _) =>
        <div className="grid grid-cols-2">
          <button
            onClick={_ => setSelectedUsers(s => Belt.Map.String.set(s, item.key, Players.Blue))}
            className="bg-green-400 border-none cursor-pointer text-3xl rounded-bl text-black plausible-event-name=SelectWinner">
            {React.string("Winner")}
          </button>
          <button
            onClick={_ => setSelectedUsers(s => Belt.Map.String.set(s, item.key, Players.Red))}
            className="bg-[#ff8686] border-none cursor-pointer text-3xl rounded-br text-black plausible-event-name=SelectLoser">
            {React.string("Loser")}
          </button>
        </div>
      | (Games.Foosball, _) =>
        <div className="grid grid-cols-2">
          <button
            onClick={_ => setSelectedUsers(s => Belt.Map.String.set(s, item.key, Players.Blue))}
            className="bg-[#86b7ff] border-none cursor-pointer text-xl lg:text-3xl rounded-bl text-black plausible-event-name=SelectBlue">
            {React.string("Blauw")}
          </button>
          <button
            onClick={_ => setSelectedUsers(s => Belt.Map.String.set(s, item.key, Players.Red))}
            className="bg-[#ff8686] border-none cursor-pointer text-xl lg:text-3xl rounded-br text-black plausible-event-name=SelectRed">
            {React.string("Rood")}
          </button>
        </div>
      }}
    </GridItem>
  )

  <>
    <Header
      step={LoggerStep.UserSelection}
      onNextStep={() => setStep(step => LoggerStep.getNextStep(step))}
      onReset={reset}
      disabled={Belt.Map.String.size(selectedUsers) <= 1}
      setShowQueueButtons={setShowQueueButtons}
      gameMode
      setGameMode={Some(setGameMode)}
      setSelectedUsers={Some(setSelectedUsers)}
      searchQuery={Some(searchQuery)}
      setSearchQuery={Some(setSearchQuery)}
      onMatchFound={Some((blueTeam, redTeam, pBlue) => setBanner(_ => Some((blueTeam, redTeam, pBlue))))}
    />
    <div
      className="grid 2xl:grid-cols-5 xl:grid-cols-4 lg:grid-cols-3 md:grid-cols-3 grid-cols-2 gap-4 lg:gap-10 mt-4 lg:mt-8 px-4 lg:content-padding pb-20 md:pb-4">
      {React.array(players)}
      <GridItem active={false}>
        <NewPlayerForm />
      </GridItem>
    </div>
    {switch banner {
    | Some((_blue, _red, pBlue)) =>
      <div className="md:hidden fixed bottom-16 left-2 right-2 z-50">
        <div className={headerStyles["glassHeader"] ++ " px-4 py-4 rounded shadow-[inset_0_1px_0_rgba(255,255,255,0.1)] flex items-center justify-between"}>
          <div className={headerStyles["backdrop"]} />
          <div className={headerStyles["backdropEdge"]} />
          <div className="text-white">
            <strong> {React.string("Match found")} </strong>
            <div className="text-white/80 text-sm">
              {let pctBlue = (pBlue *. 100.0)->Js.Math.round
              ; let pctRed = (100.0 -. pctBlue)->Js.Math.round
              ; React.string("Blue " ++ Js.Int.toString(pctBlue->Float.toInt) ++ "% · Red " ++ Js.Int.toString(pctRed->Float.toInt) ++ "%")}
            </div>
          </div>
          <Button variant={Blue} onClick={_ => closeBanner()}> {React.string("OK")} </Button>
        </div>
      </div>
    | None => React.null
    }}
  </>
}