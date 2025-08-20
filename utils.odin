package ecs

unique_array_add :: proc(arr: ^[dynamic]$T, val: T, seen: ^map[T]bool) {
  if !seen[val] {
    append(arr, val)
    seen[val] = true
  }
}
