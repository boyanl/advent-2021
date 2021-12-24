import tables
import sugar
import strutils
import algorithm
import sequtils

let openingBraces = ['(', '[', '{', '<']
let closingBraces = [')', ']', '}', '>']
proc isOpeningBrace(c: char): bool =
  return c in openingBraces

proc getMatchingPairs(): Table[char, char] =
  # Seems like we can't insert 2 mappings per iteration with the collect macro
  for i in 0..<len(openingBraces):
    result[openingBraces[i]] = closingBraces[i]
    result[closingBraces[i]] = openingBraces[i]


var matchingPairs = getMatchingPairs()
proc matchingBraces(c1, c2: char): bool =
  return matchingPairs[c1] == c2

proc firstIllegalCharacter(s: string): (bool, char) =
  var braces: seq[char]
  for c in s:
    if c.isOpeningBrace:
      braces.add(c)
    else: # closing brace
      if matchingBraces(c, braces[^1]):
        discard braces.pop
      else:
        return (true, c)
  return (false, ' ')

proc toStr(s: seq[char]): string =
  for c in s:
    result.add(c)

proc completionNeeded(s: string): string =
  var braces: seq[char]
  for c in s:
    if c.isOpeningBrace:
      braces.add(c)
    else: # closing brace
      assert matchingBraces(c, braces[^1])
      discard braces.pop
  return braces.reversed.map(c => matchingPairs[c]).toStr

func score(completion: string): int =
  let scores = {')': 1, ']': 2, '}': 3, '>': 4}.toTable
  let base = 5
  for c in completion:
    result = result * base + scores[c]

proc partOne() =
  let scores = {')': 3, ']': 57, '}': 1197, '>': 25137}.toTable
  var sum = 0
  for line in stdin.lines:
    let (corrupted, character) = firstIllegalCharacter(line)
    if corrupted:
      sum += scores[character]

  echo(sum)

proc partTwo() =
  var scores: seq[int]
  for line in stdin.lines:
    if line.isEmptyOrWhitespace or firstIllegalCharacter(line)[0]:
      continue
    let completion = completionNeeded(line)
    scores.add(score(completion))

  let result = scores.sorted[len(scores) div 2]
  echo(result)

partTwo()