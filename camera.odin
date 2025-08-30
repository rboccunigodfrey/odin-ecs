package ecs

import "core:fmt"

init_camera :: proc () {
  camera := entity_create()
  camera = entity_add_component(camera, Position{{0, -500, 0}})
  camera = entity_add_component(camera, Camera{
    target = {0, 0, 0},
    up = {0, -1, 0},
    fovy = 40,
    projection = .PERSPECTIVE
  })
  camera = entity_add_component(camera, CameraMousePan{})
}
