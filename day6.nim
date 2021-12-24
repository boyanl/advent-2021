import strutils
import sequtils
import sugar

type IntT = int64
type State = array[9, IntT]

proc getAges(): seq[IntT] =
  for l in stdin.lines:
    return l.split(",").map(x => IntT(x.parseInt))

func getCounts(ages: seq[IntT]): State =
  for age in ages:
    inc(result[age])

func next(s: State): State =
  for i in 1..8:
    result[i-1] = s[i]
  result[6] += s[0]
  result[8] = s[0]

func sum(s: State): IntT =
  for i in 0..8:
    result += s[i]

let ages = getAges()
let counts = getCounts(ages)

proc partOne() =
  let rounds = 80

  var state = counts
  for i in 1..rounds:
    state = state.next
  let res = sum(state)
  echo(res)

proc partTwo() =
  let rounds = 256

  var state = counts
  for i in 1..rounds:
    state = state.next
  let res = sum(state)
  echo(res)

partTwo()