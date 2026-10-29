extends CharacterBody2D

var speed: float = 75.0
var rotation_speed: float = 3.0 # Higher values make rotation faster
var health: int = 1
var damage: int = 1

func _physics_process(delta):
	# Guard check to avoid null reference errors
	if not is_instance_valid(Global.player):
		return

	# Calculate direction vector and target angle towards the player
	var direction: Vector2 = global_position.direction_to(Global.player.global_position)
	var target_angle: float = direction.angle()

	# Smoothly rotate towards the target angle
	global_rotation = rotate_toward(global_rotation, target_angle, rotation_speed * delta)

	# Move forward in the direction the drone is facing
	velocity = Vector2.RIGHT.rotated(global_rotation) * speed
	move_and_slide()

func take_damage(amount):
	health -= amount
	if health <= 0:
		die()

func die():
	queue_free()

func _on_hitbox_body_entered(body: CharacterBody2D) -> void:
	# Check if the body is the player's body
	if body.is_in_group("player"):
		body.take_damage(damage)
		queue_free() # Destroy the drone on impact
