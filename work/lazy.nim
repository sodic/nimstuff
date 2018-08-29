import sequtils
import os
import strutils 
var a : seq[int] = @[]

for i in 1..parseInt(paramStr(1)):
  a.add(i)
a = a
.filter(proc(x: int): bool = x > 6)
.map(proc (x: int) : int = x*x)
.map(proc (x: int) : int = x*x)
.map(proc (x: int) : int = x + x)
.map(proc (x: int) : int = x*x*4)
.map(proc (x: int) : int = x*3)
echo "Done"