package ecs

import rl "vendor:raylib"

CameraType :: union{rl.Camera3D}
CameraProjection :: union{rl.CameraProjection}
KeyboardKey :: union{rl.KeyboardKey}
MouseButton :: union{rl.MouseButton}
Color :: [4]u8


WHITE  :: Color{255, 255, 255, 255}
BLACK  :: Color{0, 0, 0, 255}
RED    :: Color{255, 0, 0, 255}
GREEN  :: Color{0, 255, 0, 255}
BLUE   :: Color{0, 0, 255, 255}
YELLOW :: Color{255, 255, 0, 255}

is_key_down :: proc (key: KeyboardKey) -> bool {
  switch v in key {
  case rl.KeyboardKey: return rl.IsKeyDown(v)
    case: return false
  }
}

MouseData :: struct {
  delta: [2]f32,
  mouse_wheel_move: [2]f32
}
