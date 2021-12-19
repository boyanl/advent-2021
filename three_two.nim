import strutils
import sequtils
import tables
import sugar

type Stats = tuple[zeros:int, ones:int]
func getStats(lines: seq[string]): Table[int, Stats] =
  var counts = initTable[int, Stats]()
  for line in lines:
    if line.isEmptyOrWhitespace:
      continue
    for i in 0..<line.len:
      if i notin counts:
        counts[i] = (zeros: 0, ones: 0)
      if line[i] == '0':
        inc(counts[i].zeros)
      elif line[i] == '1':
        inc(counts[i].ones)
  return counts

var lines = toSeq(stdin.lines).filter(x => not x.isEmptyOrWhitespace)
var N = lines[0].len

type RatingState = tuple[lines:seq[string], rating:int, done: bool]
var
  oxygen: RatingState
  co2: RatingState

oxygen.lines = lines
co2.lines = lines
for i in 0..<N:
  if not oxygen.done:
    let stats = getStats(oxygen.lines)
    let bit = if stats[i].ones >= stats[i].zeros: 1 else: 0

    oxygen.lines = oxygen.lines.filter(x => x[i] == (if bit == 1: '1' else: '0'))

    if oxygen.lines.len == 1:
      oxygen.done = true
      oxygen.rating = fromBin[int](oxygen.lines[0])

  if not co2.done:
    let stats = getStats(co2.lines)
    let bit = if stats[i].ones >= stats[i].zeros: 0 else: 1
    co2.lines = co2.lines.filter(x => x[i] == (if bit == 1: '1' else: '0'))

    if co2.lines.len == 1:
      co2.done = true
      co2.rating = fromBin[int](co2.lines[0])

echo(oxygen.rating * co2.rating)


