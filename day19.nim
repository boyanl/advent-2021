import strutils
import strscans
import tables
import sugar
import sequtils
import strformat
import sets

type Point = object
  x, y, z: int
type Vector = Point
type ScannerData = seq[Point]
type Orientation = tuple[lookAt: Point, up: Point]
type Transform = proc(p: Point): Point

let identity: Transform = (p: Point) => p
func `[]`(p: Point, i: int): int =
  return [p.x, p.y, p.z][i]
func `[]=`(p: var Point, i: int, v: int) =
  case i:
    of 0: p.x = v
    of 1: p.y = v
    of 2: p.z = v
    else:
      assert(false, "bad index: " & $i)

func `==`(v: Vector, t: (int, int, int)): bool =
  return v.x == t[0] and v.y == t[1] and v.z == t[2]

func pt(x, y, z: int): Point =
  return Point(x: x, y: y, z: z)

func v(x, y, z: int): Vector =
  return Vector(x: x, y: y, z: z)

func `-`(v: Vector): Vector =
  return v(-v.x, -v.y, -v.z)

func `-`(p1, p2: Point): Vector =
  return v(p1.x - p2.x, p1.y - p2.y, p1.z - p2.z)

func `+`(p1: Point, v: Vector): Point =
  return pt(p1.x + v.x, p1.y + v.y, p1.z + v.z)

func `*`(t1, t2: Transform): Transform =
  return (p: Point) => t1(t2(p))

func translation(v: Vector): Transform =
  return (p: Point) => pt(p.x + v.x, p.y + v.y, p.z + v.z)

func manhattanDist(p1, p2: Point): int =
  return abs(p1.x - p2.x) + abs(p1.y - p2.y) + abs(p1.z - p2.z)

proc readScannerData(): seq[ScannerData] =
  var scannerIdx: int
  for line in stdin.lines:
    if line.isEmptyOrWhitespace:
      continue
    if scanf(line, "--- scanner $i ---", scannerIdx):
      result.add(@[])
    else:
      assert len(result) - 1 == scannerIdx
      var pt: Point
      if scanf(line, "$i,$i,$i", pt.x, pt.y, pt.z):
        result[^1] = result[^1] & pt

func maxDim(v: Vector): int =
  var
    res = 0
    maxAbs = abs(v[0])
  for i in 1..2:
    if abs(v[i]) > maxAbs:
      res = i
      maxAbs = abs(v[i])
  return res

let unitVectors = @[v(1, 0, 0), v(-1, 0, 0), v(0, 1, 0), v(0, -1, 0), v(0, 0, 1), v(0, 0, -1)]
proc getOrientations(): seq[Orientation] =
  for lookAt in unitVectors:
    for up in unitVectors:
      if up.maxDim == lookAt.maxDim:
        continue
      result.add((lookAt, up))

func flipXZ(p: Point, dim: int): Point =
  return pt(-p.x, p.y, -p.z)

func xToz(up: Vector): proc(p: Point): Point =
  if up == (0, 1, 0):
    return (p: Point) => pt(p.z, p.y, -p.x)
  elif up == (0, 0, -1):
    return (p: Point) => pt(p.z, -p.x, -p.y)
  elif up == (0, -1, 0):
    return (p: Point) => pt(p.z, -p.y, p.x)
  elif up == (0, 0, 1):
    return (p: Point) => pt(p.z, p.x, p.y)
  else:
    assert(false, "unexpected up vector: " & $up & ", expected only YZ")

func yToz(up: Vector): proc (p: Point): Point =
  if up == (0, 0, 1):
    return (p: Point) => pt(-p.x, p.z, p.y)
  elif up == (0, 0, -1):
    return (p: Point) => pt(p.x, p.z, -p.y)
  elif up == (1, 0, 0):
    return (p: Point) => pt(p.y, p.z, p.x)
  elif up == (-1, 0, 0):
    return (p: Point) => pt(-p.y, p.z, -p.x)
  else:
    assert(false, "unexpected up vector: " & $up & ", expected only XZ")

func zToz(up: Vector): proc(p: Point): Point =
  if up == (0, 1, 0):
    return (p: Point) => pt(p.x, p.y, p.z)
  elif up == (0, -1, 0):
    return (p: Point) => pt(-p.x, -p.y, p.z)
  elif up == (1, 0, 0):
    return (p: Point) => pt(-p.y, p.x, p.z)
  elif up == (-1, 0, 0):
    return (p: Point) => pt(p.y, -p.x, p.z)
  else:
    assert(false, "unexpected up vector: " & $up & ", expected only XY")


func getReverseTransform(o: Orientation): Transform =
  let dim = o.lookAt.maxDim
  var innerTransform: proc (p: Point): Point = (p: Point) => p
  if o.lookAt[dim] == -1:
    innerTransform = (p: Point) => flipXZ(p, dim)
  if dim == 0:
    return (p: Point) => xToz(o.up)(innerTransform(p))
  elif dim == 1:
    return (p: Point) => yToz(o.up)(innerTransform(p))
  return (p: Point) => zToz(o.up)(innerTransform(p))


func applyReverseOrientation(data: ScannerData, o: Orientation): ScannerData =
  let transform = getReverseTransform(o)
  return data.map(transform)

proc checkCommonPointsAndGetReverseMapping(s1, s2: ScannerData, orientationS2: Orientation): (bool, Transform) =
  let transformedPts = applyReverseOrientation(s2, orientationS2)
  var transformedPtsMap = initTable[Point, int]()
  for i, pt in transformedPts:
    transformedPtsMap[pt] = i

  for pt1 in s1:
    for pt2 in transformedPts:
      let translationVec = pt2 - pt1
      var mapping = initTable[Point, Point]()
      for s in s1:
        if (s + translationVec) in transformedPtsMap:
          var idx = transformedPtsMap[s + translationVec]
          mapping[s] = s2[idx]
      if len(mapping) >= 12:
        return (true, translation(-translationVec) * getReverseTransform(orientationS2))

let scannerData = readScannerData()

proc partOne() =
  var allPoints = initHashSet[Point]()
  var queue: seq[tuple[index: int, transformToScannerZero: Transform]]
  queue.add((0, identity))

  for pt in scannerData[0]:
    allPoints.incl(pt)

  var visited = initHashSet[int]()
  visited.incl(0)
  while len(queue) > 0:
    let (index, transform) = queue.pop
    for i in 0..<len(scannerData):
      if i in visited:
        continue
      for o in getOrientations():
        let (ok, transform2) = checkCommonPointsAndGetReverseMapping(scannerData[index], scannerData[i], o)
        if ok:
          let combined = transform * transform2
          visited.incl(i)
          for pt in scannerData[i]:
            allPoints.incl(combined(pt))
          queue.add((i, combined))
          break
  echo(len(allPoints))

func maxDistanceBetweenPointsIn(pts: HashSet[Point]): int =
  var maxDist = int.low
  for p1 in pts:
    for p2 in pts:
      let d = manhattanDist(p1, p2)
      if d > maxDist:
        maxDist = d
  return maxDist

proc partTwo() =
  var scanners = initHashSet[Point]()
  var queue: seq[tuple[index: int, transformToScannerZero: Transform]]
  queue.add((0, identity))
  scanners.incl(pt(0, 0, 0))

  var visited = initHashSet[int]()
  visited.incl(0)
  while len(queue) > 0:
    let (index, transform) = queue.pop
    for i in 0..<len(scannerData):
      if i in visited:
        continue
      for o in getOrientations():
        let (ok, transform2) = checkCommonPointsAndGetReverseMapping(scannerData[index], scannerData[i], o)
        if ok:
          let combined = transform * transform2
          visited.incl(i)
          queue.add((i, combined))
          scanners.incl(combined(pt(0, 0, 0)))
          break

  echo(maxDistanceBetweenPointsIn(scanners))

partTwo()