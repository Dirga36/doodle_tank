extends Area2D

var speed: float = 75
var max_health: int = 1
var current_health: int = 1

func take_damage(amount):
	current_health -= amount
	if current_health <= 0:
		die()

func die():
	queue_free()
