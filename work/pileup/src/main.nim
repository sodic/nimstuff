import os
import iStorage
import iSequence
import storageFactory
import positionData
import messaging
import pileup
import hts

var bam: Bam
open(bam, paramStr(1), index=true)

var fai: Fai
if not open(fai, "data/fsl.fa"):
  quit("Could not open fasta file.")
  
var storage = getStorage(paramStr(3), 20, proc (d: PositionData): void = echo createJsonMessage(d))

pileup(bam, getISequence(fai), storage)