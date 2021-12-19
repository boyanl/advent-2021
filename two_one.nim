import strscans

var pos = (0, 0)
for line in stdin.lines:
  var amount: int
  var dir: (int, int)
  if scanf(line, "forward $i", amount):
    dir = (1, 0)
  elif scanf(line, "down $i", amount):
    dir = (0, 1)
  elif scanf(line, "up $i", amount):
    dir = (0, -1)
  pos = (pos[0] + amount*dir[0], pos[1] + amount*dir[1])

echo(pos[0]*pos[1])