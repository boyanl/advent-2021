import tables
import strutils
import sets
import sequtils
import sugar

type Graph = Table[int, seq[int]]
type CaveMapping = object
  nameToIndex: Table[string, int]
  indexToName: Table[int, string]
  bigRooms: HashSet[int]

func `[]`(mapping: CaveMapping, cave: string): int =
  return mapping.nameToIndex[cave]

func isBigRoom(mapping: CaveMapping, caveIdx: int): bool =
  return caveIdx in mapping.bigRooms

func isBigRoom(s: string): bool =
  for c in s:
    if not c.isUpperAscii:
      return false
  return true

proc readGraph(f: File): (Graph, CaveMapping) =
  var graph: Graph
  var mapping: CaveMapping

  var currentCave = 1
  for line in stdin.lines:
    if line.isEmptyOrWhitespace:
      continue
    let parts = line.split("-")
    var caveIndices: array[2, int]
    for i, part in parts.pairs:
      if part notin mapping.nameToIndex:
        mapping.nameToIndex[part] = currentCave
        mapping.indexToName[currentCave] = part
        caveIndices[i] = currentCave
        if isBigRoom(part):
          mapping.bigRooms.incl(caveIndices[i])
        inc(currentCave)
      else:
        caveIndices[i] = mapping.nameToIndex[part]

    if caveIndices[0] notin graph:
      graph[caveIndices[0]] = @[]
    if caveIndices[1] notin graph:
      graph[caveIndices[1]] = @[]
    graph[caveIndices[0]].add(caveIndices[1])
    graph[caveIndices[1]].add(caveIndices[0])

  return (graph, mapping)


proc partOne() =
  type Path = seq[int]
  proc countPathsOfInterest(g: Graph, mapping: CaveMapping): int =
    var paths: seq[Path]
    let
      startIdx = mapping["start"]
      endIdx = mapping["end"]
    paths.add(@[startIdx])

    while len(paths) > 0:
      let path = paths[0]
      paths.delete(0)

      let lastRoom = path[^1]
      if lastRoom == endIdx:
        inc(result)
        continue
      for n in g[lastRoom]:
        if mapping.isBigRoom(n) or n notin path:
          paths.add(path & n)

  let (graph, mapping) = readGraph(stdin)
  let answer = countPathsOfInterest(graph, mapping)
  echo(answer)

proc partTwo() =
  type State = object
    g: Graph
    mapping: CaveMapping
    lastRoom: int
    smallRooms: Table[int, int]
    twice: bool

  # Avoid copying the state by using DFS and modifying the state in-place, then reverting it back
  proc doCount(s: var State, startIdx, endIdx: int): int =
    let lastRoom = s.lastRoom
    if lastRoom == endIdx:
      return 1
    var res = 0
    for n in s.g[lastRoom]:
      let isBig = s.mapping.isBigRoom(n)
      if isBig or (n notin s.smallRooms or s.smallRooms[n] == 0) or (not s.twice and n != startIdx and n != endIdx):
        let prevLast = s.lastRoom
        let prevTwice = s.twice
        s.lastRoom = n
        if not isBig:
          inc(s.smallRooms.mgetOrPut(n, 0))
          if s.smallRooms[n] == 2:
            s.twice = true
        res += doCount(s, startIdx, endIdx)
        if not isBig:
          dec(s.smallRooms[n])
        s.lastRoom = prevLast
        s.twice = prevTwice
    return res

  proc countPathsOfInterest(g: Graph, mapping: CaveMapping): int =
    let
      startIdx = mapping["start"]
      endIdx = mapping["end"]
    var smallRooms = initTable[int, int]()
    smallRooms[startIdx] = 1
    var state = State(g: g, mapping: mapping, lastRoom: startIdx, smallRooms: smallRooms, twice: false)
    return doCount(state, startIdx, endIdx)

  let (graph, mapping) = readGraph(stdin)
  let answer = countPathsOfInterest(graph, mapping)
  echo(answer)

partTwo()