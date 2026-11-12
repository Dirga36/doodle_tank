extends CanvasLayer

# Preload your custom cursor image (recommended 32x32 or 64x64 PNG)
const SCENE_CURSOR = preload("res://scenes/game/hud/cursortarget.png")

func _process(_delta) -> void:
	# Apply the custom cursor when this scene loads
	# Vector2(0, 0) sets the click hotspot to the top-left corner
	Input.set_custom_mouse_cursor(SCENE_CURSOR, Input.CURSOR_ARROW, Vector2(16, 16))

func _exit_tree() -> void:
	# Reset back to the default system/project cursor when leaving this scene
	Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)
