class_name PlayerStats
extends Resource
## Tunable stats for the player's tank, shared as a [Resource].

@export var max_health: float = 1000.0
@export var speed: float = 100.0
@export var damage: float = 100.0

@export var max_health_level: int
@export var speed_level: int
@export var damage_level: int
