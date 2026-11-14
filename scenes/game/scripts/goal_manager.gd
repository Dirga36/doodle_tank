extends Node
## Watches for the win/lose conditions and records the run's score when it ends.

const WIN_TIME_SECONDS: float = 600.1 # Shorten to 5.1 for testing.
const WIN_BONUS_SCORE: int = 2000

@onready var win_lose_manager: Node = %WinLoseManager
@onready var game_timer: GameTimer = %GameTimer


func _process(_delta: float) -> void:
	if game_timer.play_time >= WIN_TIME_SECONDS:
		print("WIN")
		win_lose_manager.game_won()
		set_process(false) # Stops checking once the win condition is met.
		ScoreManager.score += WIN_BONUS_SCORE
		_record_score()


func _on_player_player_died() -> void:
	print("LOSE")
	win_lose_manager.game_lost()
	_record_score()


func _record_score() -> void:
	var score_gained: int = ScoreManager.score
	var game_state: GameState = GameState.get_or_create_state()
	game_state.total_score += score_gained
	GlobalState.save()
