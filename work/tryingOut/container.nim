# import slidingMap
import json
import tables
import deques

type 
  Container = ref object
    name: char
    index: int
    arr: array[5,int]
  Map = Table[int, Container]

  Something = ref object
    f: proc (a: int): int

proc initSomething(g: proc(a: int) : int): Something =
  Something(f: g)

proc `$`(contanier: Container): string =
  $(contanier[])

proc `$`(map: Map): string =
  for key, value in map:
    result = result & $key & ": " & $value



proc newContainer(): Container =
  Container(
    name: 'c',
    index: 1,
    arr: [1,2,3,4,5]
  )

proc initMap() : Map =
  initTable[int, Container]()

proc next(a: int): int = a + 1

var someContainer = Container()
someContainer.arr[0] = 1
someContainer.arr[4] = 4
someContainer.arr[2] = 2
someContainer.index = 5
someContainer.name = 's'

var someMap = initMap()
for i in 0..4:
  var data = someMap.mgetOrPut(i, Container())
  data.name = char(65 + i)
  data.index = i
  data.arr[1] = i
  data.arr[2] = i + 1
  

echo someContainer[]


var d = initDeque[Container](16)
d.addFirst(newContainer())
d.addFirst(newContainer())
d.addFirst(newContainer())
echo d
# echo someMap

var s = initSomething(next)
echo s.f(5)
# var map = newSlidingMap(5)
# map.handleRegular(
#   position: 5, 
#   value: "asd",
#   refBase: '4'
# )

var tablica = initTable[string, int]()
tablica["marko"] = 1
tablica["luka"] = 6
var a = %tablica