# Player.gd
class_name Player
extends CharacterBody2D

# --- UI References ---
@onready var durability_bar := $CanvasLayer3/VBoxContainer/DurabilityBar
@onready var boost_bar := $CanvasLayer3/VBoxContainer/BoostLabel
@onready var shield_bar := $CanvasLayer3/VBoxContainer/ShieldLabel
@onready var load_sprite: Sprite2D = $"Truck Sprite/Load Sprite"
@onready var gas_bar := $CanvasLayer3/VBoxContainer/Gas
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

# --- Player Stats ---
var stats := {
	"durability": 100.0, # vehicle health
	"boost": 0.0, # speed multiplier
	"shield": 0.0, # damage reduction (0–1)
	"gas": 1500.0
}

# --- Quest ---
var quest_manager: QuestManager
signal quest_changed(quest)
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
	var throttle := Input.get_action_strength("car_forward") - Input.get_action_strength("car_reverse")
	var steering := Input.get_action_strength("car_right") - Input.get_action_strength("car_left")
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
	reduce_gas += gas_reduction
	
	#print(throttle)
	#var reduce :=  100 - throttle
	#print(gas_reduction)S
	# Rotate only if moving
	if velocity.length() > 5:
		rotation += steering * turn_speed * delta

	var forward := Vector2.UP.rotated(rotation)

	# Apply boost multiplier
	var effective_max_speed: float = max_speed * (1.0 + stats["boost"])
	# Accelerate
	if reduce_gas >= 1500.0:
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
	durability_bar.value = stats["durability"]
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
			print("Quest Completed!")
			
			# Generate new quest
			current_quest = quest_manager.generate_new_quest(location)
			current_quest.changed.connect(_on_current_quest_changed)

# Emit signal to update quest UI
func _on_current_quest_changed():
	quest_changed.emit(current_quest)
