import os
import hts 
import strutils
import storageFactory
import positionData
import slidingDeque

type ReferenceMock = object
  data: string

proc baseAt(reference: ReferenceMock, index: int): char = reference.data[index]

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
                              read: Record, reference: ReferenceMock): void =
  ## Tells the provided storage about one matching base between the read and the 
  ## reference.
  ##
  ## @param storage The storage object keeping track of the pile-up information.
  ## @param readIndex The index of the matching base on the read.
  ## @param refIndex  The index of the mathcing base on the reference.
  ## @param read A record holding the read sequence.
  ## @param reference A record holding the reference sequence
  echo refIndex
  storage.handleRegular(refIndex, $read.baseAt(readIndex), reference.baseAt(refIndex))



proc reportMatches[StorageType](storage: var StorageType, 
                                readStart: int, refStart: int, length: int, 
                                read: Record, reference: ReferenceMock) : void =
  ## Tells the provided storage about a matching substring between
  ## the read and the reference.
  ## A matching substring consists of multiple continuos matching base.
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
  

proc reportInsertion[StorageType](storage: var StorageType,
                                  readStart: int, refIndex: int, length: int,
                                  read: Record): void =
  ## Tells the provided storage about an insertion on the read with regards to
  ## the reference. An insertion consists of one or more bases found on the read
  ## but not on the reference.
  ## 
  ## @param storage The storage object keeping track of the pile-up information.
  ## @param readStart The starting index of the insertion on the read.
  ## @param refIndex The index of the reference base.  
  var value = "-"

  for offset in countUp(0, length - 1):
    value &= read.baseAt(readStart + offset)

  storage.handleRegular(refIndex, value ,'/')



proc reportDeletion[StorageType](storage: var StorageType,
                                 readStart: int, refStart: int, length: int,
                                 reference: ReferenceMock): void =
  var value = "+"

  for offset in countUp(0, length - 1):
    value &= reference.baseAt(refStart + offset) 
    storage.handleRegular(refStart + offset, "*", '/')

  storage.handleRegular(refStart, value, '/')



proc processEvent[StorageType](event: CigarElement, storage: var StorageType, 
                               read: Record, reference: ReferenceMock,
                               mutualOffset: var int, readOnlyOffset: var int, 
                               refOnlyOffset: var int): void =
  let consumes = event.consumes()
  
  if consumes.query and consumes.reference: 
    # mutual, report all matches
    reportMatches(storage, 
                  mutualOffset + readOnlyOffset, mutualOffset + refOnlyOffset,
                  event.len, 
                  read, reference)

  elif consumes.reference:
    # reference only, report deletion
    reportInsertion(storage, 
                    mutualOffset + readOnlyOffset, mutualOffset + refOnlyOffset,
                    event.len, read)
    refOnlyOffset += event.len

  elif consumes.query:
    # query only, report insertion
    reportDeletion(storage, 
                   mutualOffset + readOnlyOffset, mutualOffset + refOnlyOffset,
                   event.len, reference)
    readOnlyOffset += event.len

  mutualOffset += event.len


proc process[StorageType](chromosome: Target, storage: var StorageType) : void =

  var counter = 0
  let reference = ReferenceMock(data: "AACACGCCTTAAGTATTATT") # somehow get the reference
  for read in bam.query(chromosome.name, 0, chromosome.lenAsInt - 1):
    echo "ple"
    var 
      mutualOffset = read.start
      readOnlyOffset = 0
      refOnlyOffset = 0

    # since the file is sorted, we can safley flush any information related to
    # indices smaller than the current start of the read
    discard storage.flushUpTo(read.start)
    for event in read.cigar:
      processEvent(event, storage, read, reference, 
                   mutualOffset, readOnlyOffset, refOnlyOffset)


open(bam, paramStr(1), index=true)
var map = getStorage[SlidingDeque](2000, proc (d: PositionData): void = echo d[])
for chromosome in targets(bam.hdr):
  process(chromosome, map)
