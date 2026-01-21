class_name VirtualJoystick
extends Control

@export var radius := 100.0
var direction := Vector2.ZERO
var touching := false

@onready var base := $Base
@onready var stick := $Stick

func _ready():
	stick.position = base.size / 2 - stick.size / 2

func _gui_input(event):
	if event is InputEventScreenTouch:
		touching = event.pressed
		if not touching:
			reset_stick()

	if event is InputEventScreenDrag and touching:
		var center: Vector2 = base.global_position + Vector2(base.size) / 2
		direction = (event.position - center).limit_length(radius) / radius
		stick.global_position = center + direction * radius - stick.size / 2
	
	if event is InputEventMouseButton:
		touching = event.pressed
		if not touching:
			reset_stick()

	if event is InputEventMouseMotion and touching:
		var center: Vector2 = base.global_position + Vector2(base.size) / 2
		direction = (event.position - center).limit_length(radius) / radius
		stick.global_position = center + direction * radius - stick.size / 2

func reset_stick():
	direction = Vector2.ZERO
	stick.position = base.size / 2 - stick.size / 2
