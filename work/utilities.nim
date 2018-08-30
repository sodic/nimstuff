proc powerOf2Ceil*(number: int): int =
  result = number - 1;
  result = result or (result shr 1); 
  result = result or (result shr 2); 
  result = result or (result shr 4);
  result = result or (result shr 8);
  result = result or (result shr 16);
  result += 1;

when isMainModule:
  block:
    var pairs = [
      (0,0), # special case
      (1,1),
      (2,2),
      (5,8),
      (16,16),
      (17,32),
      (600,1024)
    ]
    for pair in pairs:
      doAssert powerOf2Ceil(pair[0]) == pair[1]
  echo "All tests passed"