import tables
import sequtils

type BaseCounter* = array[6, int]

proc indexFor(base: char): int = 
  case base 
    of '-': 0
    of 'a': 1
    of 't': 2
    of 'g': 3
    of 'c': 4
    else: 5

proc increment*(counter: var BaseCounter, base: char) : void =
  let index = indexFor(base)
  counter[index] = counter[index] + 1

when isMainModule:
  var counter : BaseCounter

  var str = "accatgtagct"
  for base in str:
    counter.increment(base)

  for key, value in counter:
    echo key, ": ", value

# proc initBaseCounter(): BaseCounter =
#   initTable[char, int]()
# proc increment(plop: var BaseCounter, key: char) : void =
#   if plop.hasKeyOrPut(key, 1):
#     plop[key] = plop[key] + 1