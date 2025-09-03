package ecs

import "core:math/rand"
import rl "vendor:raylib"

init_components :: proc () {
  component_register(Camera)
  component_register(CameraMousePan)
  component_register(Mouse)
  
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

init_systems :: proc () {
  system_register(system_rl_mouse_update, Mouse)
  system_register(system_camera_mouse_pan, Camera, Position, CameraMousePan)
    
  system_register(system_reset_acceleration, Physics)
  system_register(system_store_prevpos, Position, PrevPosition)
  
  system_register(system_move_player, Position, Controller)
  system_register(system_move_rand, Position, RandMover)  
  //system_register(system_move_towards_closest_nn, Position, Neighbors, NNMover)
  //system_register(system_move_rand, Position, Neighbors, NNMover, RandMover)
  system_register(system_calculate_velocity, Position, PrevPosition, Physics)
  system_register(system_spatial_hash_update_rect, Position, CubeCollider)
  system_register(system_detect_collisions, Position, CubeCollider)
  system_register(system_keep_in_screen, Position, KeepInScreen)
  system_register(system_calculate_pos_from_vel, Position, Physics)
  system_register(system_update_neighbors, Position, Neighbors)
  system_register(system_camera_follow, Position, CameraFollow)
  system_register(system_rl_camera_update, Camera, Position)

  system_register(system_render_nn_conns, Position, Neighbors, RenderNeighborPaths)
  system_register(system_render_cube, Position, CubeRenderer)
  system_register(system_render_sphere, Position, SphereRenderer)
  system_register(system_render_pyll, Position, PyllRenderer)  
}
  


init_camera :: proc () {
  camera := entity_create()
  camera = entity_add_component(camera, Position{})
  camera = entity_add_component(camera, Camera{
    up = {0, -1, 0},
    fovy = 30,
    projection = .PERSPECTIVE
  })
  camera = entity_add_component(camera, CameraMousePan{})
}

init_mouse :: proc() {
  mouse := entity_create()
  mouse = entity_add_component(mouse, Position{})
  mouse = entity_add_component(mouse, Mouse{})
}

init_player :: proc () {  
  // Create player entity
  player_size : f16 = GRID_SIZE/4
  
  player := entity_create()
  player = entity_add_component(player, PrevPosition{})
  player = entity_add_component(player, Position{{50, 50, 0}})
  player = entity_add_component(player, Physics{damp=0.9, collision_damp=0.0})
  player = entity_add_component(player, SphereRenderer{d = player_size, color = YELLOW})
  player = entity_add_component(player, Controller{
    speed = 0.5,
    sprint_mult = 4,
    k_up = rl.KeyboardKey.SPACE,
    k_down = rl.KeyboardKey.LEFT_SHIFT,
    k_left = rl.KeyboardKey.A,
    k_right = rl.KeyboardKey.D,
    k_backward = rl.KeyboardKey.W,
    k_forward = rl.KeyboardKey.S,
    k_sprint = rl.KeyboardKey.LEFT_CONTROL
  })

  player = entity_add_component(player, KeepInScreen{})
  //player = entity_add_component(player, CubeCollider{size = player_size})
  player = entity_add_component(player, CameraFollow{})
}

init_pylls :: proc () {
  pyll_size : f16 = GRID_SIZE/20
  for i in 0..<NUM_PYLLS {
    
    pyll := entity_create()
    new_pos : [3]f16 = {f16(rand.int31_max(ROOM_WIDTH))-ROOM_WIDTH/2, f16(rand.int31_max(ROOM_HEIGHT))-ROOM_HEIGHT/2, f16(rand.int31_max(ROOM_DEPTH))-ROOM_DEPTH/2}

    pyll = entity_add_component(pyll, PrevPosition{})
    pyll = entity_add_component(pyll, Position{new_pos})
    pyll = entity_add_component(pyll, Physics{damp = 0.95, collision_damp = 0.0})
    pyll = entity_add_component(pyll, SphereRenderer{d = pyll_size * (4 if i == 67 else 1), color = BLUE if i == 67 else GREEN})
    pyll = entity_add_component(pyll, Pyll{})
    pyll = entity_add_component(pyll, RandMover{speed = 0.01})
    //pyll = entity_add_component(pyll, NNMover{speed = 5})
    pyll = entity_add_component(pyll, KeepInScreen{})
    //pyll = entity_add_component(pyll, CubeCollider{size = pyll_size})
    pyll = entity_add_component(pyll, Neighbors{})
    pyll = entity_add_component(pyll, RenderNeighborPaths{})
  }
}



init :: proc () {
  init_components()
  init_systems()

  init_camera()
  init_mouse()
  init_player()
  init_pylls()  
}
