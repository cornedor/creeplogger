type expectation

@module("vitest") external _describe: (string, unit => unit) => unit = "describe"
@module("vitest") external _test: (string, unit => unit) => unit = "it"
@module("vitest") external _testAsync: (string, unit => Js.Promise.t<unit>) => unit = "it"
@module("vitest") external _expect: 'a => expectation = "expect"

@send external _toBe: (expectation, 'a) => unit = "toBe"
@send external _toBeGreaterThanFloat: (expectation, float) => unit = "toBeGreaterThan"
@send external _toBeLessThanFloat: (expectation, float) => unit = "toBeLessThan"
@send external _toBeCloseToFloat: (expectation, float) => unit = "toBeCloseTo"

let describe = _describe
let test = _test
let testAsync = _testAsync

let expectIntEqual = (actual: int, expected: int) => _toBe(_expect(actual), expected)
let expectFloatEqual = (actual: float, expected: float) => _toBe(_expect(actual), expected)
let expectFloatGreater = (actual: float, expected: float) => _toBeGreaterThanFloat(_expect(actual), expected)
let expectFloatLess = (actual: float, expected: float) => _toBeLessThanFloat(_expect(actual), expected)
let expectFloatCloseTo = (actual: float, expected: float) => _toBeCloseToFloat(_expect(actual), expected)