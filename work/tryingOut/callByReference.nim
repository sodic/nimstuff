proc sideEffect(a: var int): void =
  a = 5



var marko = 9;
sideEffect(marko)
echo marko