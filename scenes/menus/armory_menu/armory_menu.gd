extends Control

var game_state := GameState.get_or_create_state()

# Drag your player_stats.tres file into this exported variable in the Inspector
@export var stats: PlayerStats 

# UI Node References (Adjust node paths to match your scene tree)
@onready var points_label: Label = $MarginContainer2/HBoxContainer/VBoxContainer/HBoxContainer/TotalScore

@onready var health_bar: ProgressBar = $MarginContainer2/HBoxContainer/VBoxContainer/StatsList/UpgradeRow_Health/UpgradeLevel/ProgressBar
@onready var health_btn: Button = $MarginContainer2/HBoxContainer/VBoxContainer/StatsList/UpgradeRow_Health/UpgradeButton

@onready var speed_bar: ProgressBar = $MarginContainer2/HBoxContainer/VBoxContainer/StatsList/UpgradeRow_Speed/UpgradeLevel/ProgressBar
@onready var speed_btn: Button = $MarginContainer2/HBoxContainer/VBoxContainer/StatsList/UpgradeRow_Speed/UpgradeButton

@onready var damage_bar: ProgressBar = $MarginContainer2/HBoxContainer/VBoxContainer/StatsList/UpgradeRow_Damage/UpgradeLevel/ProgressBar
@onready var damage_btn: Button = $MarginContainer2/HBoxContainer/VBoxContainer/StatsList/UpgradeRow_Damage/UpgradeButton

# Configuration
const BASE_COST: int = 1000
const COST_PER_LEVEL: int = 500
const MAX_LEVEL: int = 3

func _ready() -> void:
	# Connect button signals
	health_btn.pressed.connect(_on_health_upgrade)
	speed_btn.pressed.connect(_on_speed_upgrade)
	damage_btn.pressed.connect(_on_damage_upgrade)
	
	update_ui()

# Function to calculate dynamic cost based on current level
func get_upgrade_cost(current_level: int) -> int:
	# Example: Level 0 = 1000, Level 1 = 1500, Level 2 = 2000...
	return BASE_COST + (current_level * COST_PER_LEVEL)

func update_ui() -> void:	
	# Update progress bars based on current level vs max level
	health_bar.value = stats.max_health_level
	speed_bar.value = stats.speed_level
	damage_bar.value = stats.damage_level
	
	# Calculate current specific cost for each stat
	var current_health_cost: int = get_upgrade_cost(stats.max_health_level)
	var current_speed_cost: int = get_upgrade_cost(stats.speed_level)
	var current_damage_cost: int = get_upgrade_cost(stats.damage_level)
	
	# Disable upgrade buttons if the player lacks points for that specific stat or reached max level
	health_btn.disabled = game_state.total_score < current_health_cost or stats.max_health_level >= MAX_LEVEL
	speed_btn.disabled = game_state.total_score < current_speed_cost or stats.speed_level >= MAX_LEVEL
	damage_btn.disabled = game_state.total_score < current_damage_cost or stats.damage_level >= MAX_LEVEL
	
	# (Optional) If you have labels next to the buttons to display the cost, update them here:
	$MarginContainer2/HBoxContainer/VBoxContainer/StatsList/UpgradeRow_Health/HBoxContainer/UpgradeCostLabel.text = str(current_health_cost) + " PTS"
	$MarginContainer2/HBoxContainer/VBoxContainer/StatsList/UpgradeRow_Speed/HBoxContainer/UpgradeCostLabel.text = str(current_speed_cost) + " PTS"
	$MarginContainer2/HBoxContainer/VBoxContainer/StatsList/UpgradeRow_Damage/HBoxContainer/UpgradeCostLabel.text = str(current_damage_cost) + " PTS"

func _on_health_upgrade() -> void:
	var cost = get_upgrade_cost(stats.max_health_level)
	if game_state.total_score >= cost and stats.max_health_level < MAX_LEVEL:
		game_state.total_score -= cost
		stats.max_health_level += 1
		stats.max_health += 2
		save_stats()

func _on_speed_upgrade() -> void:
	var cost = get_upgrade_cost(stats.speed_level)
	if game_state.total_score >= cost and stats.speed_level < MAX_LEVEL:
		game_state.total_score -= cost
		stats.speed_level += 1
		stats.speed += 20
		save_stats()

func _on_damage_upgrade() -> void:
	var cost = get_upgrade_cost(stats.damage_level)
	if game_state.total_score >= cost and stats.damage_level < MAX_LEVEL:
		game_state.total_score -= cost
		stats.damage_level += 1
		stats.damage += 1
		save_stats()

func save_stats() -> void:
	# Saves the modified resource to disk so upgrades persist across game sessions
	ResourceSaver.save(stats, "res://resources/player_stats.tres")
	
	# Refresh the UI to reflect the deducted points and new progress bar values
	update_ui()
