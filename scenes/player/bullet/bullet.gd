extends Area2D

var speed: float = 100
var damage: int = 1

func _physics_process(delta: float) -> void:
	position += transform.x * speed * delta

func _on_body_entered(body):
	# Check if the body is the enemy's body
	if body.is_in_group("enemy"):
		body.take_damage(damage)
		queue_free() # Destroy the bullet on impact

func _on_lifespan_timeout() -> void:
	queue_free() # Deletes the bullet when time runs out
