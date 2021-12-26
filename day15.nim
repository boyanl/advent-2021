import std/tables
import std/heapqueue
import sets

proc parseHeights(line: string): seq[int] =
  for c in line:
    result.add(int(c) - int('0'))

proc getHeights(file: File): seq[seq[int]] =
  for line in stdin.lines:
    result.add(line.parseHeights)

type Node = object
  point: (int, int)
  cost: int

proc `<`(a, b: Node): bool =
  return a.cost < b.cost

func valueAt(heights: seq[seq[int]], coords: (int, int)): int =
  return heights[coords[1]][coords[0]]

func neighbours(coords: (int, int), width, height: int): seq[(int, int)] =
  for (i, j) in @[(-1, 0), (0, -1), (1, 0), (0, 1)]:
    let
      ni = coords[0] + i
      nj = coords[1] + j
    if ni >= 0 and ni < width and nj >= 0 and nj < height:
      result.add((ni, nj))

proc lowestRiskPathCost(heights: seq[seq[int]], startPt: (int, int), endPt: (int, int)): int =
  let
    width = len(heights[0])
    height = len(heights)
  var queue = initHeapQueue[Node]()
  queue.push(Node(point: startPt, cost: 0))
  var visited = initHashSet[(int, int)]()
  var dist = initTable[(int, int), int]()
  dist[startPt] = 0
  visited.incl(startPt)

  var totalIter = 0
  while len(queue) > 0:
    let top = queue.pop
    inc(totalIter)
    visited.incl(top.point)
    if top.point == endPt:
      return top.cost

    for n in neighbours(top.point, width, height):
      if n notin visited and (n notin dist or top.cost + heights.valueAt(n) < dist[n]):
        dist[n] = top.cost + heights.valueAt(n)
        queue.push(Node(point: n, cost: dist[n]))

proc generateFullMap(heights: seq[seq[int]]): seq[seq[int]] =
  const k = 5
  let
    width = len(heights[0])
    height = len(heights)
  var res = newSeq[seq[int]](k*height)
  for i in 0..<len(res):
    res[i] = newSeq[int](k*width)
  for i in 0..<k:
    for j in 0..<k:
      for ki in 0..<height:
        for kj in 0..<width:
          res[i*height + ki][j*width + kj] = (heights[ki][kj] + i + j - 1) mod 9 + 1
  return res



let heights = getHeights(stdin)

proc lowestRiskUpperLeftToBottomRight(heights: seq[seq[int]]): int =
  let
    width = len(heights[0])
    height = len(heights)
  return lowestRiskPathCost(heights, (0, 0), (width - 1, height - 1))

proc partOne() =
  echo(lowestRiskUpperLeftToBottomRight(heights))

proc partTwo() =
  let expanded = generateFullMap(heights)
  echo(lowestRiskUpperLeftToBottomRight(expanded))

partTwo()