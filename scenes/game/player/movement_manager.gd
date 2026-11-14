extends Node
## Drives the player's tank movement (turn + drive) and its engine sound.

# TODO: Prefer having [Player] pass itself in rather than reaching up the tree.
@export var player: CharacterBody2D

@export var rotation_speed: int = 3

var stats: PlayerStats = preload("res://resources/player_stats.tres")

var speed: float = stats.speed
var rotation_direction: float = 0.0

@onready var moving_sound: AudioStreamPlayer2D = %MovingSound


func _physics_process(delta: float) -> void:
	_get_input()
	player.rotation += rotation_direction * rotation_speed * delta
	player.move_and_slide()

	# Check if the tank is actively moving.
	if player.velocity.length() > 5.0:
		if not moving_sound.playing:
			moving_sound.play()
	else:
		if moving_sound.playing:
			moving_sound.stop()


func _get_input() -> void:
	rotation_direction = Input.get_axis("left", "right")
	player.velocity = player.transform.x * Input.get_axis("down", "up") * speed
