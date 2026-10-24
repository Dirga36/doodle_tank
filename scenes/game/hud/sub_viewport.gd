extends SubViewport

# @onready var player = preload("res://scenes/game/player/Player.tscn")
@onready var minimap_camera: Camera2D = $Camera2D

func _ready() -> void:
	world_2d = get_tree().root.world_2d

func _physics_process(_delta: float) -> void:
	if Global.player:
		# Force the minimap camera to track the player's position
		minimap_camera.global_position = Global.player.global_position
