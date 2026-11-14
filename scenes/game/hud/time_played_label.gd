extends Label
## Shows the elapsed play time as MM:SS.

## The game timer whose [member GameTimer.play_time] is displayed.
@export var game_timer: GameTimer


func _process(_delta: float) -> void:
	if game_timer == null:
		return

	var total_seconds: int = game_timer.play_time
	var minutes: int = int((total_seconds % 3600) / 60.0)
	var seconds: int = total_seconds % 60
	text = "%02d:%02d" % [minutes, seconds]
