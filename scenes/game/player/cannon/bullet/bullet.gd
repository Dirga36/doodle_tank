extends Area2D

@export var stats: PlayerStats
@export var max_points: int = 10
@onready var trail: Line2D = $Line2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var impact_effect: GPUParticles2D = $Marker2D/BulletImpact

var speed: float = 500
@onready var damage: int = stats.damage * 1

func _physics_process(delta: float) -> void:
	position += transform.x * speed * delta
	# Add the projectile's current global position to the trail
	trail.add_point(global_position)
	
	# Remove the oldest point if we exceed the maximum length
	if trail.get_point_count() > max_points:
		trail.remove_point(0)	

func _ready():
	# Clear any default trail points set in the editor
	trail.clear_points()

func _exit_tree() -> void:
	# Optional: If the projectile is freed/destroyed, you can let the trail 
	# orphan itself or fade out instead of vanishing instantly.
	if is_instance_valid(trail):
		trail.top_level = true


func _on_body_entered(body):
	# Check if the body is the enemy's body
	if body.is_in_group("enemy"):
		body.take_damage(damage)
		speed = 0
		sprite_2d.hide()
		impact_effect.emitting = true
		await impact_effect.finished
		queue_free() # Destroy the bullet on impact

func _on_lifespan_timeout() -> void:
	queue_free()
