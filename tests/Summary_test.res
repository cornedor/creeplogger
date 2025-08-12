open Vitest

let mockGames: Js.Dict.t<Games.game> = Js.Dict.empty()
let _ = Js.Dict.set(mockGames, "g1", {
  blueScore: 5,
  redScore: 6,
  blueTeam: ["a", "b"],
  redTeam: ["c", "d"],
  date: Js.Date.make(),
  modifiers: None,
})
let _ = Js.Dict.set(mockGames, "g2", {
  blueScore: 7,
  redScore: 0,
  blueTeam: ["a"],
  redTeam: ["c"],
  date: Js.Date.make(),
  modifiers: None,
})

let mockPlayers: Js.Dict.t<Players.player> = Js.Dict.empty()
let _ = Js.Dict.set(mockPlayers, "a", {
  name: "Alice",
  wins: 0,
  losses: 0,
  absoluteWins: 0,
  absoluteLosses: 0,
  games: 0,
  teamGoals: 0,
  teamGoalsAgainst: 0,
  blueGames: 0,
  redGames: 0,
  blueWins: 0,
  redWins: 0,
  elo: 1000.0,
  lastEloChange: 0.0,
  key: "a",
  mattermostHandle: None,
  lastGames: [],
  hidden: None,
  mu: 25.0,
  sigma: 8.333,
  ordinal: 0.0,
  lastOpenSkillChange: 0.0,
  dartsElo: 1000.0,
  dartsLastEloChange: 0.0,
  dartsGames: 0,
  dartsWins: 0,
  dartsLosses: 0,
  dartsLastGames: [],
})
let _ = Js.Dict.set(mockPlayers, "b", { ...Js.Dict.unsafeGet(mockPlayers, "a"), name: "Bob", key: "b" })
let _ = Js.Dict.set(mockPlayers, "c", { ...Js.Dict.unsafeGet(mockPlayers, "a"), name: "Carol", key: "c" })
let _ = Js.Dict.set(mockPlayers, "d", { ...Js.Dict.unsafeGet(mockPlayers, "a"), name: "Dave", key: "d" })

describe("Summary.getDailyOverviewWith", () => {
  testAsync("computes creeps/games/score", async () => {
    let result = await Summary.getDailyOverviewWith(
      Games.Daily,
      ~getTimePeriod=_ => Promise.resolve(mockGames),
      ~fetchAllPlayers=_ => Promise.resolve(mockPlayers),
    )

    let get = key =>
      result->Map.get(key)->Option.getExn

    expectIntEqual(get("a").creeps, 1)
    expectIntEqual(get("a").games, 2)
    expectIntEqual(get("a").score, 1)

    expectIntEqual(get("b").creeps, 1)
    expectIntEqual(get("b").games, 1)
    expectIntEqual(get("b").score, -6)

    expectIntEqual(get("c").creeps, 2)
    expectIntEqual(get("c").games, 2)
    expectIntEqual(get("c").score, -1)

    expectIntEqual(get("d").creeps, 0)
    expectIntEqual(get("d").games, 1)
    expectIntEqual(get("d").score, 6)
  })
})