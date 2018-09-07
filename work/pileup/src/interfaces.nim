import tables


type 
  IEventData* = tuple[
    increment: proc (data: var IEventData, key: string, quality: int),
    `[]`: func (data: var IEventData, key: string): Table[int, int],
    totalCount: proc (data: var IEventData, key: string): int
  ]

  IPositionData = tuple[
    refIndex: proc(): char,
    refBase: proc(): int,
    events: proc(): IEventData
  ]