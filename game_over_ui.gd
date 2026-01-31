extends CanvasLayer

# -----------------------
# Initialization
func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS  # ensures _process runs even when paused


# -----------------------
# Show the Game Over menu
func show_menu() -> void:
	visible = true
	get_tree().paused = true


# -----------------------
# Hide the Game Over menu
func hide_menu() -> void:
	visible = false
	get_tree().paused = false




func _on_restart_pressed() -> void:
	hide_menu()
	get_tree().reload_current_scene() # Replace with function body.


func _on_exit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://ui/mainMenu/mainMenu.tscn")
