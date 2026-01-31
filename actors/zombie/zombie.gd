extends CharacterBody2D

var speed = 50
var player_chase = false
var player = null

func _physics_process(_delta):
	if player_chase:

		position += (player.position - position)/speed
		rotation = (player.global_position - global_position).angle()
		rotation += PI / 2   # if sprite faces UP
		
		# Your existing movement	
		#position += (player.position - position) / speed
		
func _on_area_2d_body_entered(body: Node2D) -> void:
	player = body
	player_chase = true
		
func _on_area_2d_body_exited(_body: Node2D) -> void:
	player = null
	player_chase = false

func zombie():
	pass
