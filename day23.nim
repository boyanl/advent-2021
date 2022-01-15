import std/hashes
import strscans
import tables
import sets
import heapqueue

type AmphipodType = char
type Point = tuple[x: int, y: int]
type Positions = ref object
  A, B, C, D: HashSet[Point]
type State = Positions

let energyPerStep = {'A': 1, 'B': 10, 'C': 100, 'D': 1000}.toTable
let desiredXPos = {'A': 3, 'B': 5, 'C': 7, 'D': 9}.toTable

proc isInPosition(amphipodType: AmphipodType, pos: Point): bool =
  if pos.y notin [1, 2, 3, 4]:
    return false
  return desiredXPos[amphipodType] == pos.x

iterator amphipods(p: Positions): tuple[t: char, pts: HashSet[Point]] =
  for pair in [('A', p.A), ('B', p.B), ('C', p.C), ('D', p.D)]:
    yield pair

proc isEndState(s: State): bool =
  for (k, v) in s.amphipods:
    for pos in v:
      if not isInPosition(k, pos):
        return false
  return true

func empty(positions: Positions, p: Point): bool =
  for t, posSeq in positions.amphipods:
    if p in posSeq:
      return false
  return true

func hasClearPath(start: Point, dest: Point, positions: Positions): bool =
  assert(start.y in [1, 2, 3, 4])
  for y in countdown(start.y-1, 0):
    if not empty(positions, (x: start.x, y: y)):
      return false

  var dx = if start.x < dest.x: 1 else: -1
  var currX = start.x
  while currX != dest.x:
    if not empty(positions, (x: currX, y: 0)):
      return false
    currX += dx
  return true

func distance(p1, p2: Point): int =
  return abs(p1.x - p2.x) + abs(p1.y - p2.y)

func getAmphipodsForType(s: State, t: AmphipodType): HashSet[Point] =
  case t:
    of 'A':
      return s.A
    of 'B':
      return s.B
    of 'C':
      return s.C
    of 'D':
      return s.D
    else:
      raise newException(Exception, "Unexpected type: " & t)

func getAmphipodsForType(s: var State, t: AmphipodType): var HashSet[Point] =
  case t:
    of 'A':
      return s.A
    of 'B':
      return s.B
    of 'C':
      return s.C
    of 'D':
      return s.D
    else:
      raise newException(Exception, "Unexpected type: " & t)

func copy(s: State): State =
  return State(A: s.A, B: s.B, C: s.C, D: s.D)

proc replace(s: State, amphipodType: AmphipodType, p: Point, newP: Point): (State, int) =
  var newState = s.copy
  var pts = getAmphipodsForType(newState, amphipodType)
  if pts.contains(p):
    getAmphipodsForType(newState, amphipodType).excl(p)
    getAmphipodsForType(newState, amphipodType).incl(newP)
    return (newState, distance(p, newP)*energyPerStep[amphipodType])

func amphipodForCoords(p: Point, positions: Positions): (bool, char) =
  for t, posSeq in positions.amphipods:
    for pos in posSeq:
      if pos == p:
        return (true, t)

iterator nextStates(s: State): (State, int) =
  var toMove = initHashSet[(Point, AmphipodType)]()
  for t, positions in s.amphipods:
    for pos in positions:
      if not isInPosition(t, pos):
        if pos.y == 1:
          toMove.incl((pos, t))
        elif pos.y == 2:
          if empty(s, (pos.x, 1)):
            toMove.incl((pos, t))
          else:
            let upperAmphipod = (pos.x, pos.y - 1)
            let (have, t1) = amphipodForCoords(upperAmphipod, s)
            assert have
            if (upperAmphipod, t1) notin toMove:
              toMove.incl((upperAmphipod, t1))
        else:
          let inner = (desiredXPos[t], 2)
          if empty(s, inner) and hasClearPath(inner, pos, s):
            yield replace(s, t, pos, inner)
          else:
            let outer = (desiredXPos[t], 1)
            if empty(s, outer) and hasClearPath(outer, pos, s):
              yield replace(s, t, pos, outer)

  for (pos, t) in toMove:
    if pos.y in [1, 2]:
      # for x in [1, 2, 4, 6, 8, 10, 11]:
      for x in [2, 4, 6, 8, 10]:
        let newPos = (x: x, y: 0)
        if x != pos.x and empty(s, newPos) and hasClearPath(pos, newPos, s):
          yield replace(s, t, pos, (x: x, y: 0))

iterator nextStates2(s: State, height: int): (State, int) =
  var toMove = initHashSet[(Point, AmphipodType)]()
  for t, positions in s.amphipods:
    for pos in positions:
      if not isInPosition(t, pos):
        if pos.y == 1:
          toMove.incl((pos, t))
        elif pos.y >= 2:
          var y = pos.y - 1
          while not empty(s, (pos.x, y)):
            dec(y)
          let last = (pos.x, y+1)
          let (have, t) = amphipodForCoords(last, s)
          assert have
          if (last, t) notin toMove:
            toMove.incl((last, t))
        else:
          var allCorrecType = true
          for y in countdown(height, 1):
            let targetPos = (desiredXPos[t], y)
            let (have, t1) = amphipodForCoords(targetPos, s)
            if have:
              if t1 != t:
                allCorrecType = false
                break
            elif hasClearPath(targetPos, pos, s):
              yield replace(s, t, pos, targetPos)
              break

  for (pos, t) in toMove:
    if pos.y in 1..height:
      for x in [1, 2, 4, 6, 8, 10, 11]:
        let newPos = (x: x, y: 0)
        if x != pos.x and empty(s, newPos) and hasClearPath(pos, newPos, s):
          yield replace(s, t, pos, (x: x, y: 0))

proc remainingEnergyEstimate(s: State): int =
  for t, pts in s.amphipods:
    for p in pts:
      if not isInPosition(t, p):
        result += distance(p, (x: desiredXPos[t], y: 0))*energyPerStep[t]

proc visualizeAmphipodPositions(positions: Positions, height: int) =
  echo("#############")
  var walls = @[(0, 0), (12, 0), (0, 1), (1, 1), (2, 1), (4, 1), (6, 1), (8, 1), (10, 1), (11, 1), (12, 1)].toHashSet

  for y in 2..height:
    walls = walls + @[(2, y), (4, y), (6, y), (8, y), (10, y)].toHashSet

  for y in 0..height:
    for x in 0..12:
      let p = (x: x, y: y)
      var found = false
      for t, posSeq in positions.amphipods:
        if p in posSeq:
          stdout.write(t)
          found = true
          break
      if not found and p in walls:
        stdout.write("#")
        found = true
      elif not found:
        if p.y >= 2 and (p.x < 2 or p.x > 10):
          stdout.write(" ")
        else:
          stdout.write(".")
    echo("")
  echo("  #########")
  echo("")

proc `<`(a, b: (State, int)): bool =
  return a[1] < b[1]

proc hash(s: State): Hash =
  return hash(s[])

proc `==`(s1, s2: State): bool =
  return s1[] == s2[]

proc findCheapestRearrangement(start: State, height: int): int =
  var queue = initHeapQueue[(State, int)]()
  queue.push((start, 0))
  var visited = initHashSet[Positions]()

  var distance = initTable[Positions, int]()
  distance[start] = 0

  var total = 0
  while len(queue) > 0:
    let (state, _) = queue.pop()
    let energy = distance[state]
    if state in visited:
      continue
    visited.incl(state)
    inc(total)
    if isEndState(state):
      return energy
    # if total mod 1000 == 0:
    #   echo("Worked through ", total, " states, queue size: ", len(queue), ", len(distance map): ", len(distance))
    # if total mod 1000 == 0:
    #   visualizeAmphipodPositions(state, height)

    for (n, energyDiff) in nextStates2(state, height):
      let distToNeighbour = energy + energyDiff
      if n notin visited and distToNeighbour < distance.getOrDefault(n, int.high):
        distance[n] = distToNeighbour
        let energyEstimate = distToNeighbour + remainingEnergyEstimate(n)
        queue.push((n, energyEstimate))

  return -1

proc partOne() =
  proc getAmphipodPositions(): Positions =
    result = Positions(A: initHashSet[Point](), B: initHashSet[Point](), C: initHashSet[Point](), D: initHashSet[Point]())
    var (_,_) = (stdin.readLine(), stdin.readLine())
    var a: array[8, char]
    assert scanf(stdin.readLine(), "###$c#$c#$c#$c###", a[0], a[1], a[2], a[3])
    assert scanf(stdin.readLine(), "$s#$c#$c#$c#$c#", a[4], a[5], a[6], a[7])
    for i in 0..3:
      getAmphipodsForType(result, a[i]).incl((3 + i*2, 1))
    for i in 4..7:
      getAmphipodsForType(result, a[i]).incl((3 + (i-4)*2, 2))
  let initialPositions = getAmphipodPositions()
  let energyRequired = findCheapestRearrangement(initialPositions, 2)
  echo(energyRequired)

proc partTwo() =
  proc getAmphipodPositions(): Positions =
    result = Positions(A: initHashSet[Point](), B: initHashSet[Point](), C: initHashSet[Point](), D: initHashSet[Point]())
    var (_,_) = (stdin.readLine(), stdin.readLine())
    var a: array[16, char]
    assert scanf(stdin.readLine(), "###$c#$c#$c#$c###", a[0], a[1], a[2], a[3])
    assert scanf(stdin.readLine(), "$s#$c#$c#$c#$c#", a[12], a[13], a[14], a[15])
    for i in 4..<12:
      a[i] = "DCBADBAC"[i-4]
    for i in a.low..a.high:
      getAmphipodsForType(result, a[i]).incl((3 + (i mod 4)*2, (i div 4) + 1))
  let initialPositions = getAmphipodPositions()
  let energyRequired = findCheapestRearrangement(initialPositions, 4)
  echo(energyRequired)

partTwo()