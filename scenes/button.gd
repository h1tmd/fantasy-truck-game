extends Button

@onready var pause_menu: Control = $"../PauseMenu"

func _pressed() -> void:
	visible = false
	pause_menu.show_menu()
