import strutils
import sequtils
import sugar
import tables

type Entry = tuple[signals: seq[string], outputs: seq[string]]

proc readEntry(line: string): Entry =
  let split = line.split("|")
  let
    signalsStr = split[0]
    outputsStr = split[1]
  result.signals = signalsStr.split(" ").filter(x => not x.isEmptyOrWhitespace)
  result.outputs = outputsStr.split(" ").filter(x => not x.isEmptyOrWhitespace)

func toSet(s: string): set[char] =
  for c in s:
    result.incl(c)

func signalsWithLen(e: Entry, l: int): seq[string] =
  return e.signals.filter(x => len(x) == l)

let signalsForDigit = @["abcefg", "cf", "acdeg", "acdfg", "bcdf",
                        "abdfg", "abdefg", "acf", "abcdefg", "abcdfg"].map(x => x.toSet)

let all = "abcdefg".toSet

proc checkIfOnlyOneCanBeMappedTo(signals: set[char], val: char, possibilities: Table[char, set[char]]): (bool, char) =
  var cntPossible = 0
  var lastCandidate: char
  for c in signals:
    if possibilities[c].contains(val):
      inc(cntPossible)
      lastCandidate = c
  if cntPossible == 1:
    return (true, lastCandidate)
  return (false, lastCandidate)

proc removeFromPossibilities(val: char, where: set[char], possibilities: var Table[char, set[char]]) =
  for e in where:
    possibilities[e] = possibilities[e] - {val}

proc updateConstraints(signals, segments: set[char], possibilities: var Table[char, set[char]]) =
  for c in signals:
    possibilities[c] = possibilities[c] * segments

  var updatedAnything = true
  while updatedAnything:
    updatedAnything = false

    for t in segments:
      let (have, signal) = signals.checkIfOnlyOneCanBeMappedTo(t, possibilities)
      if have and len(possibilities[signal]) > 1:
        possibilities[signal] = {t}
        removeFromPossibilities(t, all - {signal}, possibilities)
        updatedAnything = true

    for t in all:
      let (have, signal) = all.checkIfOnlyOneCanBeMappedTo(t, possibilities)
      if have and len(possibilities[signal]) > 1:
        possibilities[signal] = {t}
        removeFromPossibilities(t, all - {signal}, possibilities)
        updatedAnything = true


proc determineMapping(e: Entry): Table[char, char] =
  var possibilities = initTable[char, set[char]]()
  for c in 'a'..'g':
    possibilities[c] = all

  let firstWithLen = (e:Entry, l:int) => e.signalsWithLen(l)[0].toSet
  proc reversePossibilities(c: char): set[char] =
    for c1 in all:
      if possibilities[c1].contains(c):
        result.incl(c1)
  proc reversePossibilitiesForAll(cs: set[char]): set[char] =
    for c in cs:
      result = result + reversePossibilities(c)

  # The segments for 1 are "cf". We can find which one is the "encoded" version of 1 (the only one with 2 segments)
  # and figure out which 2 elements map to "cf"
  updateConstraints(firstWithLen(e, 2), signalsForDigit[1], possibilities)
  # The segments for 7 are "acf", therefore we can figure out which signal maps to "a"
  updateConstraints(firstWithLen(e, 3), signalsForDigit[7], possibilities)
  # Segments for 4 are "bcdf". We already know which 2 signals map to "cf" (as a set), so we can figure out which 2 map to "bd"
  # (this is done manually by specifying which set difference to update constraints for; the function updating the constraints isn't that smart)
  updateConstraints(firstWithLen(e, 4), signalsForDigit[4], possibilities)
  updateConstraints(firstWithLen(e, 4) - firstWithLen(e, 2), signalsForDigit[4] - signalsForDigit[1], possibilities)
  # The intersection of the segments for digits 2, 3 and 5 (those with 5 segments) is "adg". We already know which signal maps to "a"
  # So we can deduce which 2 signals map to "dg". Also, we know which 2 signals map to "bd" (from the previous step), so we can figure out what signal maps to "d"
  # (but again, we must explicitly specify the sets of interest)
  # Once we know 'd', then 'b' and 'g' are known as well. Once those are known then 'a' and 'e' can be known as well.
  # (which one maps to 'e' is deduced not by the constraints that we've seen thus far, but by exclusion - there remains only one possibility for 'e')
  updateConstraints(e.signalsWithLen(5).map(x => x.toSet).foldl(a * b), "adg".toSet, possibilities)
  updateConstraints(firstWithLen(e, 4) - firstWithLen(e, 2), signalsForDigit[4] - signalsForDigit[1], possibilities)
  # The only thing remaining at this point is to figure out which signal maps to 'c' and which to 'f'
  # (remember, from digit '1' we know which set of 2 signals maps to {c, f}. But we don't know which one is which)
  # To figure that out, we use the fact that segment 'c' is the intersection of segments for 1 and 2
  let uniqueSignalsFor2 = reversePossibilitiesForAll("adeg".toSet) # figure out which signals map to {a, d, e, g} (we know all of them by now)
  let digit2 = e.signalsWithLen(5).filter(x => x.toSet * uniqueSignalsFor2 == uniqueSignalsFor2)[0]
  updateConstraints(digit2.toSet - uniqueSignalsFor2, {'c'}, possibilities)

  for c, v in possibilities:
    assert len(v) == 1
    result[c] = toSeq(v)[0]

proc digitForOutput(output: string, mapping: Table[char, char]): int =
  var mapped: set[char] = {}
  for c in output:
    mapped.incl(mapping[c])
  for i in 0..9:
    if signalsForDigit[i] == mapped:
      return i

proc fromDigits(digits: seq[int]): int =
  for d in digits:
    result = result * 10 + d

proc partOne() =
  func count1478(entry: Entry): int =
    for v in entry.outputs:
      if len(v) in {2, 3, 4, 7}:
        inc(result)

  var totalCount = 0
  for line in stdin.lines:
    let e = readEntry(line)
    inc(totalCount, count1478(e))

  echo(totalCount)

proc partTwo() =
  var answer = 0
  for line in stdin.lines:
    let e = readEntry(line)
    let mapping = determineMapping(e)
    let digits = e.outputs.map(x => digitForOutput(x, mapping))
    let number = fromDigits(digits)
    answer += number

  echo(answer)

partTwo()