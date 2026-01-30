extends Node2D
class_name MiniMap

enum LocType { START, END }

@onready var camera_2d: Camera2D = $Camera2D
@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var marker: Sprite2D = $Marker
@onready var minimap_sprite: Sprite2D = $MinimapSprite
@onready var start_marker: Sprite2D = $"Start Marker"
@onready var end_marker: Sprite2D = $"End Marker"

# Dimensions
const minimap_size: Vector2 = Vector2(205, 156)
const game_space_size: Vector2 = Vector2(17920, 13824)
const scale_factor = Vector2(2.5, 2.5)  # Adjust this based on your findings

func _process(_delta: float) -> void:
	if player:
		update_player_marker()

func update_player_marker() -> void:
	marker.position = translate_position(player.global_position)

func translate_position(pos: Vector2):
	var normalized_position = pos / game_space_size
	var minimap_position = normalized_position * minimap_size
	return minimap_position * scale_factor

func mark_location(loctype: LocType, locpos: Vector2i):
	if loctype == LocType.START:
		start_marker.show()
		start_marker.position = translate_position(locpos)
		end_marker.hide()
	elif loctype == LocType.END:
		end_marker.show()
		end_marker.position = translate_position(locpos)
		start_marker.hide()
