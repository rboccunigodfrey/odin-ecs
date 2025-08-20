// ======================
// IMPL::PYLL PROCS
// ======================

package ecs

import rl "vendor:raylib"
import "core:math/rand"


init_pylls :: proc () {
  pyll_size : i32 = GRID_SIZE/20
  for i in 0..<1000 {
    
    pyll := entity_create()
    new_pos : [2]i32 = {rand.int31_max(SCREEN_WIDTH), rand.int31_max(SCREEN_HEIGHT)}

    pyll = entity_add_component(pyll, PrevPosition{})
    pyll = entity_add_component(pyll, Position{new_pos})
    pyll = entity_add_component(pyll, Physics{damp = 0.95, collision_damp = 0.9})
    pyll = entity_add_component(pyll, CircleRenderer{d = pyll_size, color = rl.GREEN})
    pyll = entity_add_component(pyll, Pyll{})
    pyll = entity_add_component(pyll, RandMover{speed = 1})
    pyll = entity_add_component(pyll, KeepInScreen{})
    pyll = entity_add_component(pyll, RectCollider{w = pyll_size, h = pyll_size,})
  }
}
