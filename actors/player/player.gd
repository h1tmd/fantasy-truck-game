# Player.gd
class_name Player
extends CharacterBody2D
# --- damage ---
var enemy_in_range = false
var skeleton_in_range = false
var enemy_attack_cooldown = false
var health = 100
var player_alive = true
var damage_taken_skeleton = 10
var damage_taken_slime = 10
var truck_damage = 0

@onready var road_layer: TileMapLayer = get_node("/root/Main Game/Main Map/Road")
@onready var grass_layer: TileMapLayer = get_node("/root/Main Game/Main Map/Grass")
@onready var water_layer: TileMapLayer = get_node("/root/Main Game/Main Map/Water")
@onready var environments_layer: TileMapLayer = get_node("/root/Main Game/Main Map/Environments")

# --- UI References ---
@onready var durability_bar := $CanvasLayer3/VBoxContainer/DurabilityBar
@onready var boost_bar := $CanvasLayer3/VBoxContainer/BoostLabel
@onready var shield_bar := $CanvasLayer3/VBoxContainer/ShieldLabel
@onready var load_sprite: Sprite2D = $"Truck Sprite/Load Sprite"
@onready var gas_bar := $CanvasLayer3/VBoxContainer/Gas
@onready var points_label: Label = $CanvasLayer3/VBoxContainer/PointsLabel
@onready var engine := $engine
@onready var accel := $forward
@onready var reverse := $reverse

# --- Movement ---
@export var max_speed: float = 200.0 # forward speed
@export var acceleration: float = 900.0
@export var friction: float = 800.0
@export var turn_speed: float = 2.0
@export var reverse_speed: float = 100.0
@export var reduce_gas: float = 0.0
@export var is_gas_gone: bool = false


	

func _on_game_over() -> void:
	print("Game Over! You fell into water.")
	velocity = Vector2.ZERO
	set_physics_process(false)
	 # Load the GameOver scene and show it
	var game_over_ui = load("res://game_over_ui.tscn").instantiate()
	get_tree().current_scene.add_child(game_over_ui)
	game_over_ui.show_menu()
	
# --- Surface ---
func get_surface_type() -> String:
	# Check which layer the player is over
	var layers = {
		"environment": environments_layer,
		"road": road_layer,
		"water": water_layer,
		"grass": grass_layer,
	}

	for surface_name in layers.keys():
		var layer = layers[surface_name]
		var cell = layer.local_to_map(layer.to_local(global_position))
		
		#print("Checking layer ", surface_name, " at cell ", cell)
		var data = layer.get_cell_tile_data(cell)
		if data:
			return data.get_custom_data("surface")
	
	return "road"  # default fallback
		
	



# --- Player Stats ---
var stats := {
	"durability": 100.0, # vehicle health
	"boost": 0.0, # speed multiplier
	"shield": 0.0, # damage reduction (0–1)
	"gas": 1500.0,
	"points": 0, # game points
}

# --- Quest ---
var quest_manager: QuestManager
signal quest_changed(quest)
signal quest_completed
var current_quest: Quest = null:
	get:
		return current_quest
	set(quest):
		quest_changed.emit(quest)
		current_quest = quest


# -----------------------
func _ready() -> void:
	# Generate first quest
	quest_manager = QuestManager.new()
	current_quest = quest_manager.generate_new_quest(null)
	current_quest.changed.connect(_on_current_quest_changed)

	# Initialize UI max values
	durability_bar.max_value = 100
	boost_bar.max_value = 100
	shield_bar.max_value = 100
	gas_bar.max_value = 1500.0

	# Initial UI update
	_update_ui()

 


# -----------------------
func _physics_process(delta: float) -> void:
	var surface = get_surface_type()
	#print(surface)
	# --- Check for Game Over ---
	if surface == "water":
		_on_game_over()
		return  # stop further movement immediately
	

	 
	var throttle := Input.get_action_strength("car_forward") - Input.get_action_strength("car_reverse")
	var steering := Input.get_action_strength("car_right") - Input.get_action_strength("car_left")
	
	#var throttle := (1 if input_forward else 0) - (1 if input_reverse else 0)
	#var steering := (1 if input_right else 0) - (1 if input_left else 0)

	
		
	slime_attack()
	skeleton_attack()
	if (damage_taken_skeleton % 50 == 0) :
		truck_damage += 10
	if (damage_taken_slime % 50 == 0) :
		truck_damage += 10
	
	if throttle > 0:
		if not engine.playing: engine.play()
		accel.stop()
		reverse.stop()
	elif throttle < 0:
		if not reverse.playing: reverse.play()
		engine.stop()
		accel.stop()
	else:
		if not accel.playing: accel.play()
		engine.stop()
		reverse.stop()
	
		
	var gas_reduction := (Input.get_action_strength("car_forward") + Input.get_action_strength("car_reverse"))
	reduce_gas += gas_reduction * 0.5
	
	#print(throttle)
	#var reduce :=  100 - throttle
	#print(gas_reduction)S
	# Rotate only if moving
	if velocity.length() > 5:
		rotation += steering * turn_speed * delta

	var forward := Vector2.UP.rotated(rotation)

	# Apply boost multiplier
	var effective_max_speed: float = max_speed * (1.0 + stats["boost"])
	# --- Apply surface modifiers ---
	match get_surface_type():
		"road":
			effective_max_speed *= 1.0   # full speed
			friction = 800
		"forest":
			effective_max_speed *= 0.9
			friction = 1000
		"grass":
			effective_max_speed *= 0.6   # slower on grass
			friction = 800
		"rock":
			effective_max_speed *= 0.8   # idk where is this environment
			friction = 800
		"ice":
			friction = 100

	
	# Accelerate
	if reduce_gas >= stats["gas"]:
		throttle = 0
		
	if throttle != 0:
		var target_speed = effective_max_speed if throttle > 0 else reverse_speed
		velocity = velocity.move_toward(
			forward * target_speed * throttle,
			acceleration * delta
		)
		
	else:
		# Natural slowdown
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	
	move_and_slide()
	
	# Update HUD every frame
	_update_ui()
	
	
# -----------------------
func _update_ui() -> void:
	durability_bar.value = stats["durability"] - truck_damage
	boost_bar.value = stats["boost"] * 100 # 0.0–1.0 -> 0–100%
	shield_bar.value = stats["shield"] * 100
	gas_bar.value = stats["gas"] - reduce_gas

# -----------------------
# Example skill / stat functions

func apply_boost(amount: float, duration: float) -> void:
	stats["boost"] += amount
	_update_ui()
	await get_tree().create_timer(duration).timeout
	stats["boost"] -= amount
	_update_ui()


func apply_shield(amount: float, duration: float) -> void:
	stats["shield"] += amount
	_update_ui()
	await get_tree().create_timer(duration).timeout
	stats["shield"] -= amount
	_update_ui()


func apply_damage(amount: float) -> void:
	# Reduce damage by shield
	var effective_damage = amount * (1.0 - stats["shield"])
	stats["durability"] -= effective_damage
	stats["durability"] = max(stats["durability"], 0)
	_update_ui()
	if stats["durability"] <= 0:
		print("Vehicle Destroyed!")


#func reduce_gas():
	#gas_bar.value = gas_bar["gas"] -1
	#print('ddd')
	#_update_ui()

# Called when player enters a Location Area2D
func on_location_arrived(location: Location) -> void:
	if current_quest != null:
		# Start quest upon arriving ang starting location
		if current_quest.status == Quest.QuestStatus.READY and current_quest.starting_location == location:
			current_quest.status = Quest.QuestStatus.ONGOING
			if current_quest.type == Quest.QuestType.DELIVERY:
				load_sprite.visible = true
			else:
				load_sprite.visible = false
			print("Quest started")

		# End the quest
		elif current_quest.status == Quest.QuestStatus.ONGOING and current_quest.end_location == location:
			current_quest.status = Quest.QuestStatus.FINISHED
			load_sprite.visible = false
			quest_completed.emit()
			stats["points"] += 500
			points_label.text = "Points: " + str(stats["points"])
			print("Quest Completed!")
			
			# Generate new quest
			current_quest = quest_manager.generate_new_quest(location)
			current_quest.changed.connect(_on_current_quest_changed)

# Emit signal to update quest UI
func _on_current_quest_changed():
	quest_changed.emit(current_quest)

# -----------------------
# Functions for player stat increase 
func increase_max_speed(amount: float):
	max_speed += amount
	reverse_speed += amount

func recover_gas(percentage: float):
	reduce_gas = max(reduce_gas - stats["gas"] * percentage, 0)

func increase_gas_capacity(amount: float):
	stats["gas"] += amount
	gas_bar.max_value += amount

func increase_durability(amount: float):
	stats["durability"] += amount
	durability_bar.max_value += amount

func recover_durability():
	stats["durability"] = durability_bar.max_value

# -----------------------


func player():
	pass


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.has_method("slime"):
		enemy_in_range = false
	if body.has_method("skeleton"):
		skeleton_in_range = false
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("slime") :
		enemy_in_range = true
	if body.has_method("skeleton"):
		skeleton_in_range = true

func slime_attack():
	if enemy_in_range:
		damage_taken_slime += 1
		#print(damage_taken_slime)
		
func skeleton_attack():
	if skeleton_in_range:
		damage_taken_skeleton += 1
		#print(damage_taken_skeleton)


func _on_bumper_body_entered(body: Node2D) -> void:
	if body.has_method("slime") :
		enemy_in_range = true
		
		body.queue_free()
		enemy_in_range = false
	if body.has_method("skeleton") :
		skeleton_in_range = true
		body.queue_free()
		skeleton_in_range = false
