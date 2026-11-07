extends Label

var game_state := GameState.get_or_create_state()

func _ready() -> void:
	text = "Score: %06d" % game_state.total_score
