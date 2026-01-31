extends Node2D

@export var skeleton_scene: PackedScene
@export var spawn_interval: float = 4.0
@export var max_skeletons: int = 10
@export var spawn_radius: float = 200.0

# Collision layers to avoid
@export var collision_layer_to_avoid: int = 1

var spawned := []

func _ready() -> void:
	spawn_loop()

func spawn_loop() -> void:
	while true:
		await get_tree().create_timer(spawn_interval).timeout

		spawned = spawned.filter(func(s): return is_instance_valid(s))

		if spawned.size() < max_skeletons:
			spawn_skeleton()

func spawn_skeleton() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	var attempts := 0
	var max_attempts := 15

	while attempts < max_attempts:
		attempts += 1

		var offset = Vector2(
			randf_range(-spawn_radius, spawn_radius),
			randf_range(-spawn_radius, spawn_radius)
		)

		var spawn_pos = player.global_position + offset

		# Check if position is inside collision
		if not is_position_colliding(spawn_pos):
			var skeleton = skeleton_scene.instantiate()
			skeleton.global_position = spawn_pos
			skeleton.visible = true
			skeleton.scale = Vector2.ONE
			skeleton.z_index = 100

			get_tree().current_scene.add_child(skeleton)
			spawned.append(skeleton)
			return

# Checks if a position collides with anything
func is_position_colliding(pos: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state

	var params = PhysicsPointQueryParameters2D.new()
	params.position = pos
	params.collision_mask = collision_layer_to_avoid
	params.collide_with_bodies = true
	params.collide_with_areas = false

	var result = space_state.intersect_point(params)

	return result.size() > 0
