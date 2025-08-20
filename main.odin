// ==================================================================
// ==================          IMPL_START         ===================
// ==================================================================

package ecs
import rl "vendor:raylib"
import "core:fmt"
import "core:math/rand"
import "core:thread"

// ======================
// IMPL::CONSTANTS
// ======================

GRID_WIDTH    :: 50
GRID_HEIGHT   :: 30
GRID_SIZE     :: 50

NUM_NN        :: 10

SCREEN_WIDTH  :: GRID_WIDTH  * GRID_SIZE
SCREEN_HEIGHT :: GRID_HEIGHT * GRID_SIZE

// data types

SpatialHash2D :: struct ($Type: typeid) {
  cell_size: i32,
  buckets: map[[2]i32][dynamic]Type
}

Renderable2D :: enum {
  Rect,
  Ellipse,
  Circle,
  Line
}

RenderCommand2D :: struct {
  type: Renderable2D,
  pos: [2]i32,
  size: [2]i32,
  radius: f32,
  color: rl.Color
}

batch_render :: proc () {
  for r_cmd in render_queue {
    switch r_cmd.type {
    case .Rect:
      rl.DrawRectangle(r_cmd.pos.x, r_cmd.pos.y, r_cmd.size.x, r_cmd.size.y, r_cmd.color)
      break
    case .Circle:
      rl.DrawCircle(r_cmd.pos.x, r_cmd.pos.y, r_cmd.radius, r_cmd.color)
      break
    case .Ellipse:
      break
    case .Line:
      rl.DrawLine(r_cmd.pos.x, r_cmd.pos.y, r_cmd.size.x, r_cmd.size.y, r_cmd.color)
    }
  }
}


// globals

entity_grid := SpatialHash2D(u64){cell_size = GRID_SIZE}
render_queue := make([dynamic]RenderCommand2D, 0, 10000) 

thread_pool := thread.Pool{}
// ======================
// IMPL::INITS
// ======================


init :: proc () {
  register_components()
  register_systems()
  
  init_player()
  init_pylls()

  //thread.pool_init(&thread_pool, context.allocator, 8)
  
}

// ======================
// IMPL::MAIN
// ======================

main :: proc() {
  
  init()
    
  rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "ECS")
  defer rl.CloseWindow()

  rl.SetTargetFPS(60)
  
  // main game loop
  for ; !rl.WindowShouldClose() ; {
    // Update
    for key in entity_grid.buckets {
      clear(&entity_grid.buckets[key])
    }
    
    for arch in archetypes {
      for system in arch.systems {
	for i in 0..<len(arch.entities.data) {
	  system.update(arch.entities.data[i].id)
	}
      }
    }

    // render
    rl.BeginDrawing()
    rl.ClearBackground(rl.BLACK)
    batch_render()
    clear(&render_queue)
    
    rl.DrawFPS(10, 10)
    
    rl.EndDrawing()
  }
}
