class_name GameState
extends Resource

const STATE_NAME : String = "GameState"
const FILE_PATH = "res://scripts/game_state.gd"
const PLAYER_STATS_RESOURCE_PATH = "res://resources/player_stats.tres"

@export var play_time : int
@export var total_time : int
@export var total_bolts : int

static func has_game_state() -> bool:
	return GlobalState.has_state(STATE_NAME)

static func get_or_create_state() -> GameState:
	return GlobalState.get_or_create_state(STATE_NAME, FILE_PATH)

static func play_game() -> void:
	GlobalState.save()

static func reset() -> void:
	var game_state := get_or_create_state()
	game_state.play_time = 0
	game_state.total_time = 0
	game_state.total_bolts = 0
	reset_player_stats()
	GlobalState.save()

static func reset_player_stats() -> void:
	var player_stats = ResourceLoader.load(PLAYER_STATS_RESOURCE_PATH)
	player_stats.max_health = 3.0
	player_stats.speed = 100.0
	player_stats.damage = 1.0
	player_stats.max_health_level = 0
	player_stats.speed_level = 0
	player_stats.damage_level = 0
	ResourceSaver.save(player_stats, PLAYER_STATS_RESOURCE_PATH)
	
