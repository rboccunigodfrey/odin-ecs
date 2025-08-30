package ecs

import rl "vendor:raylib"


Renderable2D :: enum {
  Rect,
  Circle,
  Line
}

RenderCommand2D :: struct {
  type: Renderable2D,
  pos: [2]f32,
  size: [2]f32,
  radius: f32,
  color: Color
}

Renderable3D :: enum {
  Cube,
  Sphere,
  Line
}

RenderCommand3D :: struct {
  type: Renderable3D,
  pos: [3]f32,
  size: [3]f32,
  radius: f32,
  color: Color
}


batch_render_2d :: proc () {
  for r_cmd in render_queue_2d {
    switch r_cmd.type {
    case .Rect:
      rl.DrawRectangleV(r_cmd.pos, r_cmd.size, rl.Color(r_cmd.color))
      break
    case .Circle:
      rl.DrawCircleV(r_cmd.pos, r_cmd.radius, rl.Color(r_cmd.color))
      break
    case .Line:
      rl.DrawLineV(r_cmd.pos, r_cmd.size, rl.Color(r_cmd.color))
    }
  }
  clear(&render_queue_2d)
}



batch_render_3d :: proc () {
  for r_cmd in render_queue_3d {
    switch r_cmd.type {
    case .Cube:
      rl.DrawCubeV(r_cmd.pos, r_cmd.size, rl.Color(r_cmd.color))
      break
    case .Sphere:
      rl.DrawSphere(r_cmd.pos, r_cmd.radius, rl.Color(r_cmd.color))
      break
    case .Line:
      rl.DrawLine3D(r_cmd.pos, r_cmd.size, rl.Color(r_cmd.color))
    }
  }
  clear(&render_queue_3d)
}


