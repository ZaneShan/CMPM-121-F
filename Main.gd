extends Node2D

var grid_size = 3
var plotsArray = []

const plot_scene = preload("res://Plot.gd")  # Load the Plot script
var player = null
# Undo and Redo stacks to store encoded grid states
var undo_stack = []
var redo_stack = []

var sun_range = {}  # Default range
var water_range = {}  # Default range

var parser : ScenarioParser  # Declare a reference to the parser

var roundCount = 0

func _ready():
	# Load the external DSL using the ScenarioParser
	var scenario_data = ScenarioParser.parse_scenario("res://config.json")
	print("Parsed scenario data: ", scenario_data)

	# Check if parsing was successful and set the values
	if scenario_data.size() > 0:
		grid_size = scenario_data.get("grid_size", 10)
		sun_range = scenario_data.get("sun_range", {"min": 1, "max": 10})
		water_range = scenario_data.get("water_range", {"min": 1, "max": 10})
		
			# Load win condition
		if scenario_data.has("win_condition"):
			load_win_condition(scenario_data)
			print("Win condition:", scenario_data["win_condition"])
	
	# Use the static method from Plot to create the grid
		print("Sun range: ", sun_range)
		print("Water range: ", water_range)

	var cell_size = 64
	plotsArray = plot_scene.create_grid(grid_size, cell_size, self, sun_range, water_range)
	
	var level_complete_label = $LevelCompleteLabel
	level_complete_label.visible = false
	
	var viewport_size = get_viewport_rect().size
	level_complete_label.position = plotsArray[0][0].global_position
	
	# Assign the plotsArray to each plot
	for row in plotsArray:
		for plot in row:
			plot.set_plots_array(plotsArray)  # Set the grid reference in each plot

	# Connect the turn button
	var turn_button = $TurnButton
	turn_button.connect("pressed", Callable(self, "_on_turn_complete"))
	
	var save_button = $SaveButton
	save_button.connect("pressed", Callable(self, "save").bind("save1"))
	
	var save_button2 = $SaveButton2
	save_button2.connect("pressed", Callable(self, "save").bind("save2"))
	
	var save_button3 = $SaveButton3
	save_button3.connect("pressed", Callable(self, "save").bind("save3"))
	
	var load_button = $LoadButton
	load_button.connect("pressed", Callable(self, "load").bind("save1"))
	
	var load_button2 = $LoadButton2
	load_button2.connect("pressed", Callable(self, "load").bind("save2"))
	
	var load_button3 = $LoadButton3
	load_button3.connect("pressed", Callable(self, "load").bind("save3"))
	
	var undo_button = $UndoButton
	undo_button.connect("pressed", Callable(self, "undo"))
	
	var redo_button = $RedoButton
	redo_button.connect("pressed", Callable(self, "redo"))
	
	var autosave_button = $AutosaveButton
	autosave_button.connect("pressed", Callable(self, "loadAutosave"))
	
	var autosaveClose_button = $AutosaveCloseButton
	autosaveClose_button.connect("pressed", Callable(self, "hideAutosavePrompt"))
	
	var italian_button = $ItalianButton
	italian_button.connect("pressed", Callable(self, "change_language").bind("it"))
	
	var spanish_button = $SpanishButton
	spanish_button.connect("pressed", Callable(self, "change_language").bind("es"))
	
	var french_button = $FrenchButton
	french_button.connect("pressed", Callable(self, "change_language").bind("fr"))
	
	var english_button = $EnglishButton
	english_button.connect("pressed", Callable(self, "change_language").bind("en"))
	
	# Set the default language
	change_language("en")

	# Add the player
	player = preload("res://Player.tscn").instantiate()
	player.plots = plotsArray
	player.grid_size = grid_size
	add_child(player)

	# Set the player's starting position to the top-left corner of the plots
	if grid_size > 0:
		player.position = plotsArray[0][0].position  # Position matches the top-left plot
	
	encode_current_grid() # Save start of the game to undo stack


func showAutosavePrompt():
	var autosaveLabel = $AutosaveLabel
	var autosaveButton = $AutosaveButton
	var autosaveCloseButton = $AutosaveCloseButton
	autosaveLabel.visible = true
	autosaveButton.visible = true
	autosaveCloseButton.visible = true
	
func hideAutosavePrompt():
	var autosaveLabel = $AutosaveLabel
	var autosaveButton = $AutosaveButton
	var autosaveCloseButton = $AutosaveCloseButton
	autosaveLabel.visible = false
	autosaveButton.visible = false
	autosaveCloseButton.visible = false

# Turn update button callback
func _on_turn_complete():
	roundCount += 1
	for row in plotsArray:
		for plot in row:
			#print("Plot coordinates: ", plot.coordinates, " | Position: ", plot.position, " | Plant: ", plot.plant)
			plot.update_plot(plot)
	encode_current_grid()
	check_win_condition()
	autosave()
	hideAutosavePrompt()

	
func checkAutosave():
	var file = FileAccess.open("user://grid_autosave.dat", FileAccess.READ)
	if file == null:
		print("No autosave file found")
		return
	file.close()  # Close the file after checking

	showAutosavePrompt()

func autosave():
	var file = FileAccess.open("user://grid_autosave.dat", FileAccess.WRITE)
	if file == null:
		print("Failed to open file for saving!")
		return

	# Save the encoded grid data
	var encoded_data = Plot.encode_grid(plotsArray, self)
	file.store_32(encoded_data.size())
	file.store_buffer(encoded_data)
	
	# Save the undo stack
	file.store_32(undo_stack.size())
	for state in undo_stack:
		file.store_32(state.size())
		file.store_buffer(state)

	# Save the redo stack
	file.store_32(redo_stack.size())
	for state in redo_stack:
		file.store_32(state.size())
		file.store_buffer(state)

	file.close()
	print("Grid data and stacks saved successfully!")

func loadAutosave():
	hideAutosavePrompt()
	var file = FileAccess.open("user://grid_autosave.dat", FileAccess.READ)
	if file == null:
		print("Failed to open file for loading!")
		return

	# Load the encoded grid data
	var grid_size = file.get_32()
	var encoded_data = file.get_buffer(grid_size)
	plot_scene.clear_grid(self, plotsArray)
	plotsArray = Plot.decode_grid(encoded_data, self, sun_range, water_range)

	# Load the undo stack
	undo_stack.clear()
	var undo_stack_size = file.get_32()
	#print("Undo stack size: ", undo_stack_size)
	for i in range(undo_stack_size):
		var state_size = file.get_32()
		var state = file.get_buffer(state_size)
		undo_stack.append(state)

	# Load the redo stack
	redo_stack.clear()
	var redo_stack_size = file.get_32()
	#print("Redo stack size: ", redo_stack_size)
	for i in range(redo_stack_size):
		var state_size = file.get_32()
		var state = file.get_buffer(state_size)
		redo_stack.append(state)

	file.close()
	print("Grid data and stacks loaded successfully!")
	check_win_condition()
	
	
func save(fileName: String):
	var file = FileAccess.open("user://grid_" + fileName + ".dat", FileAccess.WRITE)
	if file == null:
		print("Failed to open file for saving!")
		return

	# Save the encoded grid data
	var encoded_data = Plot.encode_grid(plotsArray, self)
	file.store_32(encoded_data.size())
	file.store_buffer(encoded_data)
	
	# Save the undo stack
	file.store_32(undo_stack.size())
	for state in undo_stack:
		file.store_32(state.size())
		file.store_buffer(state)

	# Save the redo stack
	file.store_32(redo_stack.size())
	for state in redo_stack:
		file.store_32(state.size())
		file.store_buffer(state)

	file.close()
	print("Grid data and stacks saved successfully!")

func load(fileName: String):
	var file = FileAccess.open("user://grid_" + fileName + ".dat", FileAccess.READ)
	if file == null:
		print("Failed to open file for loading!")
		return

	# Load the encoded grid data
	var grid_size = file.get_32()
	var encoded_data = file.get_buffer(grid_size)
	plot_scene.clear_grid(self, plotsArray)
	plotsArray = Plot.decode_grid(encoded_data, self, sun_range, water_range)

	# Load the undo stack
	undo_stack.clear()
	var undo_stack_size = file.get_32()
	#print("Undo stack size: ", undo_stack_size)
	for i in range(undo_stack_size):
		var state_size = file.get_32()
		var state = file.get_buffer(state_size)
		undo_stack.append(state)

	# Load the redo stack
	redo_stack.clear()
	var redo_stack_size = file.get_32()
	#print("Redo stack size: ", redo_stack_size)
	for i in range(redo_stack_size):
		var state_size = file.get_32()
		var state = file.get_buffer(state_size)
		redo_stack.append(state)

	file.close()
	print("Grid data and stacks loaded successfully!")
	check_win_condition()

	
# Undo the last action
func undo():
	if undo_stack.size() > 0:
		# Pop the most recent state from the undo stack
		var last_state = undo_stack.pop_back()
		
		# Decode the grid from the packed byte array
		plot_scene.clear_grid(self, plotsArray)
		plotsArray = Plot.decode_grid(last_state, self, sun_range, water_range)
		
		# Push the state to the redo stack for possible redo later
		redo_stack.append(last_state)
		check_win_condition()

		print("Undo: Grid restored to previous state.")
	else:
		print("No more actions to undo.")
		
# Redo the last undone action
func redo():
	if redo_stack.size() > 0:
		# Pop the most recent state from the redo stack
		var redo_state = redo_stack.pop_back()
		
		# Decode the grid from the packed byte array
		plot_scene.clear_grid(self, plotsArray)
		plotsArray = Plot.decode_grid(redo_state, self, sun_range, water_range)
		
		# Push the state back to the undo stack
		undo_stack.append(redo_state)
		check_win_condition()
		
		print("Redo: Grid restored to the next state.")
	else:
		print("No more actions to redo.")
	
func encode_current_grid():
	# This assumes you have the encode_grid method from before
	var encoded_data = Plot.encode_grid(plotsArray, self)
	undo_stack.append(encoded_data)
	redo_stack.clear()  # Clear redo stack when new action happens
	print("Current grid state encoded and pushed to undo stack")
	#print(undo_stack)

# Check if level is complete
func count_fully_grown_plants():
	var grown_plants = 0
	for row in plotsArray:
		for plot in row:
			if plot.has_plant() and plot.get_plant().is_fully_grown():
				grown_plants += 1
	var level_complete_label = $LevelCompleteLabel
	return grown_plants

enum WinConditionType { COLLECT_RESOURCES, SURVIVE_ROUNDS, REACH_GROWTH_TARGET }

var win_condition_type: WinConditionType
var win_condition_goal = {}

func load_win_condition(data):
	if data.has("win_condition"):
		var condition = data["win_condition"]
		match condition["type"]:
			"collect_resources":
				win_condition_type = WinConditionType.COLLECT_RESOURCES
				win_condition_goal = condition["goal"]
				if win_condition_goal.has("plants"):
					# Parse plant goals into a dictionary
					win_condition_goal["plants"] = condition["goal"]["plants"]
			"survive_rounds":
				win_condition_type = WinConditionType.SURVIVE_ROUNDS
				win_condition_goal = condition["rounds"]
			"reach_growth_target":
				win_condition_type = WinConditionType.REACH_GROWTH_TARGET
				win_condition_goal = condition["goal"]
				if win_condition_goal.has("plants"):
					# Parse plant goals into a dictionary
					win_condition_goal["plants"] = condition["goal"]["plants"]


func check_win_condition():
	match win_condition_type:
		WinConditionType.COLLECT_RESOURCES:
			print("win condition collect resources")
			# Check if the player has harvested enough plants
			if win_condition_goal.has("plants"):
				print("win condition plant length: ", win_condition_goal["plants"].size())
				for plant_type_str in win_condition_goal["plants"].keys():
					# Convert the string keys to integers
					var plant_type_enum = int(plant_type_str)
					var required_amount = win_condition_goal["plants"][plant_type_str]
					
					# Debug print for plant_type_enum to ensure it matches
					print("Checking plant type: ", plant_type_enum)  # Ensure this matches the harvested plant type enum

					# Get the harvested amount for the enum value (plant_type_enum)
					var harvested_amount = player.harvested_plants.get(plant_type_enum, 0)
					print("required amount: ", required_amount)
					print("harvested amount: ", harvested_amount)

					if harvested_amount < required_amount:
						return false
			level_complete()
			return true
		WinConditionType.SURVIVE_ROUNDS:
			if roundCount >= win_condition_goal:
				level_complete()
				return true
			return false
		WinConditionType.REACH_GROWTH_TARGET:
			if count_fully_grown_plants() >= win_condition_goal["plants"]:
				level_complete()
				return true
			return false

func level_complete():
	print("game won!!!!!!!!!!!!!!!!!!!")
	var level_complete_label = $LevelCompleteLabel
	level_complete_label.visible = true
		
func change_language(language_code: String):
	# Set the current locale
	TranslationServer.set_locale(language_code)
	
	# Update text for all UI elements
	var turn_button = $TurnButton
	turn_button.text = tr("Turn Complete")
	var save_button = $SaveButton
	save_button.text = tr("Save Slot 1")
	var save_button2 = $SaveButton2
	save_button2.text = tr("Save Slot 2")
	var save_button3 = $SaveButton3
	save_button3.text = tr("Save Slot 3")
	var load_button = $LoadButton
	load_button.text = tr("Load Slot 1")
	var load_button2 = $LoadButton2
	load_button2.text = tr("Load Slot 2")
	var load_button3 = $LoadButton3
	load_button3.text = tr("Load Slot 3")
	var undo_button = $UndoButton
	undo_button.text = tr("Undo")
	var redo_button = $RedoButton
	redo_button.text = tr("Redo")
	var autosave_button = $AutosaveButton
	autosave_button.text = tr("Load Autosave")
	var autosave_close_button = $AutosaveCloseButton
	autosave_close_button.text = tr("Close")
	var autosave_label = $AutosaveLabel
	autosave_label.text = tr("Autosave detected. Would you like to load it?")
	var level_complete_label = $LevelCompleteLabel
	level_complete_label.text = tr("Level Complete!")
	var italian_button = $ItalianButton
	italian_button.text = tr("Italian")
	var spanish_button = $SpanishButton
	spanish_button.text = tr("Spanish")
	var french_button = $FrenchButton
	french_button.text = tr("French")
	var english_button = $EnglishButton
	english_button.text = tr("English")
	print("Language changed to: ", language_code)
