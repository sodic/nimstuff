import tables

type 
  Container = ref object
    name: char
    index: int
    arr: array[5,int]
  Map = Table[int, Container]

# proc `$`(map: Map): string =
#   for key, value in map:
#     result = result & $key & ": " & $value


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
# echo someMap