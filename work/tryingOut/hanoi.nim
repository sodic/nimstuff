import os
import strutils
import sequtils
import sets

type Node = ref object
  parent: Node
  depth: int
  config: string

proc getSuccFunction(numberOfDisks: int) : (proc (config: string) : seq[string]) = 
  let possibilities = toSet(['A', 'B', 'C'])
  return proc (config: string) : seq[string] =
    result = @[]

    for index, position in config:
      let before = config[0..<index]
      let after = config[index+1..<config.len]
      
      if after.contains(position):
        continue

      var unavailable = toSet(after)
      unavailable.incl(position)

      for possibility in possibilities - unavailable:
        result.add(before & possibility & after)

proc getGoalFunction(numberOfDisks: int) : proc (config: string): bool =
  let final = "C".repeat(numberOfDisks)
  return proc (config: string) : bool =
    config == final


proc initial(numberOfDisks: int) : Node =
  Node(config: "A".repeat(numberOfDisks), depth: 0, parent: nil)

proc expand(parent: Node, 
            succ: proc (config:string): seq[string]
            ): seq[Node] = 
  return succ(parent.config)
    .map(proc (c: string) : Node = 
      Node(config: c, depth: parent.depth + 1, parent: parent)
    )


proc restore(node: Node): string =
  if node.parent == nil:
    return node.config

  return restore(node.parent) & "\n" & node.config 

proc hamilton(current: Node, 
              visited: HashSet[string],
              succ: proc (config: string) : seq[string],
              goal: proc (config: string) : bool
              ) : Node =
  
  let children = current
    .expand(succ)
    .filter(proc(child: Node): bool = not (child.config in visited))
  
  if children.len == 0 or goal(current.config):
    return current

  return children
    .map(proc(child: Node) : Node = 
      hamilton(child, visited + toSet([current.config]), succ, goal)
    )
    .foldl(if a.depth > b.depth: a else: b)


if paramCount() != 1:
  quit "Unesite broj diskova."


let numberOfDisks = parseInt(paramStr(1))
var s = initSet[string](8)
echo hamilton(
  initial(numberOfDisks), 
  s, 
  getSuccFunction(numberOfDisks),
  getGoalFunction(numberOfDisks)
).restore()