type redScore = int
type blueScore = int

let isRedWin = (redScore: redScore, blueScore: blueScore) => redScore > blueScore
let isBlueWin = (redScore: redScore, blueScore: blueScore) => blueScore > redScore
let isTue = (redScore: redScore, blueScore: blueScore) => redScore == blueScore
let isAbsolute = (redScore: redScore, blueScore: blueScore) => abs(redScore - blueScore) == 7
