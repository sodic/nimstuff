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


type 
  Stogovni = object
    value: int
  Gomilni = ref object
    value: int

proc changeValue(o: ref Stogovni): void =
  o.value = 5


proc changeValue(o: Gomilni): void =
  o.value = 5

# var stog = Stogovni() 
# changeValue(stog[])
# echo stog.value

var gomila = Gomilni() 
changeValue(gomila)
echo gomila.value


echo "pocinje tablica"

var table = initTable[int, string]()
for i in 0..19:
  discard table.mgetOrPut(i, "marko")
for i in 0..19:
  discard table.mgetOrPut(i, "luka")
for i in 0..19:
  discard table.mgetOrPut(i, "ivan")

for key in table.keys:
  echo key