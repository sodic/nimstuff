import os
import iStorage
import storageFactory
import positionData
import messaging
import pileup
import hts

var bam: Bam
open(bam, paramStr(1), index=true)

var storage = getStorage(paramStr(2), 20, proc (d: PositionData): void = echo createJsonMessage(d))
pileup(bam, storage)