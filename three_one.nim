import strutils
import tables

type Stats = tuple[zeros:int, ones:int]
var counts = initTable[int, Stats]()
var N: int
for line in stdin.lines:
  if line.isEmptyOrWhitespace:
    continue
  N = len(line)
  for i in 0..<N:
    if i notin counts:
      counts[i] = (zeros: 0, ones: 0)
    if line[i] == '0':
      inc(counts[i].zeros)
    elif line[i] == '1':
      inc(counts[i].ones)

var
  gamma: int
  epsilon: int
for i in 0..<N:
  gamma = 2*gamma + (if counts[i].zeros > counts[i].ones: 0 else: 1)
  epsilon = 2*epsilon + (if counts[i].zeros > counts[i].ones: 1 else: 0)

echo(gamma*epsilon)
