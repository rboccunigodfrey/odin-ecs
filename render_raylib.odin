package ecs

import rl "vendor:raylib"

render_queue_2d := make([dynamic]RenderCommand2D, 0, 1000) 
render_queue_3d := make([dynamic]RenderCommand3D, 0, 1000) 

batch_render_2d :: proc () {
  for r_cmd in render_queue_2d {
    pos := vec_to(r_cmd.pos, f32)
    size := vec_to(r_cmd.pos, f32)
    radius := f32(r_cmd.radius)
    switch r_cmd.type {
    case .Rect:
      rl.DrawRectangleV(pos, size, rl.Color(r_cmd.color))
      break
    case .Circle:
      rl.DrawCircleV(pos, radius, rl.Color(r_cmd.color))
      break
    case .Line:
      rl.DrawLineV(pos, size, rl.Color(r_cmd.color))
    }
  }
  clear(&render_queue_2d)
}



batch_render_3d :: proc () {
  for r_cmd in render_queue_3d  {
    pos := vec_to(r_cmd.pos, f32)
    size := vec_to(r_cmd.pos, f32)
    radius := f32(r_cmd.radius)
    switch r_cmd.type {
    case .Cube:
      rl.DrawCubeV(pos, size, rl.Color(r_cmd.color))
      break
    case .Sphere:
      rl.DrawSphere(pos, radius, rl.Color(r_cmd.color))
      break
    case .Line:
      rl.DrawLine3D(pos, size, rl.Color(r_cmd.color))
    }
  }
  clear(&render_queue_3d)
}


