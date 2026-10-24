extends CharacterBody2D

#@onready var trail: GPUParticles2D = $Trail

var speed = 100
var rotation_speed = 3
var rotation_direction = 0

@export var max_health: int = 3
var current_health: int = 3
@export var player_health_bar: ProgressBar

@onready var engine_sound: AudioStreamPlayer2D = %MovingSound

func _ready():
	Global.player = self
	current_health = max_health
	# Initialize the UI
	if player_health_bar:
		player_health_bar.max_value = max_health
		player_health_bar.value = current_health

func take_damage(amount: int):
	current_health -= amount
	# Clamp prevents health from dropping below 0
	current_health = clamp(current_health, 0, max_health) 
	update_player_health_bar()
	
	if current_health <= 0:
		die()

# damage test
func _input(event):
	if event.is_action_pressed("ui_select"):
		take_damage(1)
		print("-1")

func update_player_health_bar():
	if player_health_bar:
		player_health_bar.value = current_health
		
func die():
	print("Player has died!")
	# Add your death logic here (e.g., queue_free(), play animation)

func get_input():
	rotation_direction = Input.get_axis("left", "right")
	velocity = transform.x * Input.get_axis("down", "up") * speed

func _physics_process(delta):
	get_input()
	rotation += rotation_direction * rotation_speed * delta
	move_and_slide()

	# Check if the tank is actively moving
	if velocity.length() > 5.0:
		if not engine_sound.playing:
			engine_sound.play()
	else:
		if engine_sound.playing:
			engine_sound.stop()

	#if velocity.length() > 0:
	#	trail.emitting = true
