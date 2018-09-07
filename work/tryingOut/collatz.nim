var
  number = 5

var output = $number

while number != 1:
  if number mod 2 == 1:
    output.add(" -> odd -> ")
    output.add("3*" & $number & "+1")
    number *= 3
    inc number
  else:
    output.add(" -> even -> ")
    output.add($number & "/2")
    number = number div 2
  
  output.add(" = " & $number)

output.add("-> end")

echo output


