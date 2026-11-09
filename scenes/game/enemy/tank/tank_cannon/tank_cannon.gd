extends Area2D

const Bullet = preload("uid://bwbfx4yqypae0")
@onready var Player = Global.player
var fire_cooldown: float = 3
var _cooldown_timer: float = 0.0
var aimed: bool = false

@onready var marker_2d: Marker2D = $Marker2D
@onready var firing_effect: GPUParticles2D = $Marker2D/CannonFiring
@onready var cannon_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D

var rotation_speed: float = 5.0 # Lower values = slower rotation

func _physics_process(delta: float) -> void:
	var target_angle = global_position.direction_to(Player.global_position).angle()
	
	# Interpolate global_rotation instead of local rotation
	global_rotation = lerp_angle(global_rotation, target_angle, rotation_speed * delta)
	
	_normalize_rotation()
	_update_cooldown(delta)
	if _can_fire():
		_shoot()


func _normalize_rotation() -> void:
	global_rotation_degrees = wrap(global_rotation_degrees, 0.0, 360.0)


func _update_cooldown(delta: float) -> void:
	if _cooldown_timer > 0.0:
		_cooldown_timer = maxf(_cooldown_timer - delta, 0.0)

func _on_target_manager_target_lost() -> void:
	aimed = false

func _on_target_manager_target_in_range() -> void:
	aimed = true

func _can_fire() -> bool:
	return aimed == true and _cooldown_timer == 0.0


func _shoot() -> void:
	var bullet := Bullet.instantiate() as Area2D
	if bullet == null:
		return
	bullet.global_transform = marker_2d.global_transform
	var spawn_parent := get_tree().root
	spawn_parent.add_child(bullet)
	
	cannon_sound.play()
	firing_effect.restart()
	firing_effect.emitting = true
	_cooldown_timer = fire_cooldown
