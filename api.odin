// ==================================================================
// ==================          API_START         ====================
// ==================================================================

package ecs

// ======================
// API::DATA TYPES
// ======================

Entity :: struct {
  id:   u64,
  mask: u64, // bitmask of which components are present
}

Component :: struct {
  id:      u64,         // unique ID (bit position)
  storage: rawptr       // pointer to the sparse set for this type
}

SparseSet :: struct($T: typeid) {
  data:      [dynamic]T,    // dense component data
  dense_ids: [dynamic]u64,  // dense index → entity ID
  sparse:    [dynamic]int  // sparse[entity_id] = dense index, or -1 if absent
}

System :: struct {
  mask: u64,                  // components the system requires
  update: proc(u64)      // per-entity update function
}

Archetype :: struct {
  mask:    u64,                // combination of components
  entities: SparseSet(Entity),   // entities in this archetype
  systems: [dynamic]System   // systems associated with this archetype
}



Renderable2D :: enum {
  Rect,
  Circle,
  Line
}

RenderCommand2D :: struct {
  type: Renderable2D,
  pos: [2]f16,
  size: [2]f16,
  radius: f16,
  color: Color
}

Renderable3D :: enum {
  Cube,
  Sphere,
  Line
}

RenderCommand3D :: struct {
  type: Renderable3D,
  pos: [3]f16,
  size: [3]f16,
  radius: f16,
  color: Color
}

SpatialHash :: struct ($dims: u8, $Type: typeid) {
  cell_size: f16,
  buckets: map[[dims]f16][dynamic]Type
}

// ======================
// API::GLOBALS
// ======================

archetypes := make([dynamic]Archetype, 0, 64) // stores entities and systems
component_registry := make(map[typeid]Component) // stores components

next_component_bit: u64 = 1
current_entity_id: u64 = 1

// ======================
// API::SPARSE SET PROCS
// ======================

sparse_set_init :: proc($T: typeid, cap: int) -> SparseSet(T) {
  return SparseSet(T){
    data = make([dynamic]T, 0, cap),
    dense_ids = make([dynamic]u64, 0, cap),
    sparse = make([dynamic]int, cap, cap),
  }
}

sparse_set_add :: proc(set: ^SparseSet($T), id: u64, item: T, overwrite: bool = true) {
  if id >= cast(u64)len(set.sparse) {
    old_len := len(set.sparse)
    resize(&set.sparse, id+1)
    for i := old_len; i >= len(set.sparse); i += 1 {
      set.sparse[i] = 0
    }
  }
  if set.sparse[id] == 0 {
    append(&set.data, item)
    append(&set.dense_ids, id)
    set.sparse[id] = len(set.data)
  } else if overwrite {
    set.data[set.sparse[id]-1] = item // overwrite
  }
}

sparse_set_remove :: proc (set: ^SparseSet($T), id: u64) {
  idx := set.sparse[id]
  if idx == 0 { return } // not present

  last_idx := len(set.data) - 1
  set.data[idx] = set.data[last_idx]
  set.dense_ids[idx] = set.dense_ids[last_idx]
  set.sparse[set.dense_ids[idx]] = idx

  pop(&set.data)
  pop(&set.dense_ids)
  set.sparse[id] = 0
}

// ======================
// API::COMPONENT PROCS
// ======================


component_register :: proc($T: typeid) {
  ss := new(SparseSet(T))
  ss^ = sparse_set_init(T, 10000)
  meta := Component{
        id = 1 << next_component_bit,
        storage = ss
    }
    component_registry[typeid_of(T)] = meta
    next_component_bit += 1
}

component_sparse_set_get :: proc ($T: typeid) -> (u64, ^SparseSet(T)) {
  meta := &component_registry[typeid_of(T)]
  return meta.id, cast(^SparseSet(T))meta.storage
}

registry_get_singleton_component :: proc ($T: typeid) -> (^T, bool) {
  _, set := component_sparse_set_get(T)
  if len(set.data) != 1 do return nil, false
  return &set.data[0], true
}

// ======================
// API::ENTITY PROCS
// ======================

entity_create :: proc() -> Entity {
  e := Entity{id = current_entity_id, mask = 0}
  current_entity_id += 1
  return e
}

entity_add_component :: proc(e: Entity, comp: $T) -> Entity {
  c_mask, set := component_sparse_set_get(T)
  e := Entity{e.id, e.mask | c_mask}
  sparse_set_add(set, e.id, comp)
  for i in 0..<len(archetypes) {
    arch := &archetypes[i]
    if arch.mask & e.mask == arch.mask {
      sparse_set_add(&arch.entities, e.id, e, true)
    } 
  }
  return e
}

entity_get_component :: proc(eid: u64, $T: typeid) -> (^T, bool) {
  _, set := component_sparse_set_get(T)
  idx := set.sparse[eid]
  
  if idx == 0 do return nil, false
  return &set.data[idx-1], true
}

entity_get_by_components :: proc (comps: ..typeid) -> []u64 {
  mask := mask_calculate(..comps)
  e_ss := make([dynamic]u64)
  e_ss_seen := make(map[u64]bool)
  
  for arch in archetypes {
    if arch.mask | mask == arch.mask {
      for e in arch.entities.data {
	unique_array_add(&e_ss, e.id, &e_ss_seen)
      }
    }
  }
  //delete(e_ss)
  delete(e_ss_seen)
  return e_ss[:]
}

entity_get_by_singleton_component :: proc (comp: typeid) -> (u64, bool) {
  mask := mask_calculate(comp)
  e_id : u64
  count := 0
  for arch in archetypes {
    if arch.mask | mask == arch.mask {
      if len(arch.entities.data) != 1 {
	return 0, false
      }
      if e_id == 0 || arch.entities.data[0].id != e_id do count += len(arch.entities.data)
      e_id = arch.entities.data[0].id
    }
  }
  return e_id, true
}

entity_remove_component :: proc(e: Entity, $T: typeid) -> Entity {
  c_mask, set := sparse_set_get(T)
  e := Entity{e.id, e.mask ~ c_mask}
  
  sparse_set_remove(set, e.id)
  
  for i in 0..<len(archetypes) {
    arch := &archetypes[i]
    if arch.mask & e.mask != arch.mask {
      sparse_set_remove(&arch.entities, e.id)
    }
  }
  return Entity{e.id, e.mask ~ c_hash}
}

// ======================
// API::ARCHETYPE PROCS
// ======================

// Find existing archetype by mask, or create a new one
archetype_get_or_create :: proc(mask: u64, create: bool = true) -> ^Archetype {
  for i in 0..<len(archetypes) {
    arch := &archetypes[i]
    if arch.mask == mask {
      return arch
    }
  }
  if create {
    append(&archetypes, Archetype{mask = mask, entities = sparse_set_init(Entity, 10000)})
    return &archetypes[len(archetypes)-1]
  } else {
    return nil
  }
}

// ======================
// API::BITMASK PROCS
// ======================

mask_calculate :: proc(comps: ..typeid) -> u64 {
  mask : u64 = 0
  for t in comps {
    mask |= component_registry[t].id
  }
  return mask
}

// ======================
// API::SYSTEM PROCS
// ======================

// Register a system with all archetypes it matches
system_register :: proc(f: proc(u64), comps: ..typeid) {
  mask := mask_calculate(..comps)
  s := System{
    mask = mask,
    update = f
  }
  arch := archetype_get_or_create(mask)  
  append(&arch.systems, s)      
}

