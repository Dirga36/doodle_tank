extends Node
## Tracks the player's health and drives the HUD bar, hurt sound and camera shake.

signal player_health_is_zero

const NORMAL_COLOR: Color = Color("1cc93d") # Green
const LOW_COLOR: Color = Color("dc000b")    # Red

@export var low_health_threshold: int = 1
@export var invulnerability_duration: float = 1.0

var stats: PlayerStats = preload("res://resources/player_stats.tres")

var max_health: int = stats.max_health
var current_health: int = stats.max_health
var is_invulnerable: bool = false

@onready var player_health_bar: ProgressBar = %PlayerHealthBar
@onready var phantom_camera_noise_emitter_2d: PhantomCameraNoiseEmitter2D = %PhantomCameraNoiseEmitter2D
@onready var hurt_sound: AudioStreamPlayer2D = %HurtSound


func _ready() -> void:
	current_health = max_health
	if player_health_bar:
		player_health_bar.max_value = max_health
		player_health_bar.value = current_health


## Applies incoming damage, ignoring it while invulnerable.
func take_damage(amount: int) -> void:
	# Ignore damage while invulnerable.
	if is_invulnerable:
		return

	current_health -= amount
	phantom_camera_noise_emitter_2d.emit()
	current_health = clamp(current_health, 0, max_health)
	_update_player_health_bar()
	hurt_sound.play()

	if current_health <= 0:
		_health_is_zero()
	else:
		_start_invulnerability()


func _start_invulnerability() -> void:
	# Wait for the specified duration before making the player vulnerable again.
	await get_tree().create_timer(invulnerability_duration).timeout


func _update_player_health_bar() -> void:
	if player_health_bar:
		player_health_bar.value = current_health

	# Get the StyleBoxFlat from the fill style override.
	var style_box: StyleBoxFlat = player_health_bar.get_theme_stylebox("fill") as StyleBoxFlat
	if style_box == null:
		return

	if current_health <= low_health_threshold:
		style_box.bg_color = LOW_COLOR
	else:
		style_box.bg_color = NORMAL_COLOR


func _health_is_zero() -> void:
	player_health_is_zero.emit()
