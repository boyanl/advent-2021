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
proc mark(fromSet, toSet: set[char], mapping: var Table[char, set[char]]) =
  for c in fromSet:
    mapping[c] = mapping[c] * toSet

  var updatedAnything = true
  while updatedAnything:
    updatedAnything = false
    for t in all:
      var cntPossible = 0
      var lastCandidate: char
      for updateSet in @[fromSet, all]:
        for c in updateSet:
          if mapping[c].contains(t):
            inc(cntPossible)
            lastCandidate = c
        if cntPossible == 1 and len(mapping[lastCandidate]) > 1:
          mapping[lastCandidate] = {t}
          updatedAnything = true

      for c in fromSet:
        if mapping[c] == {t}:
          for c2 in all - {c}:
            if mapping[c2].contains(t):
              mapping[c2] = mapping[c2] - {t}
              updatedAnything = true
          break

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

  mark(firstWithLen(e, 2), signalsForDigit[1], possibilities)
  mark(firstWithLen(e, 3), signalsForDigit[7], possibilities)
  mark(firstWithLen(e, 4), signalsForDigit[4], possibilities)
  mark(firstWithLen(e, 4) - firstWithLen(e, 2), signalsForDigit[4] - signalsForDigit[1], possibilities)
  mark(e.signalsWithLen(5).map(x => x.toSet).foldl(a * b), "adg".toSet, possibilities)
  mark(firstWithLen(e, 4) - firstWithLen(e, 2), signalsForDigit[4] - signalsForDigit[1], possibilities)
  let uniqueSignalsFor2 = reversePossibilitiesForAll("adeg".toSet)
  let digit2 = e.signalsWithLen(5).filter(x => x.toSet * uniqueSignalsFor2 == uniqueSignalsFor2)[0]
  mark(digit2.toSet - uniqueSignalsFor2, signalsForDigit[2] - "adeg".toSet, possibilities)

  for c, v in possibilities:
    if len(v) != 1:
      echo("Snafu .. possibilities for: ", c, ": ", v)
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