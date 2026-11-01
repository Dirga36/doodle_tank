extends CharacterBody2D

var speed = 100
var rotation_speed = 3
var rotation_direction = 0

@onready var moving_sound: AudioStreamPlayer2D = %MovingSound
@onready var health_manager: Node = $HealthManager

signal player_died

func _ready():
	Global.player = self

func get_input():
	rotation_direction = Input.get_axis("left", "right")
	velocity = transform.x * Input.get_axis("down", "up") * speed

func _physics_process(delta):
	get_input()
	rotation += rotation_direction * rotation_speed * delta
	move_and_slide()

	# Check if the tank is actively moving
	if velocity.length() > 5.0:
		if not moving_sound.playing:
			moving_sound.play()
	else:
		if moving_sound.playing:
			moving_sound.stop()

func take_damage(amount):
	health_manager.take_damage(amount)
	
func _on_health_manager_player_health_is_zero() -> void:
	emit_signal("player_died")
	queue_free()
