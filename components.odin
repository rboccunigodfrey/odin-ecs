// ======================
// IMPL::COMPONENTS
// ======================

package ecs

import rl "vendor:raylib"

PrevPosition :: struct {
  using pos: [2]i32
}

Position :: struct {
  using pos: [2]i32,
}

Physics :: struct {
  vel: [2]f32,
  acc: [2]f32,
  damp: f32,
  collision_damp: f32
}

Controller :: struct {
  speed: i32,
  k_up, k_down, k_left, k_right, k_sprint: rl.KeyboardKey
}

RectRenderer :: struct {
  w, h: i32,
  color: rl.Color
}

CircleRenderer :: struct {
  d: i32,
  color: rl.Color
}

RectCollider :: struct {
  w, h: i32
}

RandMover :: struct {speed: i32}

KeepInScreen :: struct {}




// Pyllbug-specific components


Pyll :: struct {}

PyllRenderer :: struct {
  using circle: CircleRenderer
}

Neighbor :: struct {
  id: u64,
  dist: i32
}

Neighbors :: struct  {
  ids: [NUM_NN]Neighbor
}



register_components :: proc () {
  component_register(PrevPosition)
  component_register(Position)
  component_register(Physics)
  component_register(RectRenderer)
  component_register(CircleRenderer)
  component_register(PyllRenderer)
  component_register(Pyll)
  component_register(RandMover)
  component_register(Controller)
  component_register(KeepInScreen)
  component_register(RectCollider)
  
}
