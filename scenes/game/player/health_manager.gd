extends Node

var stats: PlayerStats = preload("res://resources/player_stats.tres")

@onready var player_health_bar: ProgressBar = %PlayerHealthBar
@onready var phantom_camera_noise_emitter_2d: PhantomCameraNoiseEmitter2D = $"../CameraManager/PhantomCameraNoiseEmitter2D"
@onready var max_health: int = stats.max_health
var low_health_threshold: int = 1
var current_health: int = max_health
var normal_color: Color = Color("1cc93d") # Green
var low_color: Color = Color("dc000b")    # Red
var is_invulnerable: bool = false
var invulnerability_duration: float = 1.0 # Duration in seconds

signal player_health_is_zero

func _ready():
	current_health = max_health
	if player_health_bar:
		player_health_bar.max_value = max_health
		player_health_bar.value = current_health

func take_damage(amount: int):
	# Ignore damage while invulnerable
	if is_invulnerable:
		return

	current_health -= amount
	phantom_camera_noise_emitter_2d.emit()
	current_health = clamp(current_health, 0, max_health) 
	update_player_health_bar()
	
	if current_health <= 0:
		health_is_zero()
	else:
		start_invulnerability()

func start_invulnerability():	
	# Wait for the specified duration before making the player vulnerable again
	await get_tree().create_timer(invulnerability_duration).timeout

func update_player_health_bar():
	if player_health_bar:
		player_health_bar.value = current_health
	
	# Get the StyleBoxFlat from the fill style override
	var style_box = player_health_bar.get_theme_stylebox("fill") as StyleBoxFlat
	if style_box == null:
		return
		
	# Check if health is low
	if current_health <= low_health_threshold:
		style_box.bg_color = low_color
	else:
		style_box.bg_color = normal_color

func health_is_zero():
	emit_signal("player_health_is_zero")
