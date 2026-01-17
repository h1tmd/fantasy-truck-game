class_name Player
extends CharacterBody2D

@export var speed: float = 250.0

var current_quest: Quest
var is_quest_completed = false

func _ready() -> void:
	current_quest = preload("uid://c1k3rjn6sjhj3")
	print("Current Quest: " + current_quest.name)

func _physics_process(_delta):
	var input_dir := Vector2.ZERO

	# Read input
	input_dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_dir.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	# Movement
	if input_dir.length() > 0:
		input_dir = input_dir.normalized()
		velocity = input_dir * speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()

	# Rotate car to face movement direction
	if velocity.length() > 0:
		rotation = velocity.angle() + PI / 2

func generate_quest(prev_loc:Location):
	# Generate a random location that is not the previous location
	pass

func on_location_arrived(location: Location):
	# Check if location matches with quest
	if current_quest != null:
		if current_quest.location == location:
			is_quest_completed = true
			print("Quest Completed!")
			current_quest = null
			# Generate new quest here
			generate_quest(location)
