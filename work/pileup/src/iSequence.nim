import hts

type 
  ISequence* =  tuple[
    baseAt: proc(index: int): char {.closure.},
    substring: proc(first, last: int): string {.closure.},
  ]

proc getISequence*(fai: Fai): ISequence = 
  return (
      baseAt: proc (index: int): char = fai.get("NC_000913", index, index)[0],
      substring: proc (first, last: int): string = fai.get("NC_000913", first, last)
    )