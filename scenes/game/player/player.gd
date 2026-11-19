extends CharacterBody2D
## The player-controlled tank. Owns its health and movement managers.

signal player_died

@onready var health_component: Node = $HealthComponent
@onready var movement_component: Node = $MovementComponent


func _ready() -> void:
	Global.player = self


## Applies incoming damage through the health manager.
func take_damage(amount: int) -> void:
	health_component.take_damage(amount)


func _on_health_component_player_health_is_zero() -> void:
	player_died.emit()
	queue_free()
