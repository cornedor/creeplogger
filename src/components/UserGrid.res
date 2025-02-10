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
  let players = players->Js.Array2.map(item =>
    <GridItem
      key={item.key}
      active={Belt.Map.String.has(selectedUsers, item.key)}
      className={Cn.make([
        "rounded bg-white grid grid-rows-user auto-rows-[1fr] h-[220px] transition-all relative",
        switch (Belt.Map.String.get(selectedUsers, item.key), gameMode) {
        | (Some(Players.Blue), Games.Foosball) => "ring-6 ring-blue"
        | (Some(Players.Blue), Games.Darts) => "ring-6 ring-green-500"
        | (Some(Players.Red), _) => "ring-6 ring-red"
        | _ => "ring-0"
        },
      ])}>
      <button
        onClick={_ => setSelectedUsers(s => Belt.Map.String.remove(s, item.key))}
        className="text-black text-3xl min-w-0 max-w-full">
        <b className="text-ellipsis max-w-full overflow-hidden inline-block p-2">
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
            className="bg-green-400 border-none cursor-pointer text-3xl rounded-bl text-black">
            {React.string("Winner")}
          </button>
          <button
            onClick={_ => setSelectedUsers(s => Belt.Map.String.set(s, item.key, Players.Red))}
            className="bg-[#ff8686] border-none cursor-pointer text-3xl rounded-br text-black">
            {React.string("Loser")}
          </button>
        </div>
      | (Games.Foosball, _) =>
        <div className="grid grid-cols-2">
          <button
            onClick={_ => setSelectedUsers(s => Belt.Map.String.set(s, item.key, Players.Blue))}
            className="bg-[#86b7ff] border-none cursor-pointer text-3xl rounded-bl text-black">
            {React.string("Blauw")}
          </button>
          <button
            onClick={_ => setSelectedUsers(s => Belt.Map.String.set(s, item.key, Players.Red))}
            className="bg-[#ff8686] border-none cursor-pointer text-3xl rounded-br text-black">
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
    />
    <div
      className="grid 2xl:grid-cols-5 xl:grid-cols-4 lg:grid-cols-3 md:grid-cols-3 grid-cols-2 gap-10 mt-8 content-padding">
      {React.array(players)}
      <GridItem active={false}>
        <NewPlayerForm />
      </GridItem>
    </div>
  </>
}
