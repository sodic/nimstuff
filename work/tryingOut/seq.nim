import sequtils, future

var list : seq[string] = @[]
list.add("deckooo")
list.add("nisi")
list.add("ti")
list.add("to")
list.add("savlado")

echo map(list, x => x & " PLOP")