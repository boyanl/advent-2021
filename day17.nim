import strscans

type Interval[T] = object
  min, max: T

func interval[T](n1, n2: T): Interval[T] =
  return Interval[T](min: min(n1, n2), max: max(n1, n2))

func fallsAtAnyPointWithin(tx, ty: Interval[int], speed: (int, int)): bool =
  var x, y: int
  var v = speed
  var step = 0
  while true:
    x += v[0]
    y += v[1]
    inc(step)

    v[0] = max(0, v[0]-1)
    v[1] -= 1

    if tx.min <= x and x <= tx.max and ty.min <= y and y <= ty.max:
      return true
    if x > tx.max or y < ty.min:
      return false

proc findDesiredInitialVelocity(tx, ty: Interval[int]): (int, int) =
  let
    maxvx = tx.max
    maxvy = -ty.min
  var best = (int.low, int.low)
  for vx in 1..maxvx:
    for vy in 1..maxvy:
      if fallsAtAnyPointWithin(tx, ty, (vx, vy)):
        if best[1] < vy:
          best = (vx, vy)
  return best

func maxYPosition(initialSpeed: (int, int)): int =
  let vy = initialSpeed[1]
  return vy*(vy + 1) div 2

proc countAllGoodInitialVelocities(tx, ty: Interval[int]): int =
  let
    maxvx = tx.max
    minvy = ty.min
    maxvy = -ty.min
  for vx in 1..maxvx:
    for vy in minvy..maxvy:
      if fallsAtAnyPointWithin(tx, ty, (vx, vy)):
        inc(result)

let line = stdin.readLine
var t1x, t2x, t1y, t2y: int
discard scanf(line, "target area: x=$i..$i, y=$i..$i", t1x, t2x, t1y, t2y)
let
  targetAreaX = interval(t1x, t2x)
  targetAreaY = interval(t1y, t2y)

proc partOne() =
  let result = findDesiredInitialVelocity(targetAreaX, targetAreaY)
  let maxY = maxYPosition(result)
  echo(maxY)

proc partTwo() =
  let cnt = countAllGoodInitialVelocities(targetAreaX, targetAreaY)
  echo(cnt)

partTwo()