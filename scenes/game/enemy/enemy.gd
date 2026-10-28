extends CharacterBody2D

var speed: float = 50.0
var player = Global.player

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var health_manager: Node = $HealthManager

func _ready() -> void:
	# Wait for the first physics frame to ensure the NavigationServer is fully synced
	call_deferred("actor_setup")

func actor_setup() -> void:
	if player:
		nav_agent.target_position = player.global_position

func _physics_process(_delta: float) -> void:
	if not player:
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
	velocity = direction * speed
	
	move_and_slide()

func _on_timer_timeout() -> void:
	if player:
		nav_agent.target_position = player.global_position

func take_damage(amount: int) -> void:
	health_manager.take_damage(amount)

func _on_health_manager_died() -> void:
	queue_free()
