import eventData

type
  PositionData* = ref object
    referenceIndex*: int
    referenceBase*: char
    events*: EventData
    # chromosome: string

proc newPositionData* : PositionData =
  PositionData(referenceIndex: 0, referenceBase: '/', events: initEventData())

proc newPositionData*(referenceIndex: int) : PositionData =
  PositionData(
    referenceIndex: referenceIndex,
    referenceBase: '/',
    events: initEventData()
  )

proc increment*(positionData: var PositionData, value: string) =
  positionData.events.increment(value)

proc `$`*(positionData: var PositionData): string =
  "(" & "referenceIndex: " & $positionData.referenceIndex & ", referenceBase: " & $positionData.referenceBase & ", events: " & $positionData.events & ")"
    