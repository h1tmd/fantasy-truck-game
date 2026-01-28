extends Control

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS


func show_menu() -> void:
	visible = true
	get_tree().paused = true


func hide_menu() -> void:
	visible = false
	get_tree().paused = false


func _on_resume_btn_pressed() -> void:
	$"../PauseBtn".visible = true
	hide_menu()
	#latibayyyyy gumanaaaa


func _on_options_btn_pressed() -> void:
	# You can implement this later
	pass


func _on_exit_btn_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://ui/mainMenu/mainMenu.tscn")
