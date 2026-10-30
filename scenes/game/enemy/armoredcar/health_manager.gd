extends Node

var max_health: int = 5
var current_health: int = 5

signal died

func _ready():
	current_health = max_health

func take_damage(amount: int):
	current_health -= amount
	# Clamp prevents health from dropping below 0
	current_health = clamp(current_health, 0, max_health) 
	if current_health <= 0:
		health_is_zero()

func health_is_zero():
	died.emit()

func _input(event):
	if event.is_action_pressed("ui_select"):
		take_damage(1)
		print("-1")
