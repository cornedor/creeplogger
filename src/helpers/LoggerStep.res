type step = UserSelection | ScoreForm | Confirmation

let getNextStep = step =>
  switch step {
  | UserSelection => ScoreForm
  | ScoreForm => Confirmation
  | Confirmation => UserSelection
  }
