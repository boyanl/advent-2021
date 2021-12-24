import strutils
import sequtils
import sugar

proc getPositions(): seq[int] =
  for l in stdin.lines:
    return l.split(",").map(x => x.parseInt)

proc requiredFuelToMoveAllTo(positions: seq[int], pos: int, fuelFn: proc(p1, p2: int): int): int =
  for p in positions:
    inc(result, fuelFn(p, pos))

proc fuelFn1(p1, p2: int): int =
  return abs(p1 - p2)

proc fuelFn2(p1, p2: int): int =
  let d = abs(p1 - p2)
  return d*(d+1) div 2

proc findOptimalPosition(positions: seq[int], fuelFn: proc(p1, p2:int):int): tuple[pos: int, requiredFuel: int] =
  let
    minPos = positions[positions.minIndex]
    maxPos = positions[positions.maxIndex]
  var
    bestPos = -1
    bestFuel = -1
  for pos in minPos..maxPos:
    let requiredFuel = positions.requiredFuelToMoveAllTo(pos, fuelFn)
    if bestFuel == -1 or requiredFuel < bestFuel:
      bestFuel = requiredFuel
      bestPos = pos
  return (bestPos, bestFuel)


let positions = getPositions()

proc partOne() =
  let (pos, fuel) = findOptimalPosition(positions, fuelFn1)
  echo("Optimal position is: ", pos, ", requiring fuel: ", fuel)

proc partTwo() =
  let (pos, fuel) = findOptimalPosition(positions, fuelFn2)
  echo("Optimal position is: ", pos, ", requiring fuel: ", fuel)

partTwo()