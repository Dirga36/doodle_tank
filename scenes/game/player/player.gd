extends CharacterBody2D

@onready var health_manager: Node = $HealthManager
@onready var movement_manager: Node = $MovementManager

signal player_died

func _ready():
	Global.player = self

func take_damage(amount):
	health_manager.take_damage(amount)

func _on_health_manager_player_health_is_zero() -> void:
	await get_tree().create_timer(0.1).timeout
	queue_free()
	emit_signal("player_died")
