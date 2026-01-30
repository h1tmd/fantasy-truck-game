extends Area2D

@export var location_res: Location
@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	if player:
		player.quest_changed.connect(_on_quest_changed)
		# Initial call setting UI
		_on_quest_changed(player.current_quest)

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
		elif quest.status == Quest.QuestStatus.ONGOING and quest.end_location == location_res:
			sprite_2d.show()
			sprite_2d.self_modulate = Color(0.302, 0.518, 0.722)
		else:
			sprite_2d.hide()
