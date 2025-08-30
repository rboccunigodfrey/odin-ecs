// ======================
// IMPL::COMPONENTS
// ======================

package ecs

// general purpose components


PrevPosition :: struct {
  using pos: [3]f32
}

Position :: struct {
  using pos: [3]f32,
}

CameraFollow :: struct {
  camera_dir: matrix[2,2]f32
}

// camera components

Camera :: struct {
  camera: CameraType,
  target: [3]f32,
  up: [3]f32,
  fovy: f32,
  direction: matrix[2,2]f32,
  projection: CameraProjection
} 

CameraMousePan :: struct {}

// physical entity components

Physics :: struct {
  vel: [3]f32,
  acc: [3]f32,
  damp: f32,
  collision_damp: f32
}

Controller :: struct {
  speed: f32,
  k_up, k_down, k_left, k_right, k_backward, k_forward, k_sprint: KeyboardKey
}


RectRenderer :: struct {
  size: [2]f32,
  color: Color
}

CircleRenderer :: struct {
  d: f32,
  color: Color
}

CubeRenderer :: struct {
  size: [3]f32,
  color: Color
}

SphereRenderer :: struct {
  d: f32,
  color: Color
}


CubeCollider :: struct {
  size: [3]f32
}

RandMover :: struct {speed: f32}





// Pyllbug-specific components

PyllRenderer :: struct {
  using circle: CircleRenderer
}

Neighbor :: struct {
  id: Maybe(u64),
  dist: f32
}

Neighbors :: struct  {
  ids: [NUM_NN]Neighbor,
  size: i32,
  closest: Maybe(u64),
  closest_dist: f32,
}

NNMover :: struct {
  speed: f32
}


Pyll :: struct {}
KeepInScreen :: struct {}
RenderNeighborPaths :: struct {}



register_components :: proc () {
  component_register(Camera)
  component_register(CameraMousePan)

  component_register(PrevPosition)
  component_register(Position)
  component_register(Physics)
  //component_register(RectRenderer)
  //component_register(CircleRenderer)
  component_register(CameraFollow)
  component_register(CubeRenderer)
  component_register(SphereRenderer)  
  component_register(PyllRenderer)
  component_register(Pyll)
  component_register(RandMover)
  component_register(Controller)
  component_register(NNMover)
  component_register(KeepInScreen)
  component_register(CubeCollider)
  component_register(Neighbors)
  component_register(RenderNeighborPaths)
}
