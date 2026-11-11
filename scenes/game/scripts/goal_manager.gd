extends Node

@onready var win_lose_manager: Node = $"../WinLoseManager"
@onready var game_timer: Node = $"../GameTimer"

func _process(_delta: float) -> void:
	if game_timer.play_time >= 5.1: # shorten for testing, usually 600.1
		print("WIN")
		win_lose_manager.game_won()
		set_process(false) # Stops checking once win condition is met
		ScoreManager.score += 2000
		var score_gained = ScoreManager.score
		var game_state := GameState.get_or_create_state()
		game_state.total_score += score_gained
		GlobalState.save()

func _on_player_player_died() -> void:
	print("LOSE")
	win_lose_manager.game_lost()
	var score_gained = ScoreManager.score
	var game_state := GameState.get_or_create_state()
	game_state.total_score += score_gained
	GlobalState.save()
