import hts

var fai: Fai
discard open(fai, "../pileup/data/fsl.fa")
var name = fai[0]
discard fai[0]
discard fai[0]
discard fai[0]
discard fai[0]
discard fai[0]
discard fai[0]
echo fai.get(name, 0, 2)