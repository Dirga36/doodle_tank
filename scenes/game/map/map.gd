extends Node2D

# Replace with your actual TileSet Source ID and Atlas Coords
const SOURCE_ID = 0
const a = Vector2i(0, 0)
const b = Vector2i(1, 0)
const c = Vector2i(0, 1)

@export var map_width: int = 100
@export var map_height: int = 100
@export var noise_frequency: float = 0.05
@export var border_thickness: float = 64.0

var border_body: StaticBody2D

@onready var tile_map_layer: TileMapLayer = $TileMapLayer


func _ready() -> void:
	generate_map()


func generate_map(custom_seed: int = -1) -> void:
	tile_map_layer.clear()

	# FastNoiseLite is built into Godot 4 and requires no external addons
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = noise_frequency
	noise.seed = randi() if custom_seed == -1 else custom_seed

	for x in range(map_width):
		for y in range(map_height):
			# Returns a float roughly between -1.0 and 1.0
			var noise_val = noise.get_noise_2d(x, y)
			var tile_coords = get_tile_from_noise(noise_val)

			tile_map_layer.set_cell(Vector2i(x, y), SOURCE_ID, tile_coords)

	_create_map_borders()


func get_tile_from_noise(value: float) -> Vector2i:
	if value < -0.2:
		return a
	elif value < 0.0:
		return b
	else:
		return c


func _create_map_borders() -> void:
	# Remove old borders if regenerating the map
	if is_instance_valid(border_body):
		border_body.queue_free()

	border_body = StaticBody2D.new()
	border_body.name = "MapBorders"
	add_child(border_body)

	# Automatically grab your tile size from the TileSet
	var tile_size := Vector2(16, 16)
	if tile_map_layer.tile_set:
		tile_size = Vector2(tile_map_layer.tile_set.tile_size)

	var total_size := Vector2(map_width, map_height) * tile_size
	var half_thick := border_thickness / 2.0

	# Top, Bottom, Left, Right wall definitions [position, size]
	var walls := [
		[
			Vector2(total_size.x / 2.0, -half_thick),
			Vector2(total_size.x + border_thickness * 2.0, border_thickness),
		],
		[
			Vector2(total_size.x / 2.0, total_size.y + half_thick),
			Vector2(total_size.x + border_thickness * 2.0, border_thickness),
		],
		[Vector2(-half_thick, total_size.y / 2.0), Vector2(border_thickness, total_size.y)],
		[
			Vector2(total_size.x + half_thick, total_size.y / 2.0),
			Vector2(border_thickness, total_size.y),
		],
	]

	for wall in walls:
		var shape := RectangleShape2D.new()
		shape.size = wall[1]

		var collider := CollisionShape2D.new()
		collider.shape = shape
		collider.position = wall[0]
		border_body.add_child(collider)
