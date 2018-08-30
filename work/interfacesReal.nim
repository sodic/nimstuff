proc energy[PhysicalObject](o: PhysicalObject): float =
  0.5 * o.mass * o.speed * o.speed

type
  SimpleObject = ref object
    mass: float
    speed: float

type
  ComposedObject = object

proc mass(co: ComposedObject): float =
  # fancy calculation...
  42

proc speed(co: ComposedObject): float =
  # fancy calculation...
  42


let simple = SimpleObject(mass: 1.0, speed: 5.0)
echo simple.energy

let composed = ComposedObject()
echo composed.energy