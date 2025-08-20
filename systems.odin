// ======================
// IMPL::SYSTEMS
// ======================

package ecs

import rl "vendor:raylib"
import "core:math/rand"
import "core:math"
import "core:fmt"

system_reset_acceleration :: proc (e_id: u64) {
  phy, _ := entity_get_component(e_id, Physics)
  phy.acc = 0
}

system_store_prevpos :: proc(e_id: u64) {
  prev_pos, _ := entity_get_component(e_id, PrevPosition)
  pos, _ := entity_get_component(e_id, Position)
  prev_pos.pos = pos.pos  
}

system_move_player :: proc(e_id: u64) {
  pos, _ := entity_get_component(e_id, Position)
  ctrl, _ := entity_get_component(e_id, Controller)
  phy, ok := entity_get_component(e_id, Physics)
  //if ok {pos.x += i32(vel.x); pos.y += i32(vel.y)}
  speed := ctrl.speed * (2 if rl.IsKeyDown(ctrl.k_sprint) else 1)
  f_speed : = f32(speed) * 0.2
  
  if rl.IsKeyDown(ctrl.k_up)    { if ok {phy.acc.y = -f_speed} else { pos.y -= speed} }
  if rl.IsKeyDown(ctrl.k_down)    { if ok {phy.acc.y = f_speed} else { pos.y += speed} }
  if rl.IsKeyDown(ctrl.k_left)    { if ok {phy.acc.x = -f_speed} else { pos.x -= speed} }
  if rl.IsKeyDown(ctrl.k_right)    { if ok {phy.acc.x = f_speed} else { pos.x += speed} }
}

system_move_rand :: proc (e_id: u64) {
  pos, _ := entity_get_component(e_id, Position)
  rm, _ := entity_get_component(e_id, RandMover)
  phy, ok := entity_get_component(e_id, Physics)
  x_amt := rm.speed * (rand.int31_max(3)-1)
  y_amt := rm.speed * (rand.int31_max(3)-1)
  
  
  if ok {
    phy.vel.x += f32(x_amt)
    phy.vel.y += f32(y_amt)
  } else {
    pos.x += x_amt
    pos.y += y_amt
  }
}
system_keep_in_screen :: proc (e_id: u64) {
  pos, _ := entity_get_component(e_id, Position)
  coll, _ := entity_get_component(e_id, RectCollider)
  phy, ok := entity_get_component(e_id, Physics)
  if ok && (pos.x < 0+coll.w/2 || pos.x > SCREEN_WIDTH - coll.w/2) {
    phy.vel.x *= -1
  }
  if ok && (pos.y < 0+coll.h/2 || pos.y > SCREEN_HEIGHT - coll.h/2) {
    phy.vel.y *= -1
  }
  pos.x = clamp(pos.x, 0+coll.w/2, SCREEN_WIDTH - coll.w/2)
  pos.y = clamp(pos.y, 0+coll.h/2, SCREEN_HEIGHT - coll.h/2)
}

system_calculate_velocity :: proc (e_id: u64) {
  prev_pos, _ := entity_get_component(e_id, PrevPosition)
  pos, _ := entity_get_component(e_id, Position)
  phy, _ := entity_get_component(e_id, Physics)
  phy.vel.x += phy.acc.x
  phy.vel.y += phy.acc.y
  //if phy.vel.x == 0 do phy.vel.x = f32(prev_pos.x - pos.x)
  //if phy.vel.y == 0 do phy.vel.y = f32(prev_pos.y - pos.y)
  
  phy.vel *= phy.damp
}

system_calculate_pos_from_vel :: proc (e_id: u64) {
  pos, _ := entity_get_component(e_id, Position)
  phy, _ := entity_get_component(e_id, Physics)
  pos.x += i32(phy.vel.x)
  pos.y += i32(phy.vel.y)
}


system_spatial_hash_update_rect :: proc (e_id: u64) {
  pos, _ := entity_get_component(e_id, Position)
  coll, _ := entity_get_component(e_id, RectCollider)
 
  cell_x := pos.x / entity_grid.cell_size
  cell_y := pos.y / entity_grid.cell_size
  
  key : [2]i32 = {cell_x, cell_y}
  grid_bucket := &entity_grid.buckets[key]
  if grid_bucket == nil do entity_grid.buckets[key] = make([dynamic]u64)
  append(&entity_grid.buckets[key], e_id)
}

system_detect_collisions :: proc (e_id: u64) {
  pos, _ := entity_get_component(e_id, Position)
  coll, _ := entity_get_component(e_id, RectCollider)
  phy, has_phy := entity_get_component(e_id, Physics)
  nn, has_nn := entity_get_component(e_id, Neighbors)
  cell_x := pos.x / entity_grid.cell_size
  cell_y := pos.y / entity_grid.cell_size
  for x in cell_x-1..=cell_x+1 {
    for y in cell_y-1..=cell_y+1 {
      grid_bucket := entity_grid.buckets[{x, y}]
      if grid_bucket != nil do for o_id in grid_bucket {
	
	if o_id >= e_id do break
	o_pos, _ := entity_get_component(o_id, Position)
	o_coll, _ := entity_get_component(o_id, RectCollider)
	o_phy, o_has_phy := entity_get_component(o_id, Physics)
	append(&render_queue, RenderCommand2D{type = .Line, pos = pos.pos, size = o_pos.pos, color = {255, 255, 0, 50}})
	if abs(pos.x - o_pos.x) < (coll.w + o_coll.w) / 2 && abs(pos.y - o_pos.y) < (coll.h + o_coll.h) / 2 {
	  
	  if has_phy && o_has_phy {
	    phy_vel_curr := phy.vel
	    o_phy_vel_curr := o_phy.vel
	    phy.vel *= -1 * phy.collision_damp
	    o_phy.vel *= -1 * o_phy.collision_damp
	    //phy.vel -= o_phy_vel_curr * phy.collision_damp
	    //o_phy.vel -= phy_vel_curr * o_phy.collision_damp
	    
	  }

	  half_w := f32(coll.w) / 2
	  half_h := f32(coll.h) / 2
	  o_half_w := f32(o_coll.w) / 2
	  o_half_h := f32(o_coll.h) / 2

	  dx := f32(pos.x - o_pos.x)
	  px := (half_w + o_half_w) - abs(dx) // overlap on X

	  dy := f32(pos.y - o_pos.y)
	  py := (half_h + o_half_h) - abs(dy) // overlap on Y

	  epsilon : f32 = 0.01
          if px > epsilon && py > epsilon {
            // Decide axis based on movement intent
            resolve_on_x := false
            if px < py {
              resolve_on_x = true
            }
            if has_phy && abs(phy.vel.x) > abs(phy.vel.y) {
              resolve_on_x = true
            } else if has_phy && abs(phy.vel.y) > abs(phy.vel.x) {
              resolve_on_x = false
            }

            // How much each object should move
            move_ratio_self : f32 = 1.0
            move_ratio_other: f32 = 0.0
            if has_phy && o_has_phy {
              move_ratio_self  = 0.5
              move_ratio_other = 0.5
            }

            if resolve_on_x {
              if dx > 0 {
                pos.x += i32(px * move_ratio_self)
                o_pos.x -= i32(px * move_ratio_other)
              } else {
                pos.x -= i32(px * move_ratio_self)
                o_pos.x += i32(px * move_ratio_other)
              }
            } else {
              if dy > 0 {
                pos.y += i32(py * move_ratio_self)
                o_pos.y -= i32(py * move_ratio_other)
              } else {
                pos.y -= i32(py * move_ratio_self)
                o_pos.y += i32(py * move_ratio_other)
              }
            }
          }
        }
      }
    }
  }
}

system_render_rect :: proc(e_id: u64) {
  pos, _ := entity_get_component(e_id, Position)
  rend, _ := entity_get_component(e_id, RectRenderer)

  rl.DrawRectangle(pos.x-rend.w/2, pos.y-rend.h/2, rend.w, rend.h, rend.color)
}

system_render_circle :: proc(e_id: u64) {
  pos, _ := entity_get_component(e_id, Position)
  rend, _ := entity_get_component(e_id, CircleRenderer)

  append(&render_queue, RenderCommand2D{type = .Circle, pos = pos.pos, radius = f32(rend.d/2), color = rend.color})
  
}

system_render_pyll :: proc(e_id: u64) {
  pos, _ := entity_get_component(e_id, Position)
  rend, _ := entity_get_component(e_id, PyllRenderer)
  eye_dist := rend.d/3
  eye_size := f32(rend.d)/5
  pupil_size := f32(rend.d)/7
  append(&render_queue,
	 RenderCommand2D{type = .Circle, pos = pos.pos, radius = f32(rend.d)/2, color = rend.color},
	 RenderCommand2D{type = .Circle, pos = pos.pos + {eye_dist, -eye_dist}, radius = eye_size, color = rl.WHITE},
	 RenderCommand2D{type = .Circle, pos = pos.pos + {-eye_dist, -eye_dist}, radius = eye_size, color = rl.WHITE},
	 RenderCommand2D{type = .Circle, pos = pos.pos + {eye_dist, -eye_dist}, radius = pupil_size, color = rl.BLACK},
	 RenderCommand2D{type = .Circle, pos = pos.pos + {-eye_dist, -eye_dist}, radius = pupil_size, color = rl.BLACK})
}


register_systems :: proc () {
  system_register(system_reset_acceleration, Physics)
  system_register(system_store_prevpos, Position, PrevPosition)
  system_register(system_move_player, Position, Controller)
  system_register(system_move_rand, Position, RandMover)  
  system_register(system_calculate_velocity, Position, PrevPosition, Physics)
  system_register(system_calculate_pos_from_vel, Position, Physics)
  system_register(system_spatial_hash_update_rect, Position, RectCollider)
  system_register(system_detect_collisions, Position, RectCollider)
  system_register(system_keep_in_screen, Position, KeepInScreen, RectCollider)
  system_register(system_render_rect, Position, RectRenderer)
  system_register(system_render_circle, Position, CircleRenderer)
  system_register(system_render_pyll, Position, PyllRenderer)
}
  
