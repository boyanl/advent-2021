import strutils

var
  cnt = 0
  previousDepth = -1
for line in stdin.lines:
  let depth = line.parseInt
  if depth > previousDepth and previousDepth != -1:
    inc(cnt)
  previousDepth = depth

echo(cnt)