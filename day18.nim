import sugar
import sets
import strutils
import strformat
import sequtils

type SnNumber = ref object
  n: int
  parent, left, right: SnNumber

proc `$`(s: SnNumber): string =
  if s == nil:
    echo("Snafu, s is nil")
  if s.left != nil:
    return &"[{$(s.left)}, {$(s.right)}]"
  return $(s.n)

proc newSnNumber(left, right: SnNumber): SnNumber =
  let rv = SnNumber(left: left, right: right)
  left.parent = rv
  right.parent = rv
  return rv

proc parseSnNumber(s: string): SnNumber =
  let digits = collect:
    for i in 0..9: {char(i + int('0'))}
  proc parseInternal(s: string): (SnNumber, int) =
    var i = 0
    while i < s.len and s[i] in Whitespace:
      inc(i)
    if s[i] in digits:
      var n = 0
      while i < s.len and s[i] in digits:
        n = n*10 + (int(s[i]) - int('0'))
        inc(i)
      return (SnNumber(n: n), i)
    assert s[i] == '[' and s[^1] == ']'
    let (left, lenLeft) = parseInternal(s[i+1..^1])
    assert s[i+lenLeft+1] == ','
    let (right, lenRight) = parseInternal(s[i+lenLeft+2..^1])
    return (newSnNumber(left, right), lenLeft + lenRight + i + 3)

  return parseInternal(s)[0]

proc firstNumberToLeft(n: SnNumber): SnNumber =
  var
    currentNode = n.parent
    prevNode = n
  while currentNode != nil:
    if currentNode.left == prevNode:
      # can't go left, continue up
      prevNode = currentNode
      currentNode = currentNode.parent
    else:
      currentNode = currentNode.left
      while currentNode.right != nil:
        currentNode = currentNode.right
      return currentNode
  return nil

proc firstNumberToRight(n: SnNumber): SnNumber =
  var
    currentNode = n.parent
    prevNode = n
  while currentNode != nil:
    if currentNode.right == prevNode:
      # can't go right, continue up
      prevNode = currentNode
      currentNode = currentNode.parent
    else:
      currentNode = currentNode.right
      while currentNode.left != nil:
        currentNode = currentNode.left
      return currentNode
  return nil

proc isPair(n: SnNumber): bool =
  return n.left != nil and n.right != nil

proc explodeOne(n: SnNumber): bool =
  proc explodeInternal(n: SnNumber, height: int): bool =
    if height >= 4:
      assert n.left != nil and n.right != nil and n.left.left == nil and n.right.left == nil
      let
        firstLeft = firstNumberToLeft(n)
        firstRight = firstNumberToRight(n)
      if firstLeft != nil:
        firstLeft.n += n.left.n
      if firstRight != nil:
        firstRight.n += n.right.n

      if n == n.parent.left:
        n.parent.left = SnNumber(n: 0, parent: n.parent)
      else:
        n.parent.right = SnNumber(n: 0, parent: n.parent)
      return true
    else:
      if n.left != nil and isPair(n.left):
        if explodeInternal(n.left, height+1):
          return true
      if n.right != nil and isPair(n.right):
        if explodeInternal(n.right, height+1):
          return true
      return false

  # Use `or` for short-circuiting
  return explodeInternal(n.left, 1) or explodeInternal(n.right, 1)

proc splitOne(n: SnNumber): bool =
  proc splitInternal(n: SnNumber): bool =
    if not isPair(n) and n.n >= 10:
      let
        lval = n.n div 2
        rval = n.n - lval
      let newNum = newSnNumber(SnNumber(n: lval), SnNumber(n: rval))
      if n.parent.left == n:
        n.parent.left = newNum
      else:
        n.parent.right = newNum
      newNum.parent = n.parent
      return true
    else:
      if n.left != nil and splitInternal(n.left):
        return true
      if n.right != nil and splitInternal(n.right):
        return true
      return false
  return  splitInternal(n)

func deepCopy(s: SnNumber): SnNumber =
  if not s.isPair:
    return SnNumber(n: s.n)
  return newSnNumber(deepCopy(s.left), deepCopy(s.right))

proc `+`(s1, s2: SnNumber): SnNumber =
  # TODO: Explode/split
  let res = newSnNumber(deepCopy(s1), deepCopy(s2))
  var done = false
  while not done:
    done = not (explodeOne(res) or splitOne(res))
  return res

func magnitude(s: SnNumber): int =
  if isPair(s):
    return magnitude(s.left)*3 + magnitude(s.right)*2
  return s.n


var snNumbers: seq[SnNumber]
for line in stdin.lines:
  if line.isEmptyOrWhitespace:
    continue
  snNumbers.add(parseSnNumber(line))

proc partOne() =
  echo(snNumbers.foldl(a+b).magnitude)

proc partTwo() =
  var maxMagnitudeOfSum = int.low
  for i in 0..<len(snNumbers):
    for j in 0..<len(snNumbers):
      if i == j:
        continue
      let m = magnitude(snNumbers[i] + snNumbers[j])
      if m > maxMagnitudeOfSum:
        maxMagnitudeOfSum = m

  echo(maxMagnitudeOfSum)

partTwo()