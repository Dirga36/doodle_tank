extends CharacterBody2D

var speed: float = 75.0
@onready var Player = Global.player

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var health_manager: Node = $HealthManager
@onready var die_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var tank_cannon: Area2D = $TankCannon
@onready var explosion_effect: GPUParticles2D = $Explosion

func _ready() -> void:
	# Wait for the first physics frame to ensure the NavigationServer is fully synced
	call_deferred("actor_setup")

func actor_setup() -> void:
	if Player:
		nav_agent.target_position = Player.global_position

func _physics_process(delta):
	if not Player:
		return
		
	# Update the destination to the player's current position
	# nav_agent.target_position = player.global_position

	# Stop moving if the enemy is close enough to the player
	if nav_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Get the current position and the next waypoint on the path
	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = nav_agent.get_next_path_position()

	# Calculate direction and apply velocity
	var direction: Vector2 = current_agent_position.direction_to(next_path_position)
	var target_angle: float = direction.angle()

	# Smoothly rotate towards the target angle
	global_rotation = rotate_toward(global_rotation, target_angle, 1 * delta)

	# Move forward in the direction the drone is facing
	velocity = Vector2.RIGHT.rotated(global_rotation) * speed
	move_and_slide()

func _on_timer_timeout() -> void:
	if Player:
		nav_agent.target_position = Player.global_position

func take_damage(amount: int) -> void:
	health_manager.take_damage(amount)

func _on_health_manager_died() -> void:
	ScoreManager.add_points(15)
	speed = 10
	sprite_2d.hide()
	tank_cannon.hide()
	die_sound.play()
	explosion_effect.emitting = true
	await die_sound.finished
	queue_free()
