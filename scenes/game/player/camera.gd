extends Camera2D

@export var zoom_speed: float = 0.5
@export var min_zoom: float = 2.0
@export var max_zoom: float = 5.5
@export var smooth_speed: float = 10.0 # Higher values = faster, lower = smoother

# Track the intended target zoom level
@onready var target_zoom: Vector2 = zoom

func _ready() -> void:
	# Clamp initial target_zoom and zoom to the allowed range
	target_zoom.x = clamp(target_zoom.x, min_zoom, max_zoom)
	target_zoom.y = clamp(target_zoom.y, min_zoom, max_zoom)
	zoom = target_zoom

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("zoom out"): # mouse wheel up
		target_zoom += Vector2(zoom_speed, zoom_speed)
	elif event.is_action_pressed("zoom in"): # mouse wheel down
		target_zoom -= Vector2(zoom_speed, zoom_speed)
	
	# Keep target zoom within limits
	target_zoom.x = clamp(target_zoom.x, min_zoom, max_zoom)
	target_zoom.y = clamp(target_zoom.y, min_zoom, max_zoom)

func _process(delta: float) -> void:
	# Smoothly interpolate from current zoom to target zoom
	zoom = zoom.lerp(target_zoom, smooth_speed * delta)
