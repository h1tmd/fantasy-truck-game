extends StaticBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D

const colors: Array[Color] = [
	Color(0.4, 0.145, 0.216),
	Color(0.31, 0.199, 0.321),
	Color(0.165, 0.237, 0.413),
	Color(0.125, 0.268, 0.313),
	Color(0.158, 0.275, 0.216),
	Color(0.198, 0.271, 0.159),
	Color(0.3, 0.234, 0.127),
	Color(0.32, 0.222, 0.148)
]

func _ready() -> void:
	sprite_2d.self_modulate = colors.pick_random()
