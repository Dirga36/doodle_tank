extends CharacterBody2D
## The player-controlled tank. Owns its health and movement managers.

signal player_died

@onready var health_manager: Node = $HealthManager
@onready var movement_manager: Node = $MovementManager


func _ready() -> void:
	Global.player = self


## Applies incoming damage through the health manager.
func take_damage(amount: int) -> void:
	health_manager.take_damage(amount)


func _on_health_manager_player_health_is_zero() -> void:
	await get_tree().create_timer(0.1).timeout
	queue_free()
	player_died.emit()
