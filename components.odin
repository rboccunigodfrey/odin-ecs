// ======================
// IMPL::COMPONENTS
// ======================

package ecs

// general purpose components


PrevPosition :: struct {
  using pos: [3]f16
}

Position :: struct {
  using pos: [3]f16,
}

RotationMatrix2D :: matrix[2,2]f16
RotationMatrix3D :: [3]matrix[3,3]f16 

CameraFollow :: struct {
  camera_dir: RotationMatrix2D
}

// camera components

Camera :: struct {
  camera: CameraType,
  target: [3]f16,
  up: [3]f16,
  fovy: f16,
  direction: RotationMatrix2D,
  projection: CameraProjection
} 

CameraMousePan :: struct {}

// mouse components

Mouse :: struct {
  using pos: [2]f16,
  scale: [2]f16,
  offset: [2]i32,
}

// physical entity components

Physics :: struct {
  vel: [3]f16,
  acc: [3]f16,
  damp: f16,
  collision_damp: f16
}

Controller :: struct {
  speed, sprint_mult: f16,
  k_up, k_down, k_left, k_right, k_backward, k_forward, k_sprint: KeyboardKey
}


RectRenderer :: struct {
  size: [2]f16,
  color: Color
}

CircleRenderer :: struct {
  d: f16,
  color: Color
}

CubeRenderer :: struct {
  size: [3]f16,
  color: Color
}

SphereRenderer :: struct {
  d: f16,
  color: Color
}


CubeCollider :: struct {
  size: [3]f16
}

RandMover :: struct {speed: f16}





// Pyllbug-specific components

PyllRenderer :: struct {
  using circle: CircleRenderer
}

Neighbor :: struct {
  id: Maybe(u64),
  dist: f16
}

Neighbors :: struct  {
  ids: [NUM_NN]Neighbor,
  size: i32,
  closest: Maybe(u64),
  closest_dist: f16,
}

NNMover :: struct {
  speed: f16
}


Pyll :: struct {}
KeepInScreen :: struct {}
RenderNeighborPaths :: struct {}

