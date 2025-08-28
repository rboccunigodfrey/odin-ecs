// ======================
// IMPL::PYLL PROCS
// ======================

package ecs

import rl "vendor:raylib"
import "core:math/rand"


init_pylls :: proc () {
  pyll_size : f32 = GRID_SIZE/20
  for i in 0..<NUM_PYLLS {
    
    pyll := entity_create()
    new_pos : [3]f32 = {f32(rand.int31_max(ROOM_WIDTH))-ROOM_WIDTH/2, f32(rand.int31_max(ROOM_HEIGHT))-ROOM_HEIGHT/2, f32(rand.int31_max(ROOM_DEPTH))-ROOM_DEPTH/2}

    pyll = entity_add_component(pyll, PrevPosition{})
    pyll = entity_add_component(pyll, Position{new_pos})
    pyll = entity_add_component(pyll, Physics{damp = 0.95, collision_damp = 0.9})
    pyll = entity_add_component(pyll, SphereRenderer{d = pyll_size * (4 if i == 67 else 1), color = rl.BLUE if i == 67 else rl.GREEN})
    pyll = entity_add_component(pyll, Pyll{})
    pyll = entity_add_component(pyll, RandMover{speed = 1})
    //pyll = entity_add_component(pyll, NNMover{speed = 5})
    pyll = entity_add_component(pyll, KeepInScreen{})
    //pyll = entity_add_component(pyll, CubeCollider{size = pyll_size})
    //pyll = entity_add_component(pyll, Neighbors{})
    //pyll = entity_add_component(pyll, RenderNeighborPaths{})
  }
}
