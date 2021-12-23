import strutils
import strscans
import sequtils
import sugar
import tables

type
  Point = tuple[x, y: int]
  Segment = tuple[startPt, endPt: Point]

func isVertical(s: Segment): bool =
  return s.startPt.x == s.endPt.x

func isHorizontal(s: Segment): bool =
  return s.startPt.y == s.endPt.y

func isDiagonal(s: Segment): bool =
  let
    xdiff = s.startPt.x - s.endPt.x
    ydiff = s.startPt.y - s.endPt.y
  return xdiff == ydiff or xdiff == -ydiff

func dir(x1, x2: int): int =
  if x1 == x2:
    return 0
  return (if x1 < x2: 1 else: -1)

func dir(p1, p2: Point): Point =
  return (x: dir(p1.x, p2.x), y: dir(p1.y, p2.y))

iterator points(s: Segment): Point =
  var dv: Point = dir(s.startPt, s.endPt)

  var currentPt = s.startPt
  while currentPt != s.endPt:
    yield currentPt
    currentPt = (x: currentPt.x + dv.x, y: currentPt.y + dv.y)
  yield s.endPt

proc readSegments(file: File): seq[Segment] =
  for line in file.lines:
    if line.isEmptyOrWhitespace:
      continue
    var x1, y1, x2, y2: int
    if scanf(line, "$i,$i -> $i,$i", x1, y1, x2, y2):
      result.add((startPt: (x1, y1), endPt: (x2, y2)))

proc mark(t: var Table[(int, int), int], pos: (int, int)) =
  if not (pos in t):
    t[pos] = 1
  else:
    inc(t[pos])

proc partOne() =
  let segments = readSegments(stdin).filter(s => s.isHorizontal or s.isVertical)
  var counts = initTable[Point, int]()

  var commonPtsCnt: int
  for s in segments:
    for pt in s.points:
      mark(counts, pt)
      if counts[pt] == 2:
        inc(commonPtsCnt)

  echo(commonPtsCnt)

proc partTwo() =
  let segments = readSegments(stdin).filter(s => s.isHorizontal or s.isVertical or s.isDiagonal)
  var counts = initTable[Point, int]()

  var commonPtsCnt: int
  for s in segments:
    for pt in s.points:
      mark(counts, pt)
      if counts[pt] == 2:
        inc(commonPtsCnt)

  echo(commonPtsCnt)

partTwo()