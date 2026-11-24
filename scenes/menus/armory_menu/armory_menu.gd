extends Control

# Configuration
const BASE_COST: int = 1000
const COST_PER_LEVEL: int = 500
const MAX_LEVEL: int = 3

# Drag your player_stats.tres file into this exported variable in the Inspector
@export var stats: PlayerStats

var game_state := GameState.get_or_create_state()

# UI Node References (Adjust node paths to match your scene tree)
@onready var points_label: Label = $MarginContainer2/HBoxContainer/VBoxContainer/HBoxContainer/TotalBolts

@onready var health_bar: ProgressBar = $MarginContainer2/HBoxContainer/VBoxContainer/StatsList/UpgradeRow_Health/UpgradeLevel/ProgressBar
@onready var health_btn: Button = $MarginContainer2/HBoxContainer/VBoxContainer/StatsList/UpgradeRow_Health/UpgradeButton
@onready var health_cost_label: Label = $MarginContainer2/HBoxContainer/VBoxContainer/StatsList/UpgradeRow_Health/HBoxContainer/UpgradeCostLabel

@onready var speed_bar: ProgressBar = $MarginContainer2/HBoxContainer/VBoxContainer/StatsList/UpgradeRow_Speed/UpgradeLevel/ProgressBar
@onready var speed_btn: Button = $MarginContainer2/HBoxContainer/VBoxContainer/StatsList/UpgradeRow_Speed/UpgradeButton
@onready var speed_cost_label: Label = $MarginContainer2/HBoxContainer/VBoxContainer/StatsList/UpgradeRow_Speed/HBoxContainer/UpgradeCostLabel

@onready var damage_bar: ProgressBar = $MarginContainer2/HBoxContainer/VBoxContainer/StatsList/UpgradeRow_Damage/UpgradeLevel/ProgressBar
@onready var damage_btn: Button = $MarginContainer2/HBoxContainer/VBoxContainer/StatsList/UpgradeRow_Damage/UpgradeButton
@onready var damage_cost_label: Label = $MarginContainer2/HBoxContainer/VBoxContainer/StatsList/UpgradeRow_Damage/HBoxContainer/UpgradeCostLabel


func _ready() -> void:
	health_bar.max_value = MAX_LEVEL
	speed_bar.max_value = MAX_LEVEL
	damage_bar.max_value = MAX_LEVEL

	health_btn.pressed.connect(_on_health_upgrade)
	speed_btn.pressed.connect(_on_speed_upgrade)
	damage_btn.pressed.connect(_on_damage_upgrade)

	update_ui()


func get_upgrade_cost(current_level: int) -> int:
	return BASE_COST + (current_level * COST_PER_LEVEL)


func update_ui() -> void:
	if stats == null or game_state == null:
		return

	points_label.text = str(game_state.total_bolts)

	_update_stat_row(stats.max_health_level, health_bar, health_btn, health_cost_label)
	_update_stat_row(stats.speed_level, speed_bar, speed_btn, speed_cost_label)
	_update_stat_row(stats.damage_level, damage_bar, damage_btn, damage_cost_label)


func save_stats() -> void:
	ResourceSaver.save(stats, "res://resources/player_stats.tres")
	update_ui()


func _update_stat_row(current_level: int, bar: ProgressBar, btn: Button, cost_label: Label) -> void:
	bar.value = current_level
	var is_maxed: bool = current_level >= MAX_LEVEL
	var cost: int = get_upgrade_cost(current_level)

	btn.disabled = is_maxed or game_state.total_bolts < cost
	cost_label.text = "MAX" if is_maxed else str(cost)


func _on_health_upgrade() -> void:
	var cost: int = get_upgrade_cost(stats.max_health_level)
	if game_state.total_bolts >= cost and stats.max_health_level < MAX_LEVEL:
		game_state.total_bolts -= cost
		stats.max_health_level += 1
		stats.max_health += 2
		save_stats()
		GlobalState.save()


func _on_speed_upgrade() -> void:
	var cost: int = get_upgrade_cost(stats.speed_level)
	if game_state.total_bolts >= cost and stats.speed_level < MAX_LEVEL:
		game_state.total_bolts -= cost
		stats.speed_level += 1
		stats.speed += 20
		save_stats()
		GlobalState.save()


func _on_damage_upgrade() -> void:
	var cost: int = get_upgrade_cost(stats.damage_level)
	if game_state.total_bolts >= cost and stats.damage_level < MAX_LEVEL:
		game_state.total_bolts -= cost
		stats.damage_level += 1
		stats.damage += 1
		save_stats()
		GlobalState.save()
