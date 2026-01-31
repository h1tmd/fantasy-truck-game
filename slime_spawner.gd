extends Node2D

@export var slime_scene: PackedScene
@export var spawn_interval: float = 4.0
@export var max_slimes: int = 10
@export var spawn_radius: float = 200.0

var spawned := []

func _ready() -> void:
	spawn_loop()

func spawn_loop() -> void:
	while true:
		await get_tree().create_timer(spawn_interval).timeout

		# Clean invalid slimes
		spawned = spawned.filter(func(s): return is_instance_valid(s))

		if spawned.size() < max_slimes:
			spawn_slime()

func spawn_slime() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	var slime = slime_scene.instantiate()

	var offset = Vector2(
		randf_range(-spawn_radius, spawn_radius),
		randf_range(-spawn_radius, spawn_radius)
	)

	slime.global_position = player.global_position + offset

	slime.visible = true
	slime.scale = Vector2.ONE
	slime.z_index = 100

	get_tree().current_scene.add_child(slime)
	spawned.append(slime)
