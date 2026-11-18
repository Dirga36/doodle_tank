extends Node
## Tracks the player's bolts and the timed bolts multiplier.

signal bolts_changed(new_bolts: int)
signal bolts_multiplier_changed(new_bolts_multiplier: float)

const MAX_MULTIPLIER_INCREASES: int = 3
const MULTIPLIER_INTERVAL_SECONDS: float = 300.0 # 5 minutes
const MULTIPLIER_STEP: float = 0.5
const DEFAULT_BASE_POINTS: int = 10

var bolts: int = 0
var bolts_multiplier: float = 1.0
var multiplier_increases: int = 0

var _multiplier_timer: Timer


func _ready() -> void:
	_setup_timer()


## Awards points scaled by the current bolts multiplier.
func add_points(base_points: int = DEFAULT_BASE_POINTS) -> void:
	var points_earned: int = int(base_points * bolts_multiplier)
	bolts += points_earned
	bolts_changed.emit(bolts)
	print("Enemy destroyed! Earned: %d | Total Bolts: %d" % [points_earned, bolts])


func _setup_timer() -> void:
	# Create and configure the timer entirely in code.
	_multiplier_timer = Timer.new()
	add_child(_multiplier_timer)

	_multiplier_timer.wait_time = MULTIPLIER_INTERVAL_SECONDS
	_multiplier_timer.one_shot = false
	_multiplier_timer.timeout.connect(_on_multiplier_timer_timeout)
	_multiplier_timer.start()


func _on_multiplier_timer_timeout() -> void:
	if multiplier_increases < MAX_MULTIPLIER_INCREASES:
		bolts_multiplier += MULTIPLIER_STEP
		multiplier_increases += 1
		bolts_multiplier_changed.emit(bolts_multiplier)
		print("Multiplier increased! Current multiplier: ", bolts_multiplier)

		# Stop the timer once we hit the max to save processing.
		if multiplier_increases >= MAX_MULTIPLIER_INCREASES:
			_multiplier_timer.stop()
			print("Max multiplier of 2.5 reached!")
