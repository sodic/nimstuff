import hts

var fai: Fai
discard open(fai, "../pileup/data/fsl.fa")
var sequence = fai.get("ref", 0, 4)
echo sequence
echo fai.get("ref", 0, 2)