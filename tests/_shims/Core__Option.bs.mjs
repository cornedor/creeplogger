export function getOr(option, defaultValue) {
  return option ?? defaultValue
}

export function getExn(option) {
  if (option == null) throw new Error('Option.getExn: None')
  return option
}