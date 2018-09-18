import hts
import os 

var bam: Bam
open(bam, paramStr(1), index=true)

var plop = false
for chromosome in targets(bam.hdr):
  for read in bam.querys(chromosome.name):
    echo "next read"
    var offset = read.start
    for event in read.cigar:
      if event.consumes.query:
        var a = read.baseAt(offset)
        if a == '.':
          echo event
          echo offset
          echo read
          var s = ""
          for miniOffset in countUp(0, event.len):
            # echo "ple"
            echo $(offset + miniOffset)
            s &= read.baseAt(miniOffset + offset)
          echo s
          plop = true
        if plop:
          discard stdin.readLine()

