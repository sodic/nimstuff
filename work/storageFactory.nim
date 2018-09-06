import positionData
import slidingTable
import slidingDeque
proc getStorage*[StorageType](size: int = 2000,
                              submitProc: proc (data: PositionData): void
                             ): StorageType =
  when StorageType is SlidingDeque:
    result = newSlidingDeque(size, submitProc)
  when StorageType is SlidingTable:
    result = newSlidingTable(size, submitProc)