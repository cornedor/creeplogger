export function panic(message) {
  throw new Error(String(message))
}