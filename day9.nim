import sequtils
import sugar
import sets
import algorithm

proc readHeightMap(): seq[seq[int]] =
  for line in stdin.lines:
    var row: seq[int]
    for digit in line:
      row.add(int(digit) - int('0'))
    result. add(row)

iterator all(yslice, xslice: HSlice[int, int]): (int, int) =
  for y in yslice:
    for x in xslice:
      yield (y, x)

proc neighbours(heightmap: seq[seq[int]], coords: (int, int)): seq[(int, int)] =
  let (i, j) = coords
  if i > 0:
    result.add((i-1, j))
  if i < len(heightmap) - 1:
    result.add((i+1, j))
  if j > 0:
    result.add((i, j-1))
  if j < len(heightmap[0]) - 1:
    result.add((i, j+1))

proc valueAt(heightmap: seq[seq[int]], coords: (int, int)): int =
  let (i, j) = coords
  return heightmap[i][j]

let heightmap = readHeightMap()
proc partOne() =
  let lowpoints = toSeq(all(0..<len(heightmap), 0..<len(heightmap[0])))
                  .filter(t => neighbours(heightmap, t).all(t2 => heightmap.valueAt(t2) > heightmap.valueAt(t)))
                  .map(t => heightmap.valueAt(t))
  let risk = lowpoints.map(x => x + 1).foldl(a+b)
  echo(risk)



proc basinContaining(coords: (int, int), heightmap: seq[seq[int]]): seq[(int, int)] =
  var visited = initHashSet[(int, int)]()
  var queue = @[coords]
  visited.incl(coords)
  while len(queue) > 0:
    let el = queue[0]
    result.add(el)
    queue.delete(0)
    for n in heightmap.neighbours(el):
      if heightmap.valueAt(n) < 9 and not visited.contains(n):
        queue.add(n)
        visited.incl(n)


proc partTwo() =
  let lowpointCoords = toSeq(all(0..<len(heightmap), 0..<len(heightmap[0])))
                  .filter(t => neighbours(heightmap, t).all(t2 => heightmap.valueAt(t2) > heightmap.valueAt(t)))
  let basins = lowpointCoords.map(t => basinContaining(t, heightmap))
  let last = (s: seq[int], N: int) => s[len(s)-N..<len(s)]
  let result = basins.map(basin => len(basin)).sorted.last(3).foldl(a*b)
  echo(result)

partTwo()
