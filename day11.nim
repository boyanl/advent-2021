import strutils
import sequtils
import sugar
import sets

func toEnergyLevels(line: string): seq[int] =
  for c in line:
    result.add(int(c) - int('0'))

proc displayGrid(grid: seq[seq[int]]) =
  for i in 0..<len(grid):
    for j in 0..<len(grid[i]):
      stdout.write grid[i][j]
    echo("")
  echo("")

proc simulateStep(grid: seq[seq[int]]): tuple[grid: seq[seq[int]], flashes: int] =
  var newGrid = grid
  var flashed = initHashSet[(int, int)]()
  let
    height = len(grid)
    width = len(grid[0])
  var willFlash: seq[(int, int)]

  for i in 0..<height:
    for j in 0..<width:
      newGrid[i][j] = grid[i][j] + 1
      if newGrid[i][j] > 9:
        willFlash.add((i, j))

  while len(willFlash) > 0:
    let (i, j) = willFlash.pop
    if (i, j) in flashed:
      continue
    flashed.incl((i, j))
    newGrid[i][j] = 0

    for dx in -1..1:
      for dy in -1..1:
        if dx == 0 and dy == 0:
          continue
        let
          ni = i + dy
          nj = j + dx
        if ni >= 0 and ni < height and nj >= 0 and nj < width and not flashed.contains((ni, nj)):
          inc(newGrid[ni][nj])
          if newGrid[ni][nj] > 9:
            willFlash.add((ni, nj))

  return (newGrid, len(flashed))

proc partOne() =
  const steps = 100
  let grid = toSeq(stdin.lines).filter(s => not s.isEmptyOrWhitespace).map(s => toEnergyLevels(s))

  var state = grid
  var totalFlashes = 0
  for step in 1..steps:
    let (newState, flashes) = simulateStep(state)
    totalFlashes += flashes
    state = newState

  echo(totalFlashes)

proc partTwo() =
  let grid = toSeq(stdin.lines).filter(s => not s.isEmptyOrWhitespace).map(s => toEnergyLevels(s))

  var state = grid
  var step = 0
  let
    width = len(grid[0])
    height = len(grid)
  while true:
    let (newState, flashes) = simulateStep(state)
    state = newState
    inc(step)
    if flashes == width*height:
      break

  echo(step)
partTwo()