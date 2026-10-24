extends Label

var time_played: float = 0.0

func _process(delta: float) -> void:
	# Accumulate the elapsed frame time
	time_played += delta
	
	# Update the label text with the formatted time string
	text = get_formatted_time(time_played)

func get_formatted_time(total_seconds: float) -> String:
	# Calculate hours, minutes, and seconds
	var hours: int = int(total_seconds) / 3600
	var minutes: int = (int(total_seconds) % 3600) / 60
	var seconds: int = int(total_seconds) % 60
	
	# Format to pad single digits with leading zeros (e.g., 01:05:09)
	return "TIME: " + "%02d:%02d:%02d" % [hours, minutes, seconds]
