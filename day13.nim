import sets
import strutils
import strscans
import sequtils
import strformat

type Point = tuple[x: int, y: int]
type FoldInstruction = tuple[axis:char, val:int]

proc readPointsAndFoldInstructions(): (seq[Point], seq[FoldInstruction]) =
  var pts: seq[Point]
  var foldInstructions: seq[FoldInstruction]
  var instructionsNext = false
  for line in stdin.lines:
    if line.isEmptyOrWhitespace:
      instructionsNext = true
      continue
    if not instructionsNext:
      let parts = line.split(",")
      let
        x = parts[0].parseInt
        y = parts[1].parseInt
      pts.add((x, y))
    else:
      var instruction: FoldInstruction
      if scanf(line, "fold along $c=$i", instruction.axis, instruction.val):
        foldInstructions.add(instruction)
  return (pts, foldInstructions)

proc reflect(p: Point, axis: int, val: int): Point =
  result = p
  # Can't seem to index a tuple with a variable ... (must be a constant)
  if axis == 0:
    var diff = p.x - val
    result.x -= 2*diff
  elif axis == 1:
    var diff = p.y - val
    result.y -= 2*diff

proc display(pts: HashSet[Point]) =
  let
    dims = toSeq(pts).foldl((x: max(a.x, b.x), y: max(a.y, b.y)))
    width = dims.x
    height = dims.y
  echo(&"WxH: {width}x{height}")

  for y in 0..height:
    for x in 0..width:
      if (x, y) in pts:
        stdout.write "#"
      else:
        stdout.write "."
    echo("")
  echo("")

let (ptsSeq, instructions) = readPointsAndFoldInstructions()
var pts = ptsSeq.toHashSet

proc partOne() =
  let (axisLabel, value) = instructions[0]
  let axis = (if axisLabel == 'x': 0 else: 1)
  var
    toExclude: seq[Point]
    toInclude: seq[Point]
  for p in pts:
    let ptVal = (if axisLabel == 'x': p.x else: p.y)
    if ptVal > value:
      toExclude.add(p)
      toInclude.add(reflect(p, axis, value))
  for p in toExclude:
    pts.excl(p)
  for p in toInclude:
    pts.incl(p)

  display(pts)

  echo(pts.len)

proc partTwo() =
  for (axisLabel, value) in instructions:
    let axis = (if axisLabel == 'x': 0 else: 1)
    var
      toExclude: seq[Point]
      toInclude: seq[Point]
    for p in pts:
      let ptVal = (if axisLabel == 'x': p.x else: p.y)
      if ptVal > value:
        toExclude.add(p)
        toInclude.add(reflect(p, axis, value))
    for p in toExclude:
      pts.excl(p)
    for p in toInclude:
      pts.incl(p)

  display(pts)

partTwo()