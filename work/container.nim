import slidingMap
import tables
import deques

type 
  Container = ref object
    name: char
    index: int
    arr: array[5,int]
  Map = Table[int, Container]

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


var map = newSlidingMap(5)
map.handleRegular(
  position: 5, 
  value: "asd",
  refBase: '4'
)
