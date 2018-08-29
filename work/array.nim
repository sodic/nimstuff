var a : array[10, int]

for i in 0..<10:
  a[i] = (i+1)*10

for i in countup(1, 9, 2):
  echo a[i];

for i in countup(0, 9, 2):
  a[i] *= 5
  
echo a