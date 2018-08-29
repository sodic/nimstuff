import deques
import eventData
import positionData

type
  PositionData = object
    referenceIndex: int
    referenceBase: char
    events: EventData

type SlidingMap = object
  deq: Deque[PositionData]
  maxSize: int # estimated maximum size of the double ended queue
  beginning: int

proc initSlidingMap(maxSize: int): SlidingMap =
  SlidingMap(
    deq: initDeque[PositionData](maxSize), 
    maxSize: maxSize, 
    beginning: 0
  )

proc submitDeq(map: SlidingMap): void =
  # todo implement
  # asyncronous function
  # Submits the current deque to another thread for handling
  discard 

proc submitOne(map: SlidingMap): void =
  # todo implement
  # asyncronous function
  # Submits the last item in the deque to another thread for handling
  discard 

proc resetDeq(map: var SlidingMap, beginning: int) =
  # Submits the current deque and replaces it with a new one
  #
  # PARAMTERS:
  # map - the map
  # beginning - the beginning position of the new deque
  map.submitDeq()
  map.deq = initDeque[PositionData](map.maxSize)
  map.beginning = beginning

proc handleRegular(map: var SlidingMap, position: int, value: string): void =
  assert position <= (map.beginning + map.deq.len)
  if position == map.beginning + map.deq.len:
    map.deq.addFirst(newPositionData(position))
  else:
    map.deq[position - map.beginning].increment(value)

proc handleStart(map: var SlidingMap, position: int, value: string): void =
  # Used to handle the first position in a new read.
  # Submits all positions which all smaller. 
  # 
  # PARAMETERS:
  # map - the map
  # position - the starting index of the new read (wrt. the reference)
  # value - the string found at the position on the read
  if position < map.beginning:
    raise newException(IndexError, "The BAM file is not sorted.")
  
  # if a new start position is larger than all positions contained in
  # the deque, instead of emptying it manually, we can submit it and
  # make a new one  
  if position >= map.beginning + map.deq.len:
    map.resetDeq(position)

  while map.beginning < position:
    map.submitOne()
    map.beginning += 1

  map.handleRegular(position, value)





