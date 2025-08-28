// ======================
// IMPL::SYSTEMS
// ======================

package ecs

import rl "vendor:raylib"
import "core:math/rand"
import "core:math"
import "core:fmt"


// camera systems

system_camera_mouse_pan :: proc (e_id: u64) {
  cam, _ := entity_get_component(e_id, Camera)
  pos, _ := entity_get_component(e_id, Position)

  
}

system_rl_camera_update :: proc (e_id: u64) {
  cam, _ := entity_get_component(e_id, Camera)
  pos, _ := entity_get_component(e_id, Position)

  rl_cam, cam_ok := &cam.camera.(rl.Camera3D)
  assert(cam_ok, "Cannot update non-raylib camera in system_rl_camera_update")

  rl_proj, proj_ok := cam.projection.(rl.CameraProjection)
  assert(proj_ok, "Camera projection not a valid raylib projection")

  rl_cam.position = pos.pos
  rl_cam.target = cam.target
  rl_cam.up = cam.up
  rl_cam.fovy = cam.fovy
  rl_cam.projection = rl_proj  
}

// physical entity systems

system_reset_acceleration :: proc (e_id: u64) {
  phy, _ := entity_get_component(e_id, Physics)
  phy.acc = 0
}

system_store_prevpos :: proc(e_id: u64) {
  prev_pos, _ := entity_get_component(e_id, PrevPosition)
  pos, _ := entity_get_component(e_id, Position)
  prev_pos.pos = pos.pos  
}

system_camera_follow :: proc (e_id: u64) {
  pos, _ := entity_get_component(e_id, Position)
  cam_id := entity_get_by_components(Camera)[0]
  cam, _ := entity_get_component(cam_id, Camera)
  cam_pos, _ := entity_get_component(cam_id, Position)
  cam_pos.pos = pos.pos + {0, -100, -300}
  cam.target = pos.pos
}

system_move_player :: proc(e_id: u64) {
  pos, _ := entity_get_component(e_id, Position)
  ctrl, _ := entity_get_component(e_id, Controller)
  phy, ok := entity_get_component(e_id, Physics)
  //if ok {pos.x += f32(vel.x); pos.y += f32(vel.y)}
  speed := ctrl.speed * (2 if rl.IsKeyDown(ctrl.k_sprint) else 1)
  f_speed : = speed * 0.2
  
  if rl.IsKeyDown(ctrl.k_up)    { if ok {phy.acc.y = -f_speed} else { pos.y -= speed} }
  if rl.IsKeyDown(ctrl.k_down)    { if ok {phy.acc.y = f_speed} else { pos.y += speed} }
  if rl.IsKeyDown(ctrl.k_left)    { if ok {phy.acc.x = -f_speed} else { pos.x -= speed} }
  if rl.IsKeyDown(ctrl.k_right)    { if ok {phy.acc.x = f_speed} else { pos.x += speed} }
  if rl.IsKeyDown(ctrl.k_backward)    { if ok {phy.acc.z = f_speed} else { pos.z += speed} }
  if rl.IsKeyDown(ctrl.k_forward)    { if ok {phy.acc.z = -f_speed} else { pos.z -= speed} }
}

system_move_rand :: proc (e_id: u64) {
  pos, _ := entity_get_component(e_id, Position)
  rm, _ := entity_get_component(e_id, RandMover)
  phy, ok := entity_get_component(e_id, Physics)
  amt : [3]f32 = {rm.speed * f32(rand.int31_max(3)-1), rm.speed * f32(rand.int31_max(3)-1), rm.speed * f32(rand.int31_max(3)-1)}
  
  if ok do phy.vel += amt; else do pos.pos += amt
}

calculate_move_norm :: proc (pos: [3]f32, o_pos: [3]f32) -> [3]f32 {
  diff:= pos - o_pos
  
  norm_factor := max(abs(diff.x), abs(diff.y), abs(diff.z))
  amt : [3]f32 = diff / norm_factor

  return -amt
}

system_move_towards_closest_nn :: proc (e_id: u64) {
  nns, _ := entity_get_component(e_id, Neighbors)
  nn_id, has_nn := nns.closest.?

  if has_nn {
    pos, _ := entity_get_component(e_id, Position)
    nnm, _ := entity_get_component(e_id, NNMover)
    phy, ok := entity_get_component(e_id, Physics)
    
    nn_pos, _ := entity_get_component(nn_id, Position)

    amt := calculate_move_norm(pos.pos, nn_pos.pos) * nnm.speed

    if ok do phy.vel += amt; else do pos.pos += amt
  }
}

system_move_towards_nn_cluster :: proc (e_id: u64) {

  nns, _ := entity_get_component(e_id, Neighbors)
  avg : [3]f32
  nnm, _ := entity_get_component(e_id, NNMover)

  pos, _ := entity_get_component(e_id, Position)
  phy, ok := entity_get_component(e_id, Physics)
  count : f32
  for nn in nns.ids {
    nn_id, ok := nn.id.?
    if !ok do continue
    nn_pos, _ := entity_get_component(nn_id, Position)
    avg += nn_pos
    count += 1
  }
  
  if count == 0 do return
  avg /= count
  amt := calculate_move_norm(pos.pos, avg) * nnm.speed * 0.1

  if ok do phy.vel += amt; else do pos.pos += amt
}




system_move_nn_rand :: proc (e_id: u64) {
  nns, _ := entity_get_component(e_id, Neighbors)
  nn_id, has_nn := nns.closest.?

  if has_nn && nns.closest_dist > 20 {
    system_move_towards_nn_cluster(e_id)
  } else {
    system_move_rand(e_id)
  }
}

system_keep_in_screen :: proc (e_id: u64) {
  pos, _ := entity_get_component(e_id, Position)
  coll, has_coll := entity_get_component(e_id, CubeCollider)
  phy, has_phy := entity_get_component(e_id, Physics)

  offset : [3]f32 = has_coll ? coll.size/2 : 0
  
  if has_phy && (pos.x < -ROOM_WIDTH/2+offset.x || pos.x > ROOM_WIDTH - offset.x) {
    phy.vel.x *= -1
  }
  if has_phy && (pos.y < -ROOM_HEIGHT/2+offset.y || pos.y > ROOM_HEIGHT - offset.y) {
    phy.vel.y *= -1
  }
  if has_phy && (pos.z < -ROOM_DEPTH/2+offset.x || pos.z > ROOM_DEPTH - offset.z) {
    phy.vel.z *= -1
  }
  pos.x = clamp(pos.x, -ROOM_WIDTH/2  + offset.x, ROOM_WIDTH/2  - offset.x)
  pos.y = clamp(pos.y, -ROOM_HEIGHT/2 + offset.y, ROOM_HEIGHT/2 - offset.y)
  pos.z = clamp(pos.z, -ROOM_DEPTH/2  + offset.z, ROOM_DEPTH/2  - offset.z)
}

system_calculate_velocity :: proc (e_id: u64) {
  prev_pos, _ := entity_get_component(e_id, PrevPosition)
  pos, _ := entity_get_component(e_id, Position)
  phy, _ := entity_get_component(e_id, Physics)
  phy.vel += phy.acc
  phy.vel *= phy.damp
}

system_calculate_pos_from_vel :: proc (e_id: u64) {
  pos, _ := entity_get_component(e_id, Position)
  phy, _ := entity_get_component(e_id, Physics)
  pos.pos += phy.vel * (dt * 100)
}


system_spatial_hash_update_rect :: proc (e_id: u64) {
  pos, _ := entity_get_component(e_id, Position)
  coll, _ := entity_get_component(e_id, CubeCollider)
 
  key := pos.pos / entity_grid.cell_size
  
  grid_bucket := &entity_grid.buckets[key]
  if grid_bucket == nil do entity_grid.buckets[key] = make([dynamic]u64)
  append(&entity_grid.buckets[key], e_id)
}

system_detect_collisions :: proc (e_id: u64) {
  pos, _ := entity_get_component(e_id, Position)
  coll, _ := entity_get_component(e_id, CubeCollider)
  phy, has_phy := entity_get_component(e_id, Physics)
  nns, has_nns := entity_get_component(e_id, Neighbors)
  cell := pos.pos / entity_grid.cell_size
  
  for x in cell.x-1..=cell.x+1 {
    for y in cell.y-1..=cell.y+1 {
      for z in cell.z-1..=cell.y+1 {
	grid_bucket := entity_grid.buckets[{x, y, z}]
	if grid_bucket != nil do for o_id in grid_bucket {
	  
	  if o_id >= e_id do break
	  o_pos, _ := entity_get_component(o_id, Position)
	  o_coll, _ := entity_get_component(o_id, CubeCollider)
	  o_phy, o_has_phy := entity_get_component(o_id, Physics)

	  
	  if abs(pos.x - o_pos.x) < (coll.size.x + o_coll.size.x) / 2 && abs(pos.y - o_pos.y) < (coll.size.y + o_coll.size.y) / 2 && abs(pos.z - o_pos.z) < (coll.size.z + o_coll.size.z) {
	    if has_phy && o_has_phy {
	      phy_vel_curr := phy.vel
	      o_phy_vel_curr := o_phy.vel
	      phy.vel *= -1 * phy.collision_damp
	      o_phy.vel *= -1 * o_phy.collision_damp
	      //phy.vel -= o_phy_vel_curr * phy.collision_damp
	      //o_phy.vel -= phy_vel_curr * o_phy.collision_damp
	      
	    }

	    half := coll.size/2
	    o_half := o_coll.size/2

	    d := pos.pos - o_pos.pos
	    p := (half + o_half) - {abs(d.x), abs(d.y), abs(d.z)} 
	    
	    epsilon : f32 = 0.01
            if p.x > epsilon && p.y > epsilon {
              // Decide axis based on movement intent
              resolve_on_x := false
              if p.x < p.y {
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
		if d.x > 0 {
                  pos.x += p.x * move_ratio_self
                  o_pos.x -= p.x * move_ratio_other
		} else {
                  pos.x -= p.x * move_ratio_self
                  o_pos.x += p.x * move_ratio_other
		}
              } else {
		if d.y > 0 {
                  pos.y += p.y * move_ratio_self
                  o_pos.y -= p.y * move_ratio_other
		} else {
                  pos.y -= p.y * move_ratio_self
                  o_pos.y += p.y * move_ratio_other
		}
              }
            }
          }
	}
      }
    }
  }
}

system_render_cube :: proc(e_id: u64) {
  pos, _ := entity_get_component(e_id, Position)
  rend, _ := entity_get_component(e_id, CubeRenderer)

  append(&render_queue_3d, RenderCommand3D{type = .Cube, pos = pos.pos, size = rend.size, color = rend.color})
}

system_render_sphere :: proc(e_id: u64) {
  pos, _ := entity_get_component(e_id, Position)
  rend, _ := entity_get_component(e_id, SphereRenderer)

  append(&render_queue_3d, RenderCommand3D{type = .Sphere, pos = pos.pos, radius = f32(rend.d/2), color = rend.color})
  
}

system_render_pyll :: proc(e_id: u64) {
  pos, _ := entity_get_component(e_id, Position)
  rend, _ := entity_get_component(e_id, PyllRenderer)
  eye_dist := rend.d/3
  eye_size := f32(rend.d)/5
  pupil_size := f32(rend.d)/7
  append(&render_queue_3d,
	 RenderCommand3D{type = .Sphere, pos = pos.pos, radius = f32(rend.d)/2, color = rend.color},
	 RenderCommand3D{type = .Sphere, pos = pos.pos + {eye_dist, -eye_dist, eye_dist}, radius = eye_size, color = rl.WHITE},
	 RenderCommand3D{type = .Sphere, pos = pos.pos + {-eye_dist, -eye_dist, eye_dist}, radius = eye_size, color = rl.WHITE},
	 RenderCommand3D{type = .Sphere, pos = pos.pos + {eye_dist, -eye_dist, eye_dist}, radius = pupil_size, color = rl.BLACK},
	 RenderCommand3D{type = .Sphere, pos = pos.pos + {-eye_dist, -eye_dist, eye_dist}, radius = pupil_size, color = rl.BLACK})
}

system_render_nn_conns :: proc (e_id: u64) {
  pos, _ := entity_get_component(e_id, Position)
  nns, _ := entity_get_component(e_id, Neighbors)
  for i in 0..<nns.size {
    nn_id, ok := nns.ids[i].id.?
      
    if ok {
      nn_pos, _ := entity_get_component(nn_id, Position)
      append(&render_queue_3d, RenderCommand3D{type = .Line, pos = pos.pos, size = nn_pos.pos, color = {255, 255, 0, 50}})
    }
  }
  closest, has_nn := nns.closest.?
    
  if has_nn {
    
    nn_pos, _ := entity_get_component(closest, Position)
    
    append(&render_queue_3d, RenderCommand3D{type = .Line, pos = pos.pos, size = nn_pos.pos, color = {255, 255, 255, 255}})
  }
}

system_update_neighbors :: proc (e_id: u64) {
  pos, _ := entity_get_component(e_id, Position)
  nns, _ := entity_get_component(e_id, Neighbors)
  cell := pos.pos / entity_grid.cell_size
  // remove neighbors too far away, and update other's distances
  closest : Maybe(u64) = nil
  closest_dist : f32 = -1
  for i in 0..<nns.size {
    nn_id, ok := nns.ids[i].id.?
    if ok {
      nn_pos, _ := entity_get_component(nn_id, Position)
      
      dist := abs(pos.x - nn_pos.x) + abs(pos.y - nn_pos.y)
      if dist > MAX_NN_DIST {
	nns.ids[i] = Neighbor{nil, -1}
      } else {
	nns.ids[i].dist = dist
	if closest_dist == -1 || dist < closest_dist {
	  closest = nn_id
	  closest_dist = dist
	}
      }      
    }
    nns.closest = closest
    nns.closest_dist = closest_dist
  }

  // run thru entities in the 9 nearby grid cell buckets
  
  for x in cell.x-1..=cell.x+1 {
    for y in cell.y-1..=cell.y+1 {
      for z in cell.y-1..=cell.z+1 {
	grid_bucket := entity_grid.buckets[{x, y, z}]
	if grid_bucket != nil do for o_id in grid_bucket {
	  // ignore if bucket entity is current entity
	  if o_id == e_id do break

	  // ignore if bucket entity is already a nn entity 
	  exists := false
	  for i in 0..< nns.size {
	    nn_id, ok := nns.ids[i].id.?

	    if nn_id == o_id {exists = true; break}
	  }
	  if exists do break  

	  // calculate distance from current entity to bucket entity
	  o_pos, _ := entity_get_component(o_id, Position)
	  dist := abs(pos.x - o_pos.x) + abs(pos.y - o_pos.y)

	  // ignore if further than max distance
	  if dist <= MAX_NN_DIST { 
	    highest_dist : f32 = -1
	    highest_dist_i : i32 = -1

	    // insert into and increase size of neighbor array if not filled
	    if nns.size < len(nns.ids) {
	      nns.ids[nns.size] = Neighbor{o_id, dist}
	      nns.size += 1
	    }
	    else {
	      
	      for i in 0..<nns.size {
		nn_id, ok := nns.ids[i].id.?

		if !ok {
		  highest_dist_i = i
		  highest_dist = dist + 1
		  break
		}
		
		cur_dist := nns.ids[i].dist
		if highest_dist == -1 || cur_dist < highest_dist {
		  highest_dist_i = i
		  highest_dist = cur_dist
		}
	      }
	      if dist < highest_dist do nns.ids[highest_dist_i] = Neighbor{o_id, dist}
	    }
	  }
	}
      }
    }
  }
}


register_systems :: proc () {
  system_register(system_camera_mouse_pan, Camera, Position, CameraMousePan)
  
  
  system_register(system_reset_acceleration, Physics)
  system_register(system_store_prevpos, Position, PrevPosition)
  
  system_register(system_move_player, Position, Controller)
  system_register(system_move_rand, Position, RandMover)  
  //system_register(system_move_towards_closest_nn, Position, Neighbors, NNMover)
  //system_register(system_move_rand, Position, Neighbors, NNMover, RandMover)
  system_register(system_calculate_velocity, Position, PrevPosition, Physics)
  system_register(system_spatial_hash_update_rect, Position, CubeCollider)
  system_register(system_detect_collisions, Position, CubeCollider)
  system_register(system_keep_in_screen, Position, KeepInScreen)
  system_register(system_calculate_pos_from_vel, Position, Physics)
  system_register(system_update_neighbors, Position, Neighbors)
  system_register(system_camera_follow, Position, CameraFollow)
  system_register(system_rl_camera_update, Camera, Position)

  system_register(system_render_nn_conns, Position, Neighbors, RenderNeighborPaths)
  system_register(system_render_cube, Position, CubeRenderer)
  system_register(system_render_sphere, Position, SphereRenderer)
  system_register(system_render_pyll, Position, PyllRenderer)
  
}
  
