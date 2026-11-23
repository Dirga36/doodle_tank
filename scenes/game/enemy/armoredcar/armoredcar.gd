extends CharacterBody2D
## Ground enemy that moves directly toward the player to block player's path.

const BOLTS_REWARD: int = 10
const DEATH_SPEED: float = 10.0

@export var speed: float = 120.0
@export var turn_speed: float = 1.0
@export var stop_distance: float = 1.0

@onready var player: CharacterBody2D = Global.player
@onready var health_component: Node = $HealthComponent
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var exploding_effect: GPUParticles2D = %ExplodingEffect
@onready var exploding_sound: AudioStreamPlayer2D = %ExplodingSound


func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return

	# Stop moving if the enemy is close enough to the player.
	if global_position.distance_to(player.global_position) <= stop_distance:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Calculate direction directly to the player.
	var direction: Vector2 = global_position.direction_to(player.global_position)
	var target_angle: float = direction.angle()

	# Smoothly rotate towards the target angle.
	global_rotation = rotate_toward(global_rotation, target_angle, turn_speed * delta)

	# Move forward in the direction the tank is facing.
	velocity = Vector2.RIGHT.rotated(global_rotation) * speed
	move_and_slide()


## Applies incoming damage through the health Component.
func take_damage(amount: int) -> void:
	health_component.take_damage(amount)


func _on_health_component_died() -> void:
	BoltsManager.add_points(BOLTS_REWARD)
	speed = DEATH_SPEED
	sprite_2d.hide()
	exploding_sound.play()
	exploding_effect.emitting = true
	await exploding_sound.finished
	queue_free()
