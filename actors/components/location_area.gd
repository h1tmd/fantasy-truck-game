extends Area2D

@export var location_res: Location
@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var minimap_ui: MiniMap = get_tree().get_first_node_in_group("minimap")

signal is_target_loc(type: MiniMap.LocType, pos: Vector2)

func _ready() -> void:
	if player:
		player.quest_changed.connect(_on_quest_changed)
		# Initial call setting UI
		_on_quest_changed(player.current_quest)
	if minimap_ui:
		is_target_loc.connect(minimap_ui.mark_location)


func _on_body_entered(body: Node2D) -> void:
	#print("body entered")
	if body is Player:
		#print("body is Player")
		body.on_location_arrived(location_res)

func _on_quest_changed(quest: Quest):
	if quest:
		if quest.status == Quest.QuestStatus.READY and quest.starting_location == location_res:
			sprite_2d.show()
			sprite_2d.self_modulate = Color(0.302, 0.722, 0.408)
			is_target_loc.emit(MiniMap.LocType.START, global_position)
		elif quest.status == Quest.QuestStatus.ONGOING and quest.end_location == location_res:
			sprite_2d.show()
			sprite_2d.self_modulate = Color(0.302, 0.518, 0.722)
			is_target_loc.emit(MiniMap.LocType.END, global_position)
		else:
			sprite_2d.hide()
