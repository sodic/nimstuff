import deques
import eventData
import positionData
import utilities
import tables 
import sequtils

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


proc resetDeq(self: var SlidingDeque, beginning: int) =
  # Submits the current deque and replaces it with a new one
  #
  # PARAMTERS:
  # self - this sliding deque
  # beginning - the beginning position of the new deque
  self.submitDeq(self.deq)
  self.deq = initDeque[PositionData](self.initialSize)
  self.beginning = beginning

proc handleRegular*(
    self: var SlidingDeque, 
    position: int,
    value: string,
    refBase: char = '/'
  ): void =
  while position >= (self.beginning + self.deq.len):
    self.deq.addLast(newPositionData(self.deq.len + self.beginning))
  
  self.deq[position - self.beginning].increment(value)

proc handleStart*(
    self: var SlidingDeque, 
    position: int, 
    readValue: string,
    refValue: char
  ): void =
  # Used to handle the first position in a new read.
  # Submits all positions which all smaller. 
  # 
  # PARAMETERS:
  # self - this sliding deque
  # position - the starting index of the new read (wrt. the reference)
  # readValue - the string found at the position on the read
  if position < self.beginning:
    raise newException(ValueError, "Invalid order of positions.")
  
  # if a new start position is larger than all positions contained in
  # the deque, instead of emptying it manually, we can submit it and
  # make a new one  
  if position >= self.beginning + self.deq.len:
    self.resetDeq(position)

  while self.beginning < position:
    self.submit(self.deq.popFirst())
    self.beginning += 1

  self.handleRegular(position, readValue)

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
      
      storage.handleStart(0,"A", 'A')
      storage.handleRegular(1,"A", 'A')
      storage.handleRegular(2, "C", 'A')
      storage.handleRegular(3,"A", 'A')
      doAssert storage.deq.len == 4
      doAssert storage.beginning == 0

      storage.handleStart(0,"A", 'A')
      storage.handleRegular(1,"T", 'A')
      storage.handleRegular(2, "G", 'A')
      storage.handleRegular(3,"A", 'A')
      doAssert storage.deq.len == 4
      doAssert storage.beginning == 0

      storage.handleStart(0,"A", 'A')
      storage.handleRegular(1,"T", 'A')
      storage.handleRegular(2, "-AC", 'A')
      storage.handleRegular(5,"G", 'G')
      doAssert storage.deq.len == 6, $storage.deq.len
      doAssert storage.beginning == 0

      storage.handleStart(10, "A", 'A')
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






