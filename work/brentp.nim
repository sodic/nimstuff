import os
import hts 
import strutils
import storageFactory
import positionData
import slidingDeque

var bam:Bam
  
func lenAsInt(target: Target): int =
  result = cast[int](target.length)
  # if result < 0:
  #   raise newException(RangeError, "Chromosome length out of range for integers")

proc eventIterator(cigar: Cigar): (iterator (): CigarElement)  =
  return iterator(): CigarElement {.closure.} = 
    for event in cigar:
      yield event
  

proc reportMatches[StorageType](storage: var StorageType, start: int, length: int, 
                                read: Record, reference: Record) : void =
  for offset in countUp(0, length - 1):
    storage.handleRegular(start, $read.baseAt(start + offset),
                          reference.baseAt(start + offset)
                         )
  
proc reportMissing[StorageType](storage: var StorageType, start: int, length: int, 
                                sign: char, sequence: Record): void =
  var buffer = ""

  for offset in countUp(0, length - 1):
    buffer &= sequence.baseAt(start + offset)

  storage.handleRegular(start, sign & buffer,'/')


proc process[StorageType](chromosome: Target, storage: var StorageType) : void =

  var counter = 0
  for read in bam.query(chromosome.name, 0, chromosome.lenAsInt - 1):
    var 
      mutualOffset = read.start
      queryOnlyOffset = 0
      refOnlyOffset = 0

    var nextEvent = eventIterator(read.cigar)

    # we need to handle the start of the read separately
    let start = nextEvent()


    for reference in bam.query("adsf", 0, 90):
      while true: # silly iterators with the finished thing
        let event = nextEvent()
        if finished(nextEvent):
          break

        let consumes = event.consumes()
        
        if consumes.query and consumes.reference: 
          # mutual, report all matches
          reportMatches(storage, mutualOffset, event.len, read, reference)

        elif consumes.reference:
          # reference only, report deletion
          reportMissing(storage, mutualOffset + refOnlyOffset, event.len, '-', reference)
          refOnlyOffset += event.len

        elif consumes.query:
          # query only, report insertion
          reportMissing(storage, mutualOffset + queryOnlyOffset, event.len, '+', read)
          queryOnlyOffset += event.len
        
        else:
          raise newException(ValueError, "?????")

        mutualOffset += event.len

open(bam, paramStr(1), index=true)
var map = getStorage[SlidingDeque](2000, proc (d: PositionData): void = echo d[])
for chromosome in targets(bam.hdr):
  process(chromosome, map)
