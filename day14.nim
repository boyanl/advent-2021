import tables
import strutils
import sequtils
import sugar
import algorithm

type Rules = Table[string, string]

proc readInput(): tuple[polymer: string, rules: Rules] =
  result.polymer = stdin.readLine
  discard stdin.readLine
  for line in stdin.lines:
    let parts = line.split("->").map(x => x.strip)
    result.rules[parts[0]] = parts[1]

func getMinAndMaxCnt(cnts: Table[char, int]): (int, int) =
  var
    minCnt = -1
    maxCnt = -1
  for k, v in cnts:
    if minCnt == -1 or v < minCnt:
      minCnt = v
    if maxCnt == -1 or maxCnt < v:
      maxCnt = v

  return (minCnt, maxCnt)

type PairCounts = Table[string, int]
func getPairsCounts(s: string): Table[string, int] =
  for i in 0..<len(s) - 1:
    let pair = s[i..i+1]
    inc(result.mgetOrPut(pair, 0))


func getLetterCounts(s: string): Table[char, int] =
  for c in s:
    inc(result.mgetOrPut(c, 0))

var (polymer, rules) = readInput()
var pairCounts = getPairsCounts(polymer)
var letterCounts = getLetterCounts(polymer)

proc step(pairCounts: var PairCounts, letterCounts: var Table[char, int]) =
  var delta: PairCounts
  for pair, cnt in pairCounts:
    if pair in rules:
      let toInsert = rules[pair]
      delta.mgetOrPut(pair, 0) -= cnt
      delta.mgetOrPut(pair[0] & toInsert, 0) += cnt
      delta.mgetOrPut(toInsert & pair[1], 0) += cnt
      letterCounts.mgetOrPut(toInsert[0], 0) += cnt

  for pair, cnt in delta:
    pairCounts.mgetOrPut(pair, 0) += cnt

proc partOne() =
  const steps = 10
  for i in 1..steps:
    step(pairCounts, letterCounts)

  let (minCnt, maxCnt) = getMinAndMaxCnt(letterCounts)
  echo(maxCnt - minCnt)

proc partTwo() =
  const steps = 40
  for i in 1..steps:
    step(pairCounts, letterCounts)

  let (minCnt, maxCnt) = getMinAndMaxCnt(letterCounts)
  echo(maxCnt - minCnt)

partTwo()