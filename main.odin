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

NUM_PYLLS	:: 100
NUM_NN		:: 4
MAX_NN_DIST	:: 10

ROOM_WIDTH	:: ROOM_WIDTH_G  * GRID_SIZE
ROOM_HEIGHT	:: ROOM_HEIGHT_G * GRID_SIZE
ROOM_DEPTH	:: ROOM_DEPTH_G  * GRID_SIZE

SCREEN_WIDTH	:: 2000
SCREEN_HEIGHT	:: 1200

// data types

SpatialHash :: struct ($dims: u8, $Type: typeid) {
  cell_size: f32,
  buckets: map[[dims]f32][dynamic]Type
}


// globals

entity_grid := SpatialHash(3, u64){cell_size = GRID_SIZE}
render_queue_2d := make([dynamic]RenderCommand2D, 0, 1000) 
render_queue_3d := make([dynamic]RenderCommand3D, 0, 1000) 

dt : f32
// ======================
// IMPL::INITS
// ======================


init :: proc () {
  register_components()
  register_systems()

  init_camera()
  /*
  floor := entity_create()
  floor = entity_add_component(floor, Position{{0, ROOM_HEIGHT/2, 0}})
  floor = entity_add_component(floor, CubeRenderer{size = {ROOM_WIDTH, 10, ROOM_DEPTH}, color = {0, 200, 0, 255}})

  back_wall := entity_create()
  back_wall = entity_add_component(back_wall, Position{{0, 0, ROOM_DEPTH/2}})
  back_wall = entity_add_component(back_wall, CubeRenderer{size = {ROOM_WIDTH, ROOM_HEIGHT, 10}, color = {0, 50, 0, 255}})

  left_wall := entity_create()
  left_wall = entity_add_component(left_wall, Position{{-ROOM_WIDTH/2, 0, 0}})
  left_wall = entity_add_component(left_wall, CubeRenderer{size = {-10, ROOM_HEIGHT, ROOM_DEPTH}, color = {0, 100, 0, 255}})
  
  right_wall := entity_create()
  right_wall = entity_add_component(right_wall, Position{{ROOM_WIDTH/2, 0, 0}})
  right_wall = entity_add_component(right_wall, CubeRenderer{size = {10, ROOM_HEIGHT, ROOM_DEPTH}, color = {0, 150, 0, 255}})
  */
  init_player()
  init_pylls()  
}

// ======================
// IMPL::MAIN
// ======================

main :: proc() {
  
  init()

  camera, camera_exists := entity_get_component(entity_get_by_components(Camera)[0], Camera)
  assert(camera_exists, "Camera not initialized!")
  camera.camera = rl.Camera3D{}
  rl_camera := &camera.camera.(rl.Camera3D)

  rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "ECS")
  defer rl.CloseWindow()

  rl.SetTargetFPS(144)
  
  //fmt.println(rl.IsShaderValid(shader))
  //fmt.println(rl.IsShaderReady(shader))
  
  // main game loop
  for ; !rl.WindowShouldClose() ; {
    dt = rl.GetFrameTime()
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
    fmt.println(rl_camera)
//    batch_render_2d()

    batch_render_3d()
    
    rl.EndMode3D()


    rl.DrawFPS(10, 10)
    rl.EndDrawing()
  }
}
