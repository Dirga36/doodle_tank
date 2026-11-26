extends Node
## Hit-point tracker that emits [signal died] when health reaches zero.

signal died

@export var max_health: float = 300.0

var current_health: float = max_health


func _ready() -> void:
	current_health = max_health


## Applies damage, clamping health between 0 and [member max_health].
func take_damage(amount: float) -> void:
	current_health -= amount
	# Clamp prevents health from dropping below 0.
	current_health = clamp(current_health, 0, max_health)
	if current_health <= 0:
		_health_is_zero()


func _health_is_zero() -> void:
	died.emit()
