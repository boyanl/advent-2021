import strutils
import sets
import tables
import std/[deques, macros, sugar]
import sequtils

func addInFront(n: int64, digit: int8): int64 =
  var n1 = n
  var d1 = digit.int64
  while n1 > 0:
    n1 = n1 div 10
    d1 *= 10
  return d1 + n

macro compileAll(instructionsSeq: static[seq[seq[string]]]) =
  echo(instructionsSeq)
  result = newNimNode(nnkStmtList)
  for (i, instructions) in instructionsSeq.pairs:
    var fnDef = newNimNode(nnkFuncDef)
    fnDef.add(ident("compiled_" & $i)).add(newEmptyNode()).add(newEmptyNode())
    
    var formalParams = newNimNode(nnkFormalParams)
    formalParams.add(ident("int64"))
    var identDefs = newNimNode(nnkIdentDefs)
    identDefs.add(ident("w")).add(ident("z")).add(ident("int64")).add(newEmptyNode())
    formalParams.add(identDefs)
    fnDef.add(formalParams)

    fnDef.add(newEmptyNode()).add(newEmptyNode())

    var statements = newNimNode(nnkStmtList)
    var varSection = newNimNode(nnkVarSection)
    var varIdentDefs = newNimNode(nnkIdentDefs)
    # var z1, x, y: int
    varIdentDefs.add(ident("z1")).add(ident("x")).add(ident("y")).add(ident("int64")).add(newEmptyNode())
    varSection.add(varIdentDefs)
    statements.add(varSection)
    # z1 = z
    statements.add(newAssignment(ident("z1"), ident("z")))

    var inputW = instructions[0]
    assert inputW == "inp w"
    var modifyName = func(varName: string): string =
      if varName == "z": return "z1"
      return varName
    for instr in instructions[1..instructions.high]:
      let parts = instr.split(" ")
      let
        instrType = parts[0]
        o1 = parts[1]
        o2 = parts[2]
      let leftNode = ident(modifyName(o1))
      let rightNode = (if o2 in ["x", "y", "z", "w"]: ident(modifyName(o2)) else: newIntLitNode(o2.parseInt))
      case instrType:
      of "add":
        statements.add(infix(leftNode, "+=", rightNode))
      of "mul":
        statements.add(infix(leftNode, "*=", rightNode))
      of "div":
        statements.add(newAssignment(ident(modifyName(o1)), infix(leftNode, "div", rightNode)))
      of "mod":
        statements.add(newAssignment(ident(modifyName(o1)), infix(leftNode, "mod", rightNode)))
      of "eql":
        statements.add(newAssignment(ident(modifyName(o1)), newDotExpr(newPar(infix(leftNode, "==", rightNode)), ident("int64"))))

    var returnStmt = newNimNode(nnkReturnStmt)
    returnStmt.add(ident("z1"))
    statements.add(returnStmt)

    fnDef.add(statements)
    result.add(fnDef)

  var fnIdents: seq[NimNode]
  for i in instructionsSeq.low..instructionsSeq.high:
    fnIdents.add(ident("compiled_" & $i))

  let seqValueNode = newNimNode(nnkPrefix).add(ident("@"), newNimNode(nnkBracket).add(fnIdents))
  let varSection = newVarStmt(ident("funcs"), seqValueNode)
  
  result.add(varSection)


proc splitIntoParts(instrs: seq[string]): seq[seq[string]] =
  var current: seq[string]
  for s in instrs:
    if s == "inp w":
      if current.len > 0:
        result.add(current)
      current = @[]
    current.add(s)
  result.add(current)

const allInstructions = staticRead("24.input").split("\n").map(x => x.strip).filter(x => not x.isEmptyOrWhitespace).splitIntoParts
compileAll(allInstructions)

proc acceptableModelNumbers(): seq[int64] =
  var zvals = initHashSet[int]()
  zvals.incl(0)
  var nextZvals = initHashSet[int]()
  var prev = initTable[(int, int), seq[(int8, int)]]()

  var lastIp = 0
  for i in 1..14:
    var nextIp = lastIp
    for zv in zvals:
      for digit in 1..9:
        let newZ = funcs[i-1](digit, zv).int
        nextZvals.incl(newZ)
        prev.mgetOrPut((newZ, i), @[]).add((digit.int8, zv))
    zvals = nextZvals
    nextZvals = initHashSet[int]()
    lastIp = nextIp
  let lastDigitInputAndZ = prev[(0, 14)]
  var queue = initDeque[(int64, int, int)]()
  for (i, z) in lastDigitInputAndZ:
    queue.addLast((i.int64, z, 13))

  var numbers: seq[int64] = @[]
  while len(queue) > 0:
    let (numberSoFar, z, round) = queue.popFirst
    if round == 0:
      numbers.add(numberSoFar)
      continue

    for (digit, prevZ) in prev[(z, round)]:
      queue.addLast((addInFront(numberSoFar, digit), prevZ, round-1))
  return numbers


proc partOne() =
  let modelNumbers = acceptableModelNumbers()
  let result = modelNumbers[modelNumbers.maxIndex]
  echo(result)

proc partTwo() =
  let modelNumbers = acceptableModelNumbers()
  let result = modelNumbers[modelNumbers.minIndex]
  echo(result)

partOne()