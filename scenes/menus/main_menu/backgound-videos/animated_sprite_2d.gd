extends AnimatedSprite2D

# Optional: List specific animations if you don't want to include all of them
@export var custom_playlist: Array[String] = []

# Prevent the exact same animation from playing twice in a row ( optional )
@export var avoid_immediate_repeats: bool

var _available_animations: Array[String] = []
var _last_played: String = ""

func _ready() -> void:
	# If custom_playlist is empty, fetch all available animation names from SpriteFrames
	if custom_playlist.is_empty():
		_available_animations = sprite_frames.get_animation_names()
	else:
		_available_animations = custom_playlist

	# Start playing a random animation on ready
	play_random_animation()

func play_random_animation() -> void:
	if _available_animations.is_empty():
		return

	var candidates: Array[String] = _available_animations.duplicate()

	# Remove the previous animation from choices if avoid_immediate_repeats is true
	if avoid_immediate_repeats and candidates.size() > 1 and _last_played != "":
		candidates.erase(_last_played)

	# Select a random animation from candidates
	var next_anim: String = candidates.pick_random()
	_last_played = next_anim

	play(next_anim)

# Signal callback connected from AnimatedSprite2D
func _on_animation_finished() -> void:
	play_random_animation()
