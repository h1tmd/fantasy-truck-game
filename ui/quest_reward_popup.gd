extends Control

@onready var timer: Timer = $Timer
@onready var player: Player = get_tree().get_first_node_in_group("player")

@onready var option_1: Button = $"PanelContainer/MarginContainer/VBoxContainer/Option 1"
@onready var option_2: Button = $"PanelContainer/MarginContainer/VBoxContainer/Option 2"
@onready var option_3: Button = $"PanelContainer/MarginContainer/VBoxContainer/Option 3"

const rewards_directory := "res://data/rewards/"

var rewards: Array[PlayerReward] = []
var randomized: Array[PlayerReward]
var choices: Array[Button]


func _init() -> void:
	# Load rewards
	for reward in ResourceLoader.list_directory(rewards_directory):
		rewards.append(load(rewards_directory.path_join(reward)))

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	if player:
		player.quest_completed.connect(_on_quest_completed)
	
	choices = [option_1, option_2, option_3]
	for i in range(choices.size()):
		choices[i].pressed.connect(on_choice_select.bind(i))


func set_choices():
	rewards.shuffle()
	for i in range(choices.size()):
		choices[i].text = rewards[i].reward_description


func on_choice_select(index: int):
	var method: String = rewards[index].player_method_name
	var args: Array = rewards[index].method_args
	hide_menu()
	player.callv(method, args)

func show_menu() -> void:
	visible = true
	get_tree().paused = true

func hide_menu() -> void:
	visible = false
	get_tree().paused = false

func _on_quest_completed():
	set_choices()
	show_menu()
