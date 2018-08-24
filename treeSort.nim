import os
import strutils
import sequtils

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

proc inorder(tree: Node): seq[int] =
  proc inorderR (node: Node, acc: var seq[int]) : void =
    if node.empty: 
      return

    node.left.inorderR(acc)
    acc.add(node.value)
    node.right.inorderR(acc)
  
  tree.inorderR(result)

# no recursive iterators yet
iterator preorder(node: Node): int =
  var stack : seq[Node] = @[node]
  while stack.len > 0:
    var current = stack.pop()
    while not current.empty:
      yield current.value
      stack.add(current.right)
      current = current.left

# TODO: implement inorder iterator

proc add(tree: var Node, element: int) : void =
  if tree.empty:
    tree = fullNode(element)
    return

  if element < tree.value:
    tree.left.add(element)
  elif element > tree.value:
    tree.right.add(element)


var t = emptyNode()
for e in stdin.readLine().split().map(parseInt):
  t.add(e)

for e in t.preorder():
  echo e
