extends Node

@export var stats: PlayerStats
@onready var player_health_bar: ProgressBar = %PlayerHealthBar
@onready var max_health: int = stats.max_health
var current_health: int = max_health

signal player_health_is_zero

func _ready():
	current_health = max_health
	if player_health_bar:
		player_health_bar.max_value = max_health
		player_health_bar.value = current_health

func take_damage(amount: int):
	current_health -= amount
	# Clamp prevents health from dropping below 0
	current_health = clamp(current_health, 0, max_health) 
	update_player_health_bar()
	if current_health <= 0:
		health_is_zero()

func update_player_health_bar():
	if player_health_bar:
		player_health_bar.value = current_health
		
func health_is_zero():
	emit_signal("player_health_is_zero")
