import os
import sequtils
import strutils

type Node = 
  ref object
    case empty: bool
      of false: 
        value: int
        left: Node
        right: Node
      else:
        discard

proc emptyNode(): Node = Node(empty:true)

proc fullNode(element: int): Node =
  Node(
    empty: false,
    value: element,
    left: emptyNode(),   
    right: emptyNode() 
  )  

proc add(tree: var Node, element: int) : void =
  if tree.empty:
    tree = fullNode(element)
    return

  if element < tree.value:
    tree.left.add(element)

  elif element > tree.value:
    tree.right.add(element)

# no recursive iterators yet
iterator preorder(node: Node): int =
  var stack : seq[Node] = @[node]
  
  while stack.len > 0:
    var current = stack.pop()
    
    while not current.empty:
      yield current.value
      stack.add(current.right)
      current = current.left

iterator inorder(node: Node): int = 
  var current = node
  var stack: seq[Node] = @[]
  
  while stack.len > 0 or not current.empty:
    while not current.empty:
      stack.add(current)
      current = current.left

    current = stack.pop()
    yield current.value
    current = current.right

var t = emptyNode()
for e in stdin.readLine().split().map(parseInt):
  t.add(e)

for el in t.inorder():
  echo el