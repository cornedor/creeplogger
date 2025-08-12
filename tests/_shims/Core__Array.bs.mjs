export function reduce(array, initial, reducer) {
  let acc = initial
  for (const item of array) {
    acc = reducer(acc, item)
  }
  return acc
}

export function toSorted(array, compareFn) {
  return [...array].sort((a, b) => {
    const res = compareFn(a, b)
    if (typeof res === 'number') return res
    return res ? 1 : -1
  })
}