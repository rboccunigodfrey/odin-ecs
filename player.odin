// ======================
// IMPL::PLAYER PROCS
// ======================

package ecs

import rl "vendor:raylib"
import "core:fmt"

init_player :: proc () {  
  // Create player entity
  player_size : f32 = GRID_SIZE/4
  
  player := entity_create()
  player = entity_add_component(player, PrevPosition{})
  player = entity_add_component(player, Position{{50, 50, 0}})
  player = entity_add_component(player, Physics{damp=0.95, collision_damp=0.0})
  player = entity_add_component(player, SphereRenderer{d = player_size, color = rl.YELLOW})
  player = entity_add_component(player, Controller{
    speed = 1,
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

