extends Area2D

@export var damage: int = 1
@export var fuse_time: float = 2.0
@export var is_proximity_trap: bool = true  # True for proximity trigger, False for fuse timer

@onready var fuse_timer: Timer = $FuseTimer
@onready var explosion_area: Area2D = $BlastArea
@onready var sprite: Sprite2D = $Sprite2D

var is_armed: bool = false

func _ready() -> void:
	# Small arming delay so the player doesn't immediately detonate it when dropping
	await get_tree().create_timer(0.3).timeout
	is_armed = true
	
	if not is_proximity_trap:
		fuse_timer.start(fuse_time)
		fuse_timer.timeout.connect(_on_fuse_timeout)
	else:
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if is_armed and body.is_in_group("enemy"):
		explode()

func _on_fuse_timeout() -> void:
	explode()

func explode() -> void:
	# Prevent double-triggering
	set_deferred("monitoring", false)
	
	# Find all targets in the blast radius
	var targets = explosion_area.get_overlapping_bodies()
	for target in targets:
		if target.has_method("take_damage"):
			target.take_damage(damage)
			
	# Play explosion visual/audio effect here if available
	
	# Destroy the bomb
	queue_free()
