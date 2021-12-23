import strutils
import sequtils
import sugar
import strformat
import sets

type Cell = tuple[val: int, marked: bool]
type Board = array[5, array[5, Cell]]


proc readNumbers(f: File): seq[int] =
  for l in f.lines:
    if l.isEmptyOrWhitespace:
      continue
    return l.split(',').map(x => x.parseInt)

proc readBoard(f: File): Board =
  var row = 0
  for l in f.lines:
    if l.isEmptyOrWhitespace:
      continue
    let numbers = l.split(' ').filter(x => not x.isEmptyOrWhitespace).map(x => x.parseInt)
    for i, n in numbers.pairs:
      result[row][i] = (val: n, marked: false)
    inc(row)
    if row == 5:
      break

proc readBoards(f: File): seq[Board] =
  while not f.endOfFile:
    result.add(readBoard(f))

proc markNumber(board: var Board, n: int) =
  for i in 0..<5:
    for j in 0..<5:
      if board[i][j].val == n:
        board[i][j].marked = true
        return

proc isWinning(board: Board): bool =
  for i in 0..<5:
    # check if i-th row is fully marked
    var rowMarked = true
    for j in 0..<5:
      rowMarked = rowMarked and board[i][j].marked
    # check if i-th column is fully marked
    var columnMarked = true
    for j in 0..<5:
      columnMarked = columnMarked and board[j][i].marked

    if rowMarked or columnMarked:
      return true
  return false

proc score(board: Board, lastNumber: int): int =
  var sumUnmarked = 0
  for i in 0..<5:
    for j in 0..<5:
      if not board[i][j].marked:
        sumUnmarked += board[i][j].val

  return sumUnmarked * lastNumber


var numbers: seq[int]
var boards: seq[Board]
var finalScore: int

numbers = stdin.readNumbers
boards = stdin.readBoards

proc partOne() =
  block outer:
    for n in numbers:
        for i, board in boards.mpairs:
          markNumber(board, n)
          if board.isWinning:
            echo(&"Board {i+1} is winning with number {n}")
            finalScore = score(board, n)
            break outer

  echo(finalScore)

proc partTwo() =
  var won = initHashSet[int]()
  var remaining = len(boards)
  block outer:
    for n in numbers:
      for i, board in boards.mpairs:
        if not won.contains(i):
          markNumber(board, n)
          if board.isWinning:
            won.incl(i)
            dec(remaining)
            if remaining == 0:
              echo(&"Board {i+1} is the last to win with number {n}")
              finalScore = score(board, n)
              break outer

  echo(finalScore)

partTwo()

