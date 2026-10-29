extends CharacterBody2D

@onready var trail: GPUParticles2D = %Trail

var speed = 100
var rotation_speed = 3
var rotation_direction = 0

@onready var engine_sound: AudioStreamPlayer2D = %MovingSound
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
		if not engine_sound.playing:
			engine_sound.play()
	else:
		if engine_sound.playing:
			engine_sound.stop()

	if velocity.length() > 0:
		trail.emitting = true

func take_damage(amount):
	health_manager.take_damage(amount)
	
func _on_health_manager_player_health_is_zero() -> void:
	emit_signal("player_died")
	queue_free()
