import sets
import strutils
import sugar
import sequtils

type Point = tuple[x: int, y: int]
type State = object
  lighted: HashSet[Point]
  outsideLighted: bool
type Bounds = tuple[min: Point, max: Point]

func contains(b: Bounds, p: Point): bool =
  return b.min.x <= p.x and p.x <= b.max.x and b.min.y <= p.y and p.y <= b.max.y

proc readInput(): (State, string) =
  let enhancementMap = stdin.readLine
  let empty = stdin.readLine
  assert empty.isEmptyOrWhitespace

  var y = 0
  var lighted = initHashSet[Point]()
  for line in stdin.lines:
    for x, c in line.pairs:
      if c == '#':
        lighted.incl((x, y))
    inc(y)
  return (State(lighted: lighted, outsideLighted: false), enhancementMap)

func getBounds(s: HashSet[Point]): Bounds =
  var
    minX = int.high
    minY = int.high
    maxX = int.low
    maxY = int.low
  for pt in s:
    if pt.x < minX:
      minX = pt.x
    if pt.y < minY:
      minY = pt.y
    if pt.x > maxX:
      maxX = pt.x
    if pt.y > maxY:
      maxY = pt.y
  return (min: (minX, minY), max: (maxX, maxY))

iterator neighbours(p: Point): Point =
  for i in -1..1:
    for j in -1..1:
      yield (p.x + j, p.y + i)

proc getNewLightedState(pt: Point, s: State, bounds: Bounds, enhancementMap: string): bool =
  var n = 0
  for (x, y) in neighbours(pt):
    var state: bool
    if (x, y) in bounds:
      state = (x, y) in s.lighted
    else:
      state = s.outsideLighted
    n = n*2 + (if state: 1 else: 0)
  return enhancementMap[n] == '#'

proc nextState(s: State, enhancementMap: string): State =
  let (min, max) = getBounds(s.lighted)
  var newLighted = initHashSet[Point]()
  for y in min.y-1..max.y+1:
    for x in min.x-1..max.x+1:
      let newState = getNewLightedState((x, y), s, (min, max), enhancementMap)
      if newState:
        newLighted.incl((x, y))

  # determine wheter all the "rest" are lighted or not
  var newOutsideLighted: bool
  if not s.outsideLighted:
    newOutsideLighted = enhancementMap[0] == '#'
  else:
    newOutsideLighted = enhancementMap[511] == '#'

  return State(lighted: newLighted, outsideLighted: newOutsideLighted)

proc visualizeState(s: State) =
  let (min, max) = getBounds(s.lighted)
  for y in min.y..max.y:
    for x in min.x..max.x:
      if (x, y) in s.lighted:
        stdout.write "#"
      else:
        stdout.write "."
    echo("")
  echo("")

proc partOne() =
  const steps = 2
  let (state, enhancementMap) = readInput()
  var currentState = state
  for step in 1..steps:
    currentState = nextState(currentState, enhancementMap)
  echo(len(currentState.lighted))

proc partTwo() =
  const steps = 50
  let (state, enhancementMap) = readInput()
  var currentState = state
  for step in 1..steps:
    currentState = nextState(currentState, enhancementMap)
  echo(len(currentState.lighted))

partTwo()

