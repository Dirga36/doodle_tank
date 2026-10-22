extends CharacterBody2D

#@onready var trail: GPUParticles2D = $Trail

var speed = 250
var rotation_speed = 3
var rotation_direction = 0

func get_input():
	rotation_direction = Input.get_axis("left", "right")
	velocity = transform.x * Input.get_axis("down", "up") * speed

func _physics_process(delta):
	get_input()
	rotation += rotation_direction * rotation_speed * delta
	move_and_slide()
	
	#if velocity.length() > 0:
	#	trail.emitting = true
