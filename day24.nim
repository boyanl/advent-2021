import strutils
import sets
import tables
import std/deques
import sequtils

type Program = seq[string]
type VariableState = tuple[x: int, y: int, z: int, w: int]
type ProgramState = tuple[ip: int, variables: VariableState]

type ProgramInput = concept t
  t.haveMore() is bool
  t.next() is int



type StringInput = object
  s: string
  idx: int

type IntInput = object
  i: int
  used: bool

func haveMore(si: StringInput): bool =
  return si.idx < si.s.len

func next(si: var StringInput): int =
  let rv = si.s[si.idx].int - '0'.int
  inc(si.idx)
  return rv

proc fromString(s: string): StringInput =
  return StringInput(s: s, idx:0)

func haveMore(ir: IntInput): bool =
  return not ir.used

func next(ir: var IntInput): int =
  let rv = ir.i
  ir.used = true
  return rv

proc fromInt(i: int): IntInput =
  return IntInput(i: i)


proc executeInstruction(s: string, input: var ProgramInput, variables: var VariableState): bool =
  proc getVariable(variables: var VariableState, name: string): var int =
    case name:
    of "x":
      return variables.x
    of "y":
      return variables.y
    of "z":
      return variables.z
    of "w":
      return variables.w
    else:
      raise newException(Exception, "Unexpected variable name " & name)

  proc getVariableValue(variables: VariableState, name: string): int =
    case name:
    of "x":
      return variables.x
    of "y":
      return variables.y
    of "z":
      return variables.z
    of "w":
      return variables.w
    else:
      raise newException(Exception, "Unexpected variable name " & name)

  proc getValue(name: string, variables: VariableState): int =
    if name in ["x", "y", "z", "w"]:
      return getVariableValue(variables, name)
    return name.parseInt

  let parsed = s.split(" ")
  case parsed[0]:
  of "inp":
    if not input.haveMore:
      return false
    getVariable(variables, parsed[1]) = input.next
  of "add":
    getVariable(variables, parsed[1]) += getValue(parsed[2], variables)
  of "mul":
    getVariable(variables, parsed[1]) *= getValue(parsed[2], variables)
  of "div":
    getVariable(variables, parsed[1]) = getVariableValue(variables, parsed[1]) div getValue(parsed[2], variables)
  of "mod":
    getVariable(variables, parsed[1]) = getVariableValue(variables, parsed[1]) mod getValue(parsed[2], variables)
  of "eql":
    getVariable(variables, parsed[1]) = (getVariableValue(variables, parsed[1]) == getValue(parsed[2], variables)).int
  return true

proc executeProgram(p: Program, input: var ProgramInput, programState: ProgramState): ProgramState =
  var state = programState
  while true:
    if state.ip >= len(p):
      break
    let instr = p[state.ip]
    let executed = executeInstruction(instr, input, state.variables)
    if not executed:
      break
    inc(state.ip)

  return state

func addInFront(n: int64, digit: int8): int64 =
  var n1 = n
  var d1 = digit.int64
  while n1 > 0:
    n1 = n1 div 10
    d1 *= 10
  return d1 + n


proc acceptableModelNumbers(p: Program, initialState: ProgramState): seq[int64] =
  var zvals = initHashSet[int]()
  zvals.incl(0)
  var nextZvals = initHashSet[int]()
  var prev = initTable[(int, int), seq[(int8, int)]]()

  var lastIp = 0
  for i in 1..13:
    var nextIp = lastIp
    for zv in zvals:
      for digit in 1..9:
        var input = fromInt(digit)
        let endState = executeProgram(p, input, (ip: lastIp, variables: (x: 0, y: 0, z: zv, w: 0)))
        nextZvals.incl(endState.variables.z)
        prev.mgetOrPut((endState.variables.z, i), @[]).add((digit.int8, zv))
        nextIp = endState.ip
    zvals = nextZvals
    nextZvals = initHashSet[int]()
    lastIp = nextIp
  # Pre-computed but oh well
  let lastDigitInputAndZ: seq[(int64, int)] = @[(4.int64, 15), (3.int64, 14), (6.int64, 17), (2.int64, 13), (5.int64, 16), (7.int64, 18), (8.int64, 19), (1.int64, 12)]
  var queue = initDeque[(int64, int, int)]()
  for (i, z) in lastDigitInputAndZ:
    queue.addLast((i, z, 13))

  var numbers: seq[int64] = @[]
  while len(queue) > 0:
    let (numberSoFar, z, round) = queue.popFirst
    if round == 0:
      numbers.add(numberSoFar)
      continue

    for (digit, prevZ) in prev[(z, round)]:
      queue.addLast((addInFront(numberSoFar, digit), prevZ, round-1))
  return numbers


proc readProgram(): Program =
  for line in stdin.lines:
    result.add(line)

let program = readProgram()
let initialState = (ip: 0, variables: (x: 0, y: 0, z: 0, w:0))
let modelNumbers = acceptableModelNumbers(program, initialState)

proc partOne() =
  let result = modelNumbers[modelNumbers.maxIndex]
  echo(result)

proc partTwo() =
  let result = modelNumbers[modelNumbers.minIndex]
  echo(result)

partTwo()