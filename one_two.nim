
import strutils
import sequtils

const windowSize = 3

func sum(arr: seq[int]): int =
  return arr.foldl(a+b)

var
  cnt = 0
  prevWindow: seq[int]
  currentWindow: seq[int]
for line in stdin.lines:
  let depth = line.parseInt
  if len(currentWindow) < windowSize:
    currentWindow.add(depth)
  else:
    prevWindow = currentWindow
    currentWindow = currentWindow[1..<currentWindow.len] & depth
    if sum(currentWindow) > sum(prevWindow):
      inc(cnt)

  prevWindow = currentWindow


echo(cnt)