extends Area2D

@export var location_res: Location

func _on_body_entered(body: Node2D) -> void:
	print("body entered")
	if body is Player:
		print("body is Player")
		body.on_location_arrived(location_res)
