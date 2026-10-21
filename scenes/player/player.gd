extends CharacterBody2D

@onready var gpu_particles_2d: GPUParticles2D = get_tree().root.find_child("Trail", true, false)

@export var speed = 250
@export var rotation_speed = 3
var rotation_direction = 0

func get_input():
	rotation_direction = Input.get_axis("left", "right")
	velocity = transform.x * Input.get_axis("down", "up") * speed

func _physics_process(delta):
	get_input()
	rotation += rotation_direction * rotation_speed * delta
	move_and_slide()
	
	if velocity.length() > 0:
		gpu_particles_2d.emitting = true
