extends Node

@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var name_ui: Label = $PanelContainer/MarginContainer/VBoxContainer/Name
@onready var location: Label = $PanelContainer/MarginContainer/VBoxContainer/Location
@onready var status: Label = $PanelContainer/MarginContainer/VBoxContainer/Status

func _ready() -> void:
	if player:
		player.quest_changed.connect(_on_quest_changed)
		# Initial call setting UI
		_on_quest_changed(player.current_quest)

func _on_quest_changed(quest: Quest):
	if quest != null:
		var quest_status: String = Quest.QuestStatus.find_key(quest.status)
		name_ui.text = quest.name
		if quest.status == Quest.QuestStatus.READY:
			location.text = quest.starting_location.name
		else:
			location.text = quest.end_location.name
		status.text = quest_status
	#else:
		#status.text = "No quest available"
