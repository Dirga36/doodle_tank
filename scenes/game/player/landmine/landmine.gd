extends Area2D

var stats: PlayerStats = preload("res://resources/player_stats.tres")
@onready var fuse_timer: Timer = $FuseTimer
@onready var explosion_area: Area2D = $BlastArea
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var exploding_sound: AudioStreamPlayer2D = $ExplodingSound
@onready var exploding_particles: GPUParticles2D = $ExplodingParticles

@onready var damage: int = stats.damage * 3
var fuse_time: float = 2.0
var is_proximity_trap: bool = true  # True for proximity trigger, False for fuse timer
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
	# Note: Landmines affects only ground enemies
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
		
	# Destroy the bomb
	animated_sprite_2d.hide()
	exploding_particles.emitting = true
	exploding_sound.play()
	await exploding_sound.finished
	queue_free()


func _on_lifespan_timeout() -> void:
	explode()
