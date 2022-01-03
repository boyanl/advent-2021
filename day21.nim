import strscans
import rationals
import tables

type Die = object
  n: int
  sides: int

type State = tuple[pos1: int, pos2: int, score1: int, score2: int, turn: int]

func roll(d: var Die): int =
  var val = d.n
  d.n = d.n mod d.sides + 1
  return val

func deterministicDie(): Die =
  return Die(n: 1, sides: 100)

func simulate(startingPositions: (int, int), d: Die): (State, int) =
  var die = d
  var state: State = (pos1: startingPositions[0], pos2: startingPositions[1], score1: 0, score2: 0, turn: 1)
  var rolledCnt = 0
  while true:
    var newState = state
    let sum = die.roll + die.roll + die.roll
    if state.turn == 1:
      newState.pos1 = (newState.pos1 + sum - 1) mod 10 + 1
      newState.score1 += newState.pos1
    elif state.turn == 2:
      newState.pos2 = (newState.pos2 + sum - 1) mod 10 + 1
      newState.score2 += newState.pos2
    rolledCnt += 3
    if newState.score1 >= 1000 or newState.score2 >= 1000:
      return (newState, rolledCnt)
    newState.turn = 3 - state.turn
    state = newState

func nextPosition(currentPos, roll: int): int =
  return (currentPos + roll - 1) mod 10 + 1

proc getStartingPositions(): (int, int) =
  let
    line1 = stdin.readLine
    line2 = stdin.readLine
  var pos1, pos2: int
  assert scanf(line1, "Player 1 starting position: $i", pos1)
  assert scanf(line2, "Player 2 starting position: $i", pos2)
  return(pos1, pos2)


var weights = {3: 1, 4: 3, 5: 6, 6: 7, 7: 6, 8: 3, 9: 1}.toTable
var counts = initTable[State, (int64, int64)]()
proc winCounts(s: State): (int64, int64) =
  if s in counts:
    return counts[s]
  for roll in 3..9:
    var nextState = s
    var finished = false
    if s.turn == 1:
      nextState.pos1 = nextPosition(s.pos1, roll)
      nextState.score1 += nextState.pos1
      if nextState.score1 >= 21:
        result[0] += weights[roll]
        finished = true
    else:
      nextState.pos2 = nextPosition(s.pos2, roll)
      nextState.score2 += nextState.pos2
      if nextState.score2 >= 21:
        result[1] += weights[roll]
        finished = true
    nextState.turn = 3 - s.turn
    if not finished:
      let (w1, w2) = winCounts(nextState)
      result[0] += w1 * weights[roll]
      result[1] += w2 * weights[roll]
  counts[s] = result
  return result

let (pos1, pos2) = getStartingPositions()

proc partOne() =
  let (finalState, rolled) = simulate((pos1, pos2), deterministicDie())
  let losingScore = if finalState.turn == 1: finalState.score2 else: finalState.score1
  let answer = losingScore * rolled
  echo(answer)

proc partTwo() =
  let initialState = (pos1: pos1, pos2: pos2, score1: 0, score2: 0, turn: 1)
  let winCnts = winCounts(initialState)
  echo("Win counts: ", winCnts)

partTwo()