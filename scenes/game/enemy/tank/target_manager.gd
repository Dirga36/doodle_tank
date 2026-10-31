extends Node

signal target_in_range
signal target_lost

func _on_target_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		target_in_range.emit()


func _on_target_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		target_lost.emit()
