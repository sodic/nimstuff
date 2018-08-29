var collatz = @[19]

var current = collatz[^1]
while current != 1:
  if current mod 2 == 1:
    current = current*3 + 1
  else:
    current = current div 2
  collatz.add(current)

echo "The length of the sequence is ", collatz.len, "."
for el in collatz: echo el
