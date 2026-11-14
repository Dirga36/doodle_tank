class_name GameTimer
extends Node
## Tracks play time (pausable) and total time (runs even while paused).

var play_time: int = 0
var total_time: int = 0


func _enter_tree() -> void:
	_add_timers()


func _exit_tree() -> void:
	var game_state: GameState = GameState.get_or_create_state()
	game_state.play_time += play_time
	game_state.total_time += total_time
	GlobalState.save()


func _add_timers() -> void:
	var play_timer: Timer = Timer.new()
	play_timer.one_shot = false
	play_timer.process_mode = Node.PROCESS_MODE_PAUSABLE
	play_timer.timeout.connect(func() -> void: play_time += 1)
	add_child(play_timer)
	play_timer.start(1)

	var total_timer: Timer = Timer.new()
	total_timer.one_shot = false
	total_timer.process_mode = Node.PROCESS_MODE_ALWAYS
	total_timer.timeout.connect(func() -> void: total_time += 1)
	add_child(total_timer)
	total_timer.start(1)
