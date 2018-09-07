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

# No recursive iterator in the language
# iterator inorder(node: Node) : int =
    
#   for el in inorder(node.left): 
#     yield el

#   yield node.value

#   for el in inorder(node.right): 
#     yield el

proc emptyNode(): Node = Node(empty:true)

proc fullNode(element: int): Node =
  Node(
    empty: false,
    value: element,
    left: emptyNode(),   
    right: emptyNode() 
  )  

proc inorder(tree: Node): seq[int] =
  var prop : seq[int] = @[]

  proc inorderR (node: Node) : void =
    if node.empty:
      return

    node.left.inorderR()
    prop.add(node.value)
    node.right.inorderR()
  
  tree.inorderR()
  return prop

# why does't this work
# proc add(tree: var Node, element: int) : void =

#   proc addToParent(parent: var Node, element: int) : void 

#   proc addR(node: var Node, element: int) : void =
#     if element == node.value:
#       return
#     echo "here"
#     var parent = if element < node.value: node.left else: node.right
#     parent.addToParent(element)
#     echo parent.empty

#   proc addToParent(parent: var Node, element: int) : void =
#     if parent.empty:
#       echo "tu sam"
#       parent = fullNode(element)
#     elif element > parent.value:
#       parent.addR(element)

#   case tree.empty 
#     of true: tree = fullNode(element)
#     else: tree.addR(element)



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

echo t.inorder() 
