class_name Quest
extends Resource

enum QuestType {DELIVERY, PASSENGER}

@export var name: String
@export var type: QuestType
@export var location: Location
@export var time_limit: float

func _init(
	p_name := "", 
	p_type := QuestType.DELIVERY, 
	p_location := Location.new(), 
	p_time_limit := 10.0,
) -> void:
	name = p_name
	type = p_type
	location = p_location
	time_limit = p_time_limit
