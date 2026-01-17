extends Node

@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var name_ui: Label = $PanelContainer/MarginContainer/VBoxContainer/Name
@onready var location: Label = $PanelContainer/MarginContainer/VBoxContainer/Location
@onready var status: Label = $PanelContainer/MarginContainer/VBoxContainer/Status

func _ready() -> void:
	print("Player Obtained: " + player.to_string())

func _process(_delta: float) -> void:
	if player.current_quest != null:
		name_ui.text = player.current_quest.name
		location.text = player.current_quest.location.name
		status.text = "Ongoing"
	else:
		status.text = "Done!"
