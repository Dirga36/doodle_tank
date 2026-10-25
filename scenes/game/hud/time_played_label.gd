extends Label

@onready var game_timer: Node = $"../GameTimer"

func _process(_delta: float) -> void:
	var total_seconds: int = int(game_timer.play_time)
	
	var hours: int = total_seconds / 3600
	var minutes: int = (total_seconds % 3600) / 60
	var seconds: int = total_seconds % 60
	
	text = "TIME: %02d:%02d:%02d" % [hours, minutes, seconds]
