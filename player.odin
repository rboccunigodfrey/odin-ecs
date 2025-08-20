// ======================
// IMPL::PLAYER PROCS
// ======================

package ecs

import rl "vendor:raylib"

init_player :: proc () {  
  // Create player entity
  player_size : i32 = GRID_SIZE/7
  
  player := entity_create()
  player = entity_add_component(player, PrevPosition{})
  player = entity_add_component(player, Position{{50, 50}})
  player = entity_add_component(player, Physics{damp=0.9, collision_damp=0.0})
  //xentity_add_component(player, RectRenderer{w = player_size, h = player_size, color = rl.YELLOW})
  player = entity_add_component(player, CircleRenderer{d = player_size, color = rl.YELLOW})

  player = entity_add_component(player, Controller{
    speed = 5,
    k_up = rl.KeyboardKey.W,
    k_down = rl.KeyboardKey.S,
    k_left = rl.KeyboardKey.A,
    k_right = rl.KeyboardKey.D,
    k_sprint = rl.KeyboardKey.LEFT_SHIFT
  })

  player = entity_add_component(player, KeepInScreen{})
  player = entity_add_component(player, RectCollider{w = player_size, h = player_size})
  
}

