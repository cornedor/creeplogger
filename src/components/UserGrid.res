@react.component
let make = (
  ~selectedUsers,
  ~setSelectedUsers,
  ~reset,
  ~setStep,
  ~players: array<Players.player>,
) => {
  let (showQueueButtons, setShowQueueButtons) = React.useState(_ => false)
  let players = players->Js.Array2.map(item =>
    <GridItem
      key={item.key}
      active={Belt.Map.String.has(selectedUsers, item.key)}
      className={Cn.make([
        "rounded bg-white grid grid-rows-user auto-rows-[1fr] h-[220px] transition-all relative",
        switch Belt.Map.String.get(selectedUsers, item.key) {
        | Some(Players.Blue) => "ring-6 ring-green"
        | Some(Players.Red) => "ring-6 ring-red"
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
      {showQueueButtons
        ? <div className="grid grid-cols-4">
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
        : <div className="grid grid-cols-2">
            <button
              onClick={_ => setSelectedUsers(s => Belt.Map.String.set(s, item.key, Players.Blue))}
              className="bg-[#76e19d] border-none cursor-pointer text-3xl rounded-bl text-black">
              {React.string("Winnaar")}
            </button>
            <button
              onClick={_ => setSelectedUsers(s => Belt.Map.String.set(s, item.key, Players.Red))}
              className="bg-[#ff8686] border-none cursor-pointer text-3xl rounded-br text-black">
              {React.string("Verliezer")}
            </button>
          </div>}
    </GridItem>
  )

  <>
    <Header
      step={LoggerStep.UserSelection}
      onNextStep={() => setStep(step => LoggerStep.getNextStep(step))}
      onReset={reset}
      disabled={Belt.Map.String.size(selectedUsers) <= 1}
      setShowQueueButtons={setShowQueueButtons}
    />
    <div
      className="grid 2xl:grid-cols-5 xl:grid-cols-4 lg:grid-cols-3 md:grid-cols-3 grid-cols-1 gap-10 mt-8 content-padding">
      {React.array(players)}
      <GridItem active={false}>
        <NewPlayerForm />
      </GridItem>
    </div>
  </>
}
