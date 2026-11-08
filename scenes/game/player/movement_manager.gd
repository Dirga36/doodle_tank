extends Node

@onready var player: CharacterBody2D = $".."
@onready var moving_sound: AudioStreamPlayer2D = %MovingSound

@export var stats: PlayerStats

@onready var speed: float = stats.speed
var rotation_speed: int = 3
var rotation_direction: float = 0.0

func get_input():
	rotation_direction = Input.get_axis("left", "right")
	player.velocity = player.transform.x * Input.get_axis("down", "up") * speed

func _physics_process(delta):
	get_input()
	player.rotation += rotation_direction * rotation_speed * delta
	player.move_and_slide()

	# Check if the tank is actively moving
	if player.velocity.length() > 5.0:
		if not moving_sound.playing:
			moving_sound.play()
	else:
		if moving_sound.playing:
			moving_sound.stop()
