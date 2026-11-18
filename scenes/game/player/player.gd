extends CharacterBody2D
## The player-controlled tank. Owns its health and movement managers.

signal player_died

@onready var health_component: Node = $HealthManager
@onready var movement_component: Node = $MovementManager


func _ready() -> void:
	Global.player = self


## Applies incoming damage through the health manager.
func take_damage(amount: int) -> void:
	health_component.take_damage(amount)


func _on_health_component_player_health_is_zero() -> void:
	await get_tree().create_timer(0.1).timeout
	queue_free()
	player_died.emit()
