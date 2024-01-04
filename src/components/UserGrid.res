@react.component
let make = (
  ~selectedUsers,
  ~setSelectedUsers,
  ~reset,
  ~setStep,
  ~players: array<Players.player>,
) => {
  let players = players->Js.Array2.map(item =>
    <GridItem
      key={item.key}
      active={Belt.Map.String.has(selectedUsers, item.key)}
      className={Cn.make([
        "rounded bg-white grid grid-rows-user auto-rows-[1fr] h-[220px] transition-all",
        switch Belt.Map.String.get(selectedUsers, item.key) {
        | Some(Players.Blue) => "ring-6 ring-blue"
        | Some(Players.Red) => "ring-6 ring-red"
        | _ => "ring-0"
        },
      ])}>
      <button
        onClick={_ => setSelectedUsers(s => Belt.Map.String.remove(s, item.key))}
        className="text-black text-3xl">
        <b> {React.string(item.name)} </b>
      </button>
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
    </GridItem>
  )

  <>
    <Header
      step={LoggerStep.UserSelection}
      onNextStep={() => setStep(step => LoggerStep.getNextStep(step))}
      onReset={reset}
      disabled={Belt.Map.String.size(selectedUsers) <= 1}
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
