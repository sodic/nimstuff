echo "Hello World!"

let 
  a = 11
  b = 4

echo "a + b = ", a + b
echo "a - b = ", a - b
echo "a * b = ", a * b
echo "a / b = ", a / b
echo "a div b = ", a div b
echo "a mod b = ", a mod b

var
  p = "abc"
  q = "xyz"
  r = "z"

p.add("def") # mutable string
echo "p is now: ", p

q.add(r)
echo "q is now: ", q

echo "concat: ", p & ' ' & q
echo "p is still: ", p
echo "q is still: ", q