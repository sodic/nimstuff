import deques
import eventData
import positionData
import utilities
import tables 
import sequtils
import iStorage

type SlidingDeque* = ref object
  deq: Deque[PositionData]
  submit: proc (data: PositionData): void
  initialSize: int # estimated maximum size of the double ended queue
  beginning: int

proc newSlidingDeque*(initialSize: int, 
                    submitProc: proc (data: PositionData): void): SlidingDeque =
  let adjustedSize = powerOf2Ceil(initialSize)
  SlidingDeque(
    deq: initDeque[PositionData](adjustedSize),
    submit: submitProc, 
    initialSize: adjustedSize, 
    beginning: 0
  )

proc submitDeq(self: SlidingDeque, deq: var Deque[PositionData]): void =
  # todo implement
  # asyncronous function
  # Submits the current deque to another thread for handling
  for element in deq:
    self.submit(element)


proc resetDeq(self: SlidingDeque, beginning: int) =
  # Submits the current deque and replaces it with a new one
  #
  # PARAMTERS:
  # self - this sliding deque
  # beginning - the beginning position of the new deque
  self.submitDeq(self.deq)
  self.deq = initDeque[PositionData](self.initialSize)
  self.beginning = beginning

proc record*(
    self: SlidingDeque, 
    position: int,
    value: string,
    refBase: char
  ): void =
  if position >= (self.beginning + self.deq.len):
    self.deq.addLast(newPositionData(self.deq.len + self.beginning, refBase))
  
  self.deq[position - self.beginning].increment(value)

proc flushAll*(self: SlidingDeque): int =
  result = self.deq.len
  self.resetDeq(0)

proc flushUpTo*(self: SlidingDeque, position: int): int = 
  ## Flushes/submits all finished slots in the storage. This is meant to be 
  ## called when starting to process a new read
  ## 
  ## @return the number of flushed items (primarily for testing and debugging purposes,
  ## feel free to remove when in release)
  if position < self.beginning:
    raise newException(ValueError, "Invalid order of positions.")
  
  # if a new start position is larger than all positions contained in
  # the deque, instead of emptying it manually, we can submit it and
  # make a new one  
  if position >= self.beginning + self.deq.len:
    result = self.deq.len
    self.resetDeq(position)
    self.beginning = position
    return

  while self.beginning < position:
    self.submit(self.deq.popFirst())
    self.beginning.inc

proc recordStart(
    self: SlidingDeque, 
    position: int, 
    readValue: string,
    refBase: char
  ): void =
  ## Used to handle the first position in a new read.
  ## Submits all positions which all smaller and only then updates
  ## the storage. 
  ## 
  ## PARAMETERS:
  ## self - this sliding deque
  ## position - the starting index of the new read (wrt. the reference)
  ## readValue - the string found at the position on the read
  discard self.flushUpTo(position)
  self.record(position, readValue, refBase)

proc getIStorage*(self: SlidingDeque): IStorage=
  return (
        record: proc(position: int,value: string,refBase: char): void= 
          self.record(position, value, refBase),
        flushUpTo: proc(position: int): int = 
          self.flushUpTo(position),
        flushAll: proc(): int  = 
          self.flushAll()
       )

when isMainModule:
  block:
    var pairs = [
      (given: 10, adjusted: 16),
      (given: 789, adjusted: 1024)
    ]
    for pair in pairs:
      var storage = newSlidingDeque(pair.given, proc (d: PositionData): void = echo d[])
      doAssert storage.initialSize == pair.adjusted
      doAssert storage.deq.len == 0
      doAssert storage.beginning == 0

    block:
      var actual : seq[PositionData] = @[]
      var storage = newSlidingDeque(20, proc (d: PositionData): void = actual.add(d))
      
      storage.recordStart(0,"A", 'A')
      storage.record(1,"A", 'A')
      storage.record(2, "C", 'A')
      storage.record(3,"A", 'A')
      doAssert storage.deq.len == 4
      doAssert storage.beginning == 0

      storage.recordStart(0,"A", 'A')
      storage.record(1,"T", 'A')
      storage.record(2, "G", 'A')
      storage.record(3,"A", 'A')
      doAssert storage.deq.len == 4
      doAssert storage.beginning == 0

      storage.recordStart(0,"A", 'A')
      storage.record(1,"T", 'A')
      storage.record(2, "-AC", 'A')
      storage.record(5,"G", 'G')
      doAssert storage.deq.len == 6, $storage.deq.len
      doAssert storage.beginning == 0

      storage.recordStart(10, "A", 'A')
      doAssert storage.deq.len == 1
      doAssert storage.beginning == 10

      var expected = @[
        {"A": 3}.toTable, 
        {"A": 1, "T": 2}.toTable, 
        {"C": 1, "G": 1, "-AC": 1}.toTable,
        {"A": 2}.toTable,
        toTable[string, int]({:}), 
        {"G": 1}.toTable
      ]

      for idx, pair in zip(actual, expected):
        echo pair[0][]
        echo pair[1]
        doAssert pair[0].events == pair[1]






