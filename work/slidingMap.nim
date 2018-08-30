import deques
import eventData
import positionData
import utilities

type SlidingMap* = ref object
  deq: Deque[PositionData]
  maxSize: int # estimated maximum size of the double ended queue
  beginning: int

proc newSlidingMap*(maxSize: int): SlidingMap =
  let adjustedSize = powerOf2Ceil(maxSize)
  SlidingMap(
    deq: initDeque[PositionData](adjustedSize), 
    maxSize: adjustedSize, 
    beginning: 0
  )

proc submitDeq(map: SlidingMap): void =
  # todo implement
  # asyncronous function
  # Submits the current deque to another thread for handling
  discard #spawn submit(map.deq) 

proc submitOne(map: SlidingMap): void =
  # todo implement
  # asyncronous function
  # Submits the last item in the deque to another thread for handling
  discard #spawn submit(map.deq.popFirst()) 

proc resetDeq(map: var SlidingMap, beginning: int) =
  # Submits the current deque and replaces it with a new one
  #
  # PARAMTERS:
  # map - the map
  # beginning - the beginning position of the new deque
  map.submitDeq()
  map.deq = initDeque[PositionData](map.maxSize)
  map.beginning = beginning

proc handleRegular*(
    map: var SlidingMap, 
    position: int,
    value: string,
    refBase: char = '/'
  ): void =
  assert position <= (map.beginning + map.deq.len)
  if position == map.beginning + map.deq.len:
    map.deq.addFirst(newPositionData(position))
  else:
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
    map.submitOne()
    map.beginning += 1

  map.handleRegular(position, readValue)

when isMainModule:
  block:
    var pairs = [
      (given: 10, adjusted: 16),
      (given: 789, adjusted: 1024)
    ]
    for pair in pairs:
      var map = newSlidingMap(pair.given)
      doAssert map.maxSize == pair.adjusted
      doAssert map.deq.len == 0






