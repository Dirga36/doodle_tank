extends Label

func _ready() -> void:
	ScoreManager.score_changed.connect(_on_score_manager_score_changed)
	
	# Initial text with 6-digit leading zeros
	text = "Score: %06d" % ScoreManager.score

func _on_score_manager_score_changed(new_score: int) -> void:
	# Format with 6 digits, padding with zeros on the left
	text = "Score: %06d" % new_score
