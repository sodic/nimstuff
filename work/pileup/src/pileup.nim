import hts 

func lenAsInt(target: Target): int =
  result = cast[int](target.length)
  # if result < 0:
  #   raise newException(RangeError, "Chromosome length out of range for integers")

# I should perhaps remove this as it is just a special case for 
# reportMatches. However, I left it for semantic reasons and encapsulation
# (e.g. beginning of the read)
proc reportMatch[TSequence, TStorage](storage: var TStorage,
                 readIndex: int, refIndex: int,
                 read: Record, reference: TSequence): void =
  ## Tells the provided storage about one matching base between the read and the 
  ## reference.
  ##
  ## @param storage The storage object keeping track of the pile-up information.
  ## @param readIndex The index of the matching base on the read.
  ## @param refIndex  The index of the mathcing base on the reference.
  ## @param read A record holding the read sequence.
  ## @param reference A record holding the reference sequence
  # if read.baseAt(readIndex) == '.':
    # echo read
  storage.record(refIndex, $read.baseAt(readIndex), reference.baseAt(refIndex))



proc reportMatches[TSequence, TStorage](storage: var TStorage, 
                   readStart: int, refStart: int, length: int, 
                   read: Record, reference: TSequence) : void =
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
  

proc reportInsertion[TSequence, TStorage](storage: var TStorage,
                     readStart: int, refIndex: int, length: int,
                     read: Record, reference: TSequence): void =
  ## Tells the provided storage about an insertion on the read with regards to
  ## the reference. An insertion consists of one or more bases found on the read
  ## but not on the reference.
  ## 
  ## @param storage The storage object keeping track of the pile-up information.
  ## @param readStart The starting index of the insertion on the read.
  ## @param refIndex The index of the reference base.  
  var value = "+"

  for offset in countUp(readStart, readStart + length - 1):
    value &= read.baseAt(offset)

  # insertion is reported on the base that preceeds it
  storage.record(refIndex - 1, value , '/')



proc reportDeletion[TSequence, TStorage](storage: var TStorage,
                    readStart: int, refStart: int, length: int,
                    reference: TSequence): void =
  var value = "-"

  for offset in countUp(refStart, refStart + length - 1):
    value &= reference.baseAt(offset) 
    storage.record(offset, "*", reference.baseAt(offset))

  # deletion is reported on the base that preceeds it
  storage.record(refStart - 1, value, '/')



proc processEvent[TSequence, TStorage](event: CigarElement, storage: var TStorage, 
                  read: Record, reference: TSequence,
                  mutualOffset: var int, readOnlyOffset: var int, 
                  refOnlyOffset: var int): void =

  let operation = event.op
  if operation == soft_clip:
    readOnlyOffset += 1
    return
  if operation == hard_clip: raise newException(ValueError, "hard clip")
  assert operation != ref_skip and operation != pad, "Illegal operation"


  let consumes = event.consumes()
  
  if consumes.query and consumes.reference: 
    # mutual, report all matches
    reportMatches(storage, 
                  mutualOffset + readOnlyOffset, mutualOffset + refOnlyOffset,
                  event.len, 
                  read, reference)
    mutualOffset += event.len

  elif consumes.reference:
    # reference only, report deletion
    reportDeletion(storage, 
                   mutualOffset + readOnlyOffset, mutualOffset + refOnlyOffset,
                   event.len, reference)
    refOnlyOffset += event.len

  elif consumes.query:
    # query only, report insertion
    reportInsertion(storage, 
                    mutualOffset + readOnlyOffset, mutualOffset + refOnlyOffset,
                    event.len, read, reference)
    readOnlyOffset += event.len

proc pileup*[TSequence, TStorage](bam: var Bam, reference: TSequence, storage: var TStorage) =
  for chromosome in targets(bam.hdr):
    for read in bam.query(chromosome.name, 0, chromosome.lenAsInt - 1):
      var 
        mutualOffset = read.start
        readOnlyOffset = 0
        refOnlyOffset = 0

      # since the file is sorted, we can safley flush any information related to
      # indices smaller than the current start of the read
      discard storage.flushUpTo(read.start) #todo can a read begin with deletion/insertion
      for event in read.cigar:
        processEvent(event, storage, read, reference, 
                     mutualOffset, readOnlyOffset, refOnlyOffset)
    discard storage.flushAll()