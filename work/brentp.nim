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
  

# I should perhaps remove this as it is just a special case for 
# reportMatcher. However, I left it for semantic reasons and encapsulation
# (e.g. beginning of the read)
proc reportMatch[StorageType](storage: var StorageType,
                              readIndex: int, refIndex: int,
                              read: Record, reference: Record): void =
  ## Tells the provided storage about one matching base between the read and the 
  ## reference.
  ##
  ## @param storage The storage object keeping track of the pile-up information.
  ## @param readIndex The index of the matching base on the read.
  ## @param refIndex  The index of the mathcing base on the reference.
  ## @param read A record holding the read sequence.
  ## @param reference A record holding the reference sequence
  storage.handleRegular(refIndex, $read.baseAt(readIndex),reference.baseAt(refIndex))

proc reportMatches[StorageType](storage: var StorageType, 
                                readStart: int, refStart: int, length: int, 
                                read: Record, reference: Record) : void =
  ## Tells the provided storage about a matching substring
  ## multiple continuos matching bases) between the read and the reference.
  ##
  ## @param storage The storage object keeping track of the pile-up information.
  ## @param readStart The starting match index on the read.
  ## @param refStart  The starting match index on the reference.
  ## @param length The total length of the matching substring.
  ## @param read A record holding the read sequence.
  ## @param reference A record holding the reference sequence.
  if length == 1:
    reportMatch(storage, readStart, refStart, read, reference)
    return

  for offset in countUp(0, length - 1):
    reportMatch(storage, readStart + offset, refStart + offset, read, reference)
  
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
      readOnlyOffset = 0
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
          reportMatches(storage, 
                        mutualOffset + readOnlyOffset, mutualOffset + refOnlyOffset,
                        event.len, 
                        read, reference)

        elif consumes.reference:
          # reference only, report deletion
          reportMissing(storage, mutualOffset + refOnlyOffset, event.len, '-', reference)
          refOnlyOffset += event.len

        elif consumes.query:
          # query only, report insertion
          reportMissing(storage, mutualOffset + readOnlyOffset, event.len, '+', read)
          readOnlyOffset += event.len
        
        else:
          raise newException(ValueError, "?????")

        mutualOffset += event.len

open(bam, paramStr(1), index=true)
var map = getStorage[SlidingDeque](2000, proc (d: PositionData): void = echo d[])
for chromosome in targets(bam.hdr):
  process(chromosome, map)
