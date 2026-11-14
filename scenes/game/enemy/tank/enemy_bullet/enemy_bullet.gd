extends Area2D
## Enemy projectile that damages the player and leaves a fading trail.

@export var speed: float = 500.0
@export var damage: int = 1
@export var max_points: int = 10

@onready var trail: Line2D = $Line2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var impact_effect: GPUParticles2D = $Marker2D/BulletImpact


func _ready() -> void:
	# Clear any default trail points set in the editor.
	trail.clear_points()


func _physics_process(delta: float) -> void:
	position += transform.x * speed * delta
	# Add the projectile's current global position to the trail.
	trail.add_point(global_position)

	# Remove the oldest point if we exceed the maximum length.
	if trail.get_point_count() > max_points:
		trail.remove_point(0)


func _exit_tree() -> void:
	# Let the trail orphan itself instead of vanishing instantly.
	if is_instance_valid(trail):
		trail.top_level = true


func _on_body_entered(body: Node2D) -> void:
	# Check if the body is the player's body.
	if body.is_in_group("player"):
		body.take_damage(damage)
		speed = 0.0
		sprite_2d.hide()
		impact_effect.emitting = true
		await impact_effect.finished
		queue_free() # Destroy the bullet on impact.


func _on_lifespan_timeout() -> void:
	queue_free()
