iterator mycount(a, b: int): int {.closure.} =
  var x = a
  while x <= b:
    yield x
    inc x

iterator testIterator() : int {.closure.} =
  for i in 1..5:
    yield i

# var c = mycount # instantiate the iterator
# while not finished(c):
#   echo c(1, 3)

var a = testIterator
echo a()
for i in a:
  echo i