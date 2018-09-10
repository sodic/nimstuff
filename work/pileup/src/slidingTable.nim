import sets
import sequtils
import tables 
import positionData  

type SlidingTable* = ref object
  table: Table[int, PositionData]
  indices: HashSet[int]
  initialSize: int
  submit : proc (data: PositionData): void

proc newSlidingTable*(initialSize: int, 
                     submitProc: proc (data: PositionData): void
                    ): SlidingTable =
  SlidingTable(initialSize: initialSize, submit: submitProc)


proc dispose(self: SlidingTable, current: int): void =
  # try to turn this into a regular filter
  iterator filterSet[T](s: HashSet, predicate: proc (x: T): bool): T = 
    for element in s:
      if predicate(element):
        yield element

  for index in self.indices.filterSet(proc (i: int): bool = i < current):
    var value : PositionData
    discard self.table.take(index, value)
    self.submit(value) # make async


proc handleRegular(self: var SlidingTable, position: int, value: string, 
                   refBase: char): void =
  self.indices.incl(position)
  self.table.mgetOrPut(position, newPositionData(position, refBase)).increment(value)

proc handleStart(self: var SlidingTable, position: int, value: string,
                 refBase: char): void =
  self.dispose(position) # make async
  self.handleRegular(position, value, refBase)

