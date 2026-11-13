extends MarginContainer

@onready var score_label: Label = $VBoxContainer/HBoxContainer/ScoreLabel
@onready var score_multiplier_label: Label = $VBoxContainer/HBoxContainer/ScoreMultiplierLabel

func _ready() -> void:
	ScoreManager.score_changed.connect(_on_score_manager_score_changed)
	ScoreManager.score_multiplier_changed.connect(_on_score_manager_score_multiplier_changed)
	
	# Initial text with 6-digit leading zeros
	score_label.text = "Score: %06d" % ScoreManager.score
	score_multiplier_label.text = "x%.1f" % ScoreManager.score_multiplier

func _on_score_manager_score_changed(new_score: int) -> void:
	# Format with 6 digits, padding with zeros on the left
	score_label.text = "Score: %06d" % new_score

func _on_score_manager_score_multiplier_changed(new_score_multiplier: float) -> void:
	score_multiplier_label.text = "x%.1f" % new_score_multiplier
