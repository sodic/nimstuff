proc fib_generator : (proc (): int) = 
  var 
    former = 0
    current = 1
  return proc () : int = 
    result = current
    current = former + current
    former = result


var gen = fib_generator()
for i in 0..20:
  echo gen()