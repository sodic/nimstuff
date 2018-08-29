import os
import hts 
import tables
import eventData
import strutils
import positionData


type Histogram = Table[int, PositionData]


proc `$`(histogram: Histogram): string =
  for key, value in histogram:
    result = result & $key & ": " & $value & "\n"

var bam:Bam

proc initHistogram(): Histogram = initTable[int, PositionData]()


proc update(histogram: var Histogram, 
            index: int, 
            key: string, 
            referenceIndex: int
          ): void =
  let data = histogram.mgetOrPut(index, newPositionData())
  data.referenceIndex = index
  data.events.increment(key)

proc update(histogram: var Histogram, 
            index: int, 
            base: char, 
            referenceIndex: int
          ): void =
  update(histogram, index, base & "", referenceIndex)
  
func lenAsInt(target: Target): int =
  result = cast[int](target.length)
  if result < 0:
    raise newException(RangeError, "Chromosome length out of range for integers")


proc process(chromosome: Target) : void =
  var histogram = initHistogram()
  var counter = 0
  for read in bam.query(chromosome.name, 0, chromosome.lenAsInt - 1):
    counter.inc
    if counter > 400:
        break

    echo read.qname
    var
      offset = read.start
      queryOffset = 0
      exclusiveRefOffset = 0
     
    for event in read.cigar:
      let consumes = event.consumes()
      
      if consumes.query:
        queryOffset += event.len
      
      if consumes.reference:
        offset += event.len
        if not consumes.query:
          exclusiveRefOffset += event.len

      let position = queryOffset - (offset - exclusiveRefOffset)
      if position < 0:
        break # todo figure out

      let base = read.baseAt(offset)
      let quality = read.baseQualityAt(position)

      histogram.update(offset, base, offset)

  echo histogram

open(bam, paramStr(1), index=true)
for chromosome in targets(bam.hdr):
  process(chromosome)





# var position = 830146
# let ref_allele = 'G'
# for alignedRead in bam.query("PseudomonaLESB58.fa", 0, position + 1):
#   var 
#     off = alignedRead.start
#     qoff = 0
#     roff_only = 0
#     nalt = 0
#     nref = 0
#   for event in alignedRead.cigar:
#     var cons = event.consumes
#     if cons.query:
#       qoff += event.len
#     if cons.reference:
#       off += event.len
#       if not cons.query:
#         roff_onl y+= event.len
#     # continue until we get to the genomic position
#     if off <= position: continue
#     # since each cigar op can consume many bases
#     # calc how far past the requested position
#     var over = off - position - roff_only
#     # get the base 
#     var base = alignedRead.base_at(qoff - over)
#     if base == ref_allele:
#       nref += 1
#     else:
#       nalt += 1
#   echo nref, nalt
#   # now nalt and nref are the allele counts ready for use.   