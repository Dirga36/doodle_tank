extends MarginContainer
## Displays the current bolts and bolts multiplier, updating when they change.

@onready var bolts_label: Label = $VBoxContainer/HBoxContainer/BoltsLabel
@onready var bolts_multiplier_label: Label = $VBoxContainer/HBoxContainer/BoltsMultiplierLabel


func _ready() -> void:
	BoltsManager.bolts_changed.connect(_on_bolts_manager_bolts_changed)
	BoltsManager.bolts_multiplier_changed.connect(_on_bolts_manager_bolts_multiplier_changed)

	# Initial text with 6-digit leading zeros.
	bolts_label.text = "%d" % BoltsManager.bolts
	bolts_multiplier_label.text = "x%.1f" % BoltsManager.bolts_multiplier


func _on_bolts_manager_bolts_changed(new_bolts: int) -> void:
	# Format with 6 digits, padding with zeros on the left.
	bolts_label.text = "%d" % new_bolts


func _on_bolts_manager_bolts_multiplier_changed(new_bolts_multiplier: float) -> void:
	bolts_multiplier_label.text = "x%.1f" % new_bolts_multiplier
