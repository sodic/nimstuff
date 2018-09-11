import os
import iSequence
import positionData
import slidingDeque
import messaging
import pileup
import hts

var bam: Bam
open(bam, paramStr(1), index=true)

var fai: Fai
if not open(fai, paramStr(2)):
  quit("Could not open fasta file.")

var storage = newslidingDeque(20, proc(d: PositionData): void = echo createJsonMessage(d))

pileup(bam, fai.getISequence(), storage)