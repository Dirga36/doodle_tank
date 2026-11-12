extends Node

var stats: PlayerStats = preload("res://resources/player_stats.tres")

@onready var player_health_bar: ProgressBar = %PlayerHealthBar
@onready var max_health: int = stats.max_health
var current_health: int = max_health
var is_invulnerable: bool = false
var invulnerability_duration: float = 1.0 # Duration in seconds

signal player_health_is_zero

func _ready():
	current_health = max_health
	if player_health_bar:
		player_health_bar.max_value = max_health
		player_health_bar.value = current_health

func take_damage(amount: int):
	# Ignore damage while invulnerable
	if is_invulnerable:
		return

	current_health -= amount
	current_health = clamp(current_health, 0, max_health) 
	update_player_health_bar()
	
	if current_health <= 0:
		health_is_zero()
	else:
		start_invulnerability()

func start_invulnerability():	
	# Wait for the specified duration before making the player vulnerable again
	await get_tree().create_timer(invulnerability_duration).timeout

func update_player_health_bar():
	if player_health_bar:
		player_health_bar.value = current_health
		
func health_is_zero():
	emit_signal("player_health_is_zero")
