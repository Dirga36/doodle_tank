extends SubViewport
## Script to apply the anti-aliasing setting from [PlayerConfig] to a [SubViewport].
@onready var minimap_camera: Camera2D = $Camera2D

## The name of the anti-aliasing variable in the [ConfigFile].
@export var anti_aliasing_key : StringName = "Anti-aliasing"
## The name of the section of the anti-aliasing variable in the [ConfigFile].
@export var video_section : StringName = AppSettings.VIDEO_SECTION

func _ready() -> void:
	world_2d = get_tree().root.world_2d
	var anti_aliasing : int = PlayerConfig.get_config(video_section, anti_aliasing_key, Viewport.MSAA_DISABLED)
	msaa_2d = anti_aliasing as MSAA
	msaa_3d = anti_aliasing as MSAA

func _physics_process(_delta: float) -> void:
	if Global.player:
		# Force the minimap camera to track the player's position
		minimap_camera.global_position = Global.player.global_position
