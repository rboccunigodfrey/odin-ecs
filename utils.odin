package ecs

import "core:math"

unique_array_add :: proc(arr: ^[dynamic]$T, val: T, seen: ^map[T]bool) {
  if !seen[val] {
    append(arr, val)
    seen[val] = true
  }
}

vec_to :: proc (v: [$N]$T1, $T2: typeid) -> (v_out: [N]T2) {
  for i in 0..<N {
    v_out[i] = T2(v[i])
  }
  return
}
