extends Node
## Handles mouse-wheel zooming for the player's [PhantomCamera2D].

@export var zoom_speed: float = 0.5
@export var min_zoom: float = 2.5
@export var max_zoom: float = 5.0

@onready var pcam: PhantomCamera2D = $PhantomCamera2D


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		var current_zoom: Vector2 = pcam.get_zoom()
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			current_zoom += Vector2(zoom_speed, zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			current_zoom -= Vector2(zoom_speed, zoom_speed)

		# Clamp the zoom values to keep them within limits.
		current_zoom.x = clamp(current_zoom.x, min_zoom, max_zoom)
		current_zoom.y = clamp(current_zoom.y, min_zoom, max_zoom)

		pcam.set_zoom(current_zoom)
