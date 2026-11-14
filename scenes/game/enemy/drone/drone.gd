extends CharacterBody2D
## Flying enemy that chases the player and explodes on contact.

const SCORE_REWARD: int = 10
const DEATH_SPEED: float = 10.0

@export var speed: float = 75.0
@export var rotation_speed: float = 3.0 # Higher values make rotation faster.
@export var health: int = 1
@export var damage: int = 1

@onready var player: CharacterBody2D = Global.player
@onready var die_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var explosion_effect: GPUParticles2D = $Explosion


func _physics_process(delta: float) -> void:
	# Guard check to avoid null reference errors.
	if not is_instance_valid(player):
		return

	# Calculate direction vector and target angle towards the player.
	var direction: Vector2 = global_position.direction_to(player.global_position)
	var target_angle: float = direction.angle()

	# Smoothly rotate towards the target angle.
	global_rotation = rotate_toward(global_rotation, target_angle, rotation_speed * delta)

	# Move forward in the direction the drone is facing.
	velocity = Vector2.RIGHT.rotated(global_rotation) * speed
	move_and_slide()


## Applies damage and destroys the drone when health is depleted.
func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		_die()


func _die() -> void:
	ScoreManager.add_points(SCORE_REWARD)
	speed = DEATH_SPEED
	global_rotation = 0.0
	explosion_effect.emitting = true
	sprite_2d.hide()
	die_sound.play()
	await die_sound.finished
	queue_free()


func _on_hitbox_body_entered(body: CharacterBody2D) -> void:
	# Check if the body is the player's body.
	if body.is_in_group("player"):
		body.take_damage(damage)
		_die() # Destroy the drone on impact.
