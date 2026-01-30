extends Resource
class_name QuestManager

const locations_directory := "res://data/locations/"

var locations: Array[Location] = []

func _init() -> void:
	# Load quest locations
	for loc in ResourceLoader.list_directory(locations_directory):
		locations.append(load(locations_directory.path_join(loc)))

func generate_new_quest(prev_loc: Location) -> Quest:
	var quest_type = Quest.QuestType.values().pick_random()
	var start_loc: Location
	var end_loc: Location
	var randomized: Array[Location] = locations.duplicate()
	while true:
		randomized.shuffle()
		start_loc = randomized[0]
		end_loc = randomized[1]
		if start_loc != prev_loc:
			break
	print("\nNew quest: ", Quest.QuestType.keys()[quest_type])
	print(start_loc.name, " -> ", end_loc.name, "\n")
	return Quest.new(
		"New Quest",
		quest_type,
		start_loc,
		end_loc,
		30.0
	)
