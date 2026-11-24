extends MainMenu
## Main menu extension that adds options.

@onready var play_game_button = %ContinueGameButton


func _ready() -> void:
	super._ready()


func load_game_scene() -> void:
	GameState.play_game()
	super.load_game_scene()


func _on_play_game_button_pressed() -> void:
	GameState.play_game()
	load_game_scene()
