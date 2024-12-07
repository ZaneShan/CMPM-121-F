class_name ScenarioParser

static func parse_scenario(file_path: String) -> Dictionary:
	var scenario = {}
	
	# Use FileAccess for reading files in Godot 4.x
	var file = FileAccess.open(file_path, FileAccess.ModeFlags.READ)
	
	if file == null:
		return {}  # Return empty dictionary if the file can't be opened
	
	var content = file.get_as_text().strip_edges()
	var json = JSON.new()  # Create an instance of JSON
	var parsed_data = json.parse(content)  # Use the instance to parse the content
	file.close()  # Always close the file
	
	if parsed_data != OK:
		return {}  # Return empty dictionary if parsing fails
	
	# Extracting relevant data
	var data = json.get_data()  # This retrieves the parsed data as a Dictionary
	scenario["grid_size"] = data.get("grid_size", 10)  # Use the parsed data
	scenario["sun_range"] = data.get("sun_range", {"min": 1, "max": 10})
	scenario["water_range"] = data.get("water_range", {"min": 1, "max": 10})
	
	# Load the win_condition if it exists in the scenario data
	if data.has("win_condition"):
		scenario["win_condition"] = data["win_condition"]
	
	return scenario
