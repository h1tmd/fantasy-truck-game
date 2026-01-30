extends Button

@export var action_name: String

func _ready():
	connect("button_down", _on_down)
	connect("button_up", _on_up)

func _on_down():
	Input.action_press(action_name)

func _on_up():
	Input.action_release(action_name)
