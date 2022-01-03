import strutils
import strscans
import sequtils
type Interval = tuple[min: int, max: int]
type Bounds = tuple[x, y, z: Interval]
type Instruction = object
  on: bool
  bounds: Bounds
type Point = tuple[x: int, y: int, z: int]

func contains(bounds: Bounds, pt: Point): bool =
  return bounds.x.min <= pt.x and pt.x <= bounds.x.max and
     bounds.y.min <= pt.y and pt.y <= bounds.y.max and
     bounds.z.min <= pt.z and pt.z <= bounds.z.max


proc readInstructions(): seq[Instruction] =
  for line in stdin.lines:
    if line.isEmptyOrWhitespace:
      continue
    var
      on: string
      intX: Interval
      intY: Interval
      intZ: Interval
    assert scanf(line, "$* x=$i..$i,y=$i..$i,z=$i..$i", on, intX.min, intX.max, intY.min, intY.max, intZ.min, intZ.max)
    result.add(Instruction(on: (if on == "on": true else: false), bounds: (x: intX, y: intY, z: intZ)))

proc findLatestInstructionIndex(instructions: seq[Instruction], pt: Point): int =
  for i in countdown(instructions.high, instructions.low):
    if pt in instructions[i].bounds:
      return i
  return -1

let instructions = readInstructions()

proc partOne() =
  let max = 50
  var on = 0
  for x in -max..max:
    for y in -max..max:
      for z in -max..max:
        let instrIndex = findLatestInstructionIndex(instructions, (x, y, z))
        if instrIndex != -1 and instructions[instrIndex].on:
          inc(on)

  echo(on)

func len(i: Interval): int64 =
  if i.min > i.max:
    return 0
  return i.max - i.min + 1

func `*`(b1, b2: Bounds): Bounds =
  return (x: (min: max(b1.x.min, b2.x.min), max: min(b1.x.max, b2.x.max)),
          y: (min: max(b1.y.min, b2.y.min), max: min(b1.y.max, b2.y.max)),
          z: (min: max(b1.z.min, b2.z.min), max: min(b1.z.max, b2.z.max)))
func isEmpty(b: Bounds): bool =
  return b.x.min > b.x.max or b.y.min> b.y.max or b.z.min > b.z.max
func volume(b: Bounds): int64 =
  return b.x.len * b.y.len * b.z.len

func flip(b: bool): bool =
  return if b: false else: true

proc cubesOn(instructions: seq[Instruction]): int64 =
  var allIntersections = @[instructions[0]]
  for i in 1..instructions.high:
    var toAdd: seq[Instruction]
    let instruction = instructions[i]
    for sb in allIntersections:
      let b = sb.bounds * instruction.bounds
      if not b.isEmpty:
        toAdd.add(Instruction(on: sb.on.flip, bounds: b))

    if instruction.on:
      allIntersections.add(instruction)
    for el in toAdd:
      allIntersections.add(el)

  for b in allIntersections:
    result += (if b.on: 1 else: -1) * b.bounds.volume

proc partTwo() =
  echo(cubesOn(instructions))

partTwo()