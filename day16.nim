import tables
import strutils
import sequtils
import sugar
import strformat

type PacketType = enum
  ptLiteral, ptOperator

type Packet = ref object
  version: int
  typeId: int
  value: int
  packets: seq[Packet]

func `$`(p: Packet): string =
  var packetsStr: string
  for subpacket in p.packets:
    packetsStr = packetsStr & $(subpacket)

  return &"(version: {p.version}, typeId: {p.typeId}, value: {p.value}, packets: {packetsStr})"


proc parseLiteralValue(s: string): tuple[value: int, bitsUsed: int] =
  var pos = 0
  var valueStr: string
  var bitsUsed = 0
  while true:
    valueStr = valueStr & s[pos+1..pos+4]
    bitsUsed += 5
    if s[pos] == '0':
      break
    pos += 5
  return (fromBin[int](valueStr), bitsUsed)

func substrLen(s: string, f, len: int): string =
  return s[f..f+len-1]

proc readPacket(s: string): (Packet, int) =
  let version = fromBin[int](s.substrLen(0, 3))
  let typeId = fromBin[int](s.substrLen(3, 3))
  case typeId:
    of 4:
      # parse literal value
      let (value, bitsCnt) = parseLiteralValue(s[6..^1])
      return (Packet(version: version, typeId: typeId, value: value), bitsCnt + 6)
    else:
      # operator packet; parse sub-packets
      let lengthId = (if s[6] == '0': 0 else: 1)
      if lengthId == 0:
        let length = fromBin[int](s.substrLen(7, 15))
        var consumedSoFar = 0
        var subpackets: seq[Packet]
        while consumedSoFar < length:
          let (packet, bitsCnt) = readPacket(s[22+consumedSoFar..^1])
          subpackets.add(packet)
          consumedSoFar += bitsCnt
        return (Packet(version: version, typeId: typeId, packets: subpackets), 22 + consumedSoFar)
      elif lengthId == 1:
        let subpacketsCnt = fromBin[int](s.substrLen(7, 11))
        var consumedSoFar = 0
        var subpackets: seq[Packet]
        for i in 1..subpacketsCnt:
          let (packet, bitsCnt) = readPacket(s[18+consumedSoFar..^1])
          subpackets.add(packet)
          consumedSoFar += bitsCnt
        return (Packet(version: version, typeId: typeId, packets: subpackets), 18 + consumedSoFar)

let replacement = collect:
  for i in 0..15:
    {i.toHex(1)[0]: i.toBin(4)}

proc replaceHexDigits(hexStr: string): string =
  for c in hexStr:
    result = result & replacement[c]

let packetsHex = stdin.readLine
let packetsBinaryStr = replaceHexDigits(packetsHex)
let (packet, _) = readPacket(packetsBinaryStr)

proc partOne() =
  proc versionSum(p: Packet): int =
    var subpacketVersionSum = 0
    for sp in p.packets:
      subpacketVersionSum += versionSum(sp)
    return subpacketVersionSum + p.version

  echo(versionSum(packet))

proc partTwo() =
  proc evaluate(p: Packet): int =
    let vals = p.packets.map(sp => evaluate(sp))
    case p.typeId:
      of 0:
        return vals.foldl(a+b)
      of 1:
        return vals.foldl(a*b)
      of 2:
        return vals.foldl(min(a, b))
      of 3:
        return vals.foldl(max(a, b))
      of 4:
        return p.value
      of 5:
        return if vals[0] > vals[1]: 1 else: 0
      of 6:
        return if vals[0] < vals[1]: 1 else: 0
      of 7:
        return if vals[0] == vals[1]: 1 else: 0
      else:
        echo("Unexpected type: ", p.typeId)
        return -1

  echo(evaluate(packet))

partTwo()