extends Node

@onready var win_lose_manager: Node = $"../WinLoseManager"
@onready var game_timer: Node = $"../GameTimer"

func _process(_delta: float) -> void:
	if game_timer.play_time >= 1200.1:
		print("WIN")
		win_lose_manager.game_won()
		set_process(false) # Stops checking once win condition is met

func _on_player_player_died() -> void:
	win_lose_manager.game_lost()
