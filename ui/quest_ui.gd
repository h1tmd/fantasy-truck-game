extends Node

@onready var player: Player = get_tree().get_first_node_in_group("player")

@onready var name_ui: Label = $PanelContainer/MarginContainer/VBoxContainer/Name
@onready var start_location: Label = $"PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Start Location"
@onready var end_location: Label = $"PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/End Location"
@onready var status: Label = $PanelContainer/MarginContainer/VBoxContainer/Status

func _ready() -> void:
	if player:
		player.quest_changed.connect(_on_quest_changed)
		# Initial call setting UI
		_on_quest_changed(player.current_quest)

func _on_quest_changed(quest: Quest):
	if quest != null:
		var quest_status: String = Quest.QuestStatus.find_key(quest.status)
		if quest.type == Quest.QuestType.DELIVERY:
			name_ui.text = "Make a delivery!"
		else:
			name_ui.text = "Drive a passenger!"
		
		start_location.text = quest.starting_location.name
		end_location.text = quest.end_location.name
		if quest.status == Quest.QuestStatus.READY:
			start_location.add_theme_constant_override("outline_size", 10)
			end_location.add_theme_constant_override("outline_size", 0)
		else:
			end_location.add_theme_constant_override("outline_size", 10)
			start_location.add_theme_constant_override("outline_size", 0)
		status.text = quest_status
	#else:
		#status.text = "No quest available"
