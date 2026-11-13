extends Node

signal score_changed(new_score: int)
signal score_multiplier_changed(new_score_multiplier: float)

var score: int = 0
var score_multiplier: float = 1.0

var multiplier_increases: int = 0
const MAX_MULTIPLIER_INCREASES: int = 3
const MULTIPLIER_INTERVAL_SECONDS: float = 300.0 # 5 minutes

var multiplier_timer: Timer

func _ready() -> void:
	_setup_timer()

func _setup_timer() -> void:
	# Create and configure the timer entirely in code
	multiplier_timer = Timer.new()
	add_child(multiplier_timer)
	
	multiplier_timer.wait_time = MULTIPLIER_INTERVAL_SECONDS
	multiplier_timer.one_shot = false
	multiplier_timer.timeout.connect(_on_multiplier_timer_timeout)
	multiplier_timer.start()

# Call this from your enemy script when it dies
func add_points(base_points: int = 10) -> void:
	var points_earned = int(base_points * score_multiplier)
	score += points_earned
	score_changed.emit(score)
	print("Enemy destroyed! Earned: %d | Total Score: %d" % [points_earned, score])

func _on_multiplier_timer_timeout() -> void:
	if multiplier_increases < MAX_MULTIPLIER_INCREASES:
		score_multiplier += 0.5
		multiplier_increases += 1
		score_multiplier_changed.emit(score_multiplier)
		print("Multiplier increased! Current multiplier: ", score_multiplier)
		
		# Stop the timer once we hit the max to save processing
		if multiplier_increases >= MAX_MULTIPLIER_INCREASES:
			multiplier_timer.stop()
			print("Max multiplier of 2.5 reached!")
