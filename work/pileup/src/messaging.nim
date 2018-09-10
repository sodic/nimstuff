import json
import positionData

proc createJsonMessage*(data: PositionData): string = $(%data) & "\c\l"