import strutils
import sequtils

type State = seq[string]

proc readInitialState(): State =
  return toSeq(stdin.lines)

proc displayState(s: State) =
  for line in s:
    echo(line)
  echo("")


# Returns how many "sea cucumbers" moved during the step
func step(curr: State, next: var State): int =
  let
    h = len(curr)
    w = curr[0].len

  var tmp = curr
  for i in 0..<h:
    for j in 0..<w:
      var dir: (int, int)
      case curr[i][j]:
      of '<':
        dir = (-1, 0)
      of '>':
        dir = (1, 0)
      else:
        continue

      let nextPos = ((j + dir[0] + w) mod w, i)
      if curr[nextPos[1]][nextPos[0]] == '.':
        tmp[nextPos[1]][nextPos[0]] = curr[i][j]
        tmp[i][j] = '.'
        inc(result)
  next = tmp

  for i in 0..<h:
    for j in 0..<w:
      var dir: (int, int)
      case curr[i][j]:
      of 'v':
        dir = (0, 1)
      of '^':
        dir = (0, -1)
      else:
        continue

      let nextPos = (j, (i + dir[1] + h) mod h)
      if tmp[nextPos[1]][nextPos[0]] == '.':
        next[nextPos[1]][nextPos[0]] = curr[i][j]
        next[i][j] = '.'
        inc(result)



let state = readInitialState()

proc partOne() =
  var states: array[2, State]

  var currIdx = 0
  states[currIdx] = state
  states[1 - currIdx] = state
  var steps = 0
  while true:
    let moved = step(states[currIdx], states[1-currIdx])
    inc(steps)
    if moved == 0:
      break
    currIdx = 1 - currIdx
  echo(steps)

partOne()