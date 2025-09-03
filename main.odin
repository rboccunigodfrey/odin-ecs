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

ROOM_WIDTH_G    :: 20
ROOM_HEIGHT_G   :: 10
ROOM_DEPTH_G    :: 10

GRID_SIZE	:: 50

NUM_PYLLS	:: 500
NUM_NN		:: 4
MAX_NN_DIST	:: 10

ROOM_WIDTH	:: ROOM_WIDTH_G  * GRID_SIZE
ROOM_HEIGHT	:: ROOM_HEIGHT_G * GRID_SIZE
ROOM_DEPTH	:: ROOM_DEPTH_G  * GRID_SIZE

SCREEN_WIDTH	:: 2000
SCREEN_HEIGHT	:: 1200
FPS             :: 60
// globals

entity_grid := SpatialHash(3, u64){cell_size = GRID_SIZE}

dt : f16

// ======================
// IMPL::MAIN
// ======================

main :: proc() {
  
  init()

  camera, camera_exists  := registry_get_singleton_component(Camera)
  assert(camera_exists, "Camera not initialized!")
  camera.camera = rl.Camera3D{}
  rl_camera := &camera.camera.(rl.Camera3D)  
  rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "ECS")
  defer rl.CloseWindow()

  rl.HideCursor()
  
  rl.SetTargetFPS(FPS)
  
  
  // main game loop
  for ; !rl.WindowShouldClose() ; {
    dt = f16(rl.GetFrameTime())
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

    rl.BeginMode3D(rl_camera^)
    
    batch_render_3d()
    
    rl.EndMode3D()

    rl.DrawFPS(10, 10)
    rl.EndDrawing()
  }
}
