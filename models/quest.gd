class_name Quest
extends Resource

enum QuestType {DELIVERY, PASSENGER}
enum QuestStatus {READY, ONGOING, FINISHED}

@export var name: String
@export var type: QuestType
@export var starting_location: Location
@export var end_location: Location
@export var status: QuestStatus:
	set(new_status):
		status = new_status
		emit_changed()
@export var time_limit: float

func _init(
	p_name := "", 
	p_type := QuestType.DELIVERY, 
	p_sloc := Location.new(), 
	p_eloc := Location.new(), 
	p_time_limit := 10.0,
) -> void:
	name = p_name
	type = p_type
	starting_location = p_sloc
	end_location = p_eloc
	time_limit = p_time_limit
