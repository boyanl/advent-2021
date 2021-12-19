import strscans

type State = tuple[x: int, d: int, aim: int]
var pos: State

for line in stdin.lines:
  var amount: int
  var delta: State
  if scanf(line, "forward $i", amount):
    delta = (x: amount, d: pos.aim * amount, aim: 0)
  elif scanf(line, "down $i", amount):
    delta = (x: 0, d: 0, aim: amount)
  elif scanf(line, "up $i", amount):
    delta = (x: 0, d: 0, aim: -amount)
  pos = (x: pos.x + delta.x, d: pos.d + delta.d, aim: pos.aim + delta.aim)

echo(pos.x*pos.d)