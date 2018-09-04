import deques
import eventData
import positionData
import utilities
import tables 
import sequtils

type SlidingMap* = ref object
  deq: Deque[PositionData]
  submit: proc (data: PositionData): void
  maxSize: int # estimated maximum size of the double ended queue
  beginning: int

proc newSlidingMap*(maxSize: int, 
                    submitProc: proc (data: PositionData): void): SlidingMap =
  let adjustedSize = powerOf2Ceil(maxSize)
  SlidingMap(
    deq: initDeque[PositionData](adjustedSize),
    submit: submitProc, 
    maxSize: adjustedSize, 
    beginning: 0
  )

proc submitDeq(map: SlidingMap, deq: var Deque[PositionData]): void =
  # todo implement
  # asyncronous function
  # Submits the current deque to another thread for handling
  for element in deq:
    map.submit(element)


proc resetDeq(map: var SlidingMap, beginning: int) =
  # Submits the current deque and replaces it with a new one
  #
  # PARAMTERS:
  # map - the map
  # beginning - the beginning position of the new deque
  map.submitDeq(map.deq)
  map.deq = initDeque[PositionData](map.maxSize)
  map.beginning = beginning

proc handleRegular*(
    map: var SlidingMap, 
    position: int,
    value: string,
    refBase: char = '/'
  ): void =
  while position >= (map.beginning + map.deq.len):
    map.deq.addLast(newPositionData(map.deq.len + map.beginning))
  
  map.deq[position - map.beginning].increment(value)

proc handleStart*(
    map: var SlidingMap, 
    position: int, 
    readValue: string,
    refValue: char
  ): void =
  # Used to handle the first position in a new read.
  # Submits all positions which all smaller. 
  # 
  # PARAMETERS:
  # map - the map
  # position - the starting index of the new read (wrt. the reference)
  # readValue - the string found at the position on the read
  if position < map.beginning:
    raise newException(ValueError, "Invalid order of positions.")
  
  # if a new start position is larger than all positions contained in
  # the deque, instead of emptying it manually, we can submit it and
  # make a new one  
  if position >= map.beginning + map.deq.len:
    map.resetDeq(position)

  while map.beginning < position:
    map.submit(map.deq.popFirst())
    map.beginning += 1

  map.handleRegular(position, readValue)

when isMainModule:
  block:
    var pairs = [
      (given: 10, adjusted: 16),
      (given: 789, adjusted: 1024)
    ]
    for pair in pairs:
      var map = newSlidingMap(pair.given, proc (d: PositionData): void = echo d[])
      doAssert map.maxSize == pair.adjusted
      doAssert map.deq.len == 0
      doAssert map.beginning == 0

    block:
      var actual : seq[PositionData] = @[]
      var map = newSlidingMap(20, proc (d: PositionData): void = actual.add(d))
      
      map.handleStart(0,"A", 'A')
      map.handleRegular(1,"A", 'A')
      map.handleRegular(2, "C", 'A')
      map.handleRegular(3,"A", 'A')
      doAssert map.deq.len == 4
      doAssert map.beginning == 0

      map.handleStart(0,"A", 'A')
      map.handleRegular(1,"T", 'A')
      map.handleRegular(2, "G", 'A')
      map.handleRegular(3,"A", 'A')
      doAssert map.deq.len == 4
      doAssert map.beginning == 0

      map.handleStart(0,"A", 'A')
      map.handleRegular(1,"T", 'A')
      map.handleRegular(2, "-AC", 'A')
      map.handleRegular(5,"G", 'G')
      doAssert map.deq.len == 6, $map.deq.len
      doAssert map.beginning == 0

      map.handleStart(10, "A", 'A')
      doAssert map.deq.len == 1
      doAssert map.beginning == 10

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






