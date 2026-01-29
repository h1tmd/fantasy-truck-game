extends Control


const MAIN_GAME = preload("uid://0a4sac7166s3")

func _on_start_pressed() -> void:
	get_tree().change_scene_to_packed(MAIN_GAME)


func _on_options_pressed() -> void:
	pass # Replace with function body.


func _on_exit_pressed() -> void:
	get_tree().quit() # Replace with function body.
