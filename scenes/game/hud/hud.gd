extends CanvasLayer
## Applies the custom in-game cursor while the HUD is active.

# Recommended 32x32 or 64x64 PNG.
const SCENE_CURSOR: Texture2D = preload("res://scenes/game/hud/cursortarget.png")
# Sets the click hotspot to the centre of the cursor image.
const CURSOR_HOTSPOT: Vector2 = Vector2(16, 16)


func _ready() -> void:
	Input.set_custom_mouse_cursor(SCENE_CURSOR, Input.CURSOR_ARROW, CURSOR_HOTSPOT)


func _exit_tree() -> void:
	# Reset back to the default system/project cursor when leaving this scene.
	Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)
