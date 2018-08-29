import tables

#
#Serves as a counting map for events.
#The standard class CountMap is to slow.
#
type EventData* = Table[string, int]

func initEventData*(): EventData = 
  initTable[string, int]()


proc increment*(data: var EventData, key: string) : void =
  if data.hasKeyOrPut(key, 1):
    data[key] = data[key] + 1

func `[]`*(data: var EventData, key: string): int =
  data.getOrDefault(key)


when isMainModule:
  block:
    var data = initEventData()
    doAssert data["a"] == 0
    doAssert data["b"] == 0
    doAssert data.len == 0

  block:
    var data = initEventData()
    data.increment("a")
    data.increment("a")
    data.increment("c")
    doAssert data.len == 2
    doAssert data["a"] == 2
    doAssert data["c"] == 1
