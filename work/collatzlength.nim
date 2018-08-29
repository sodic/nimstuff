proc collatz(starting_number: int) : seq[int] =
  result = @[starting_number]
  var current = starting_number

  while current != 1:
    if current mod 2 == 1:
      current = current*3 + 1
    else:
      current = current div 2
    result.add(current)


var record = (length: 0, number: 0)
for i in 2..100:
  let current_length = i.collatz.len
  if current_length  > record.length:
    record = (current_length, i)

echo "The longest has a length of ", 
  record.length, 
  " and starts with number ",
   record.number
