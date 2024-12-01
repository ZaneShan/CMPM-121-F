extends Node2D

var grid_size = 3
var plotsArray = []

const plot_scene = preload("res://Plot.gd")  # Load the Plot script

# Undo and Redo stacks to store encoded grid states
var undo_stack = []
var redo_stack = []

func _ready():
	# Use the static method from Plot to create the grid
	var cell_size = 64
	plotsArray = plot_scene.create_grid(grid_size, cell_size, self)
	
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
	save_button.connect("pressed", Callable(self, "save"))
	
	var load_button = $LoadButton
	load_button.connect("pressed", Callable(self, "load"))
	
	var undo_button = $UndoButton
	undo_button.connect("pressed", Callable(self, "undo"))
	
	var redo_button = $RedoButton
	redo_button.connect("pressed", Callable(self, "redo"))

	# Add the player
	var player = preload("res://Player.tscn").instantiate()
	player.plots = plotsArray
	player.grid_size = grid_size
	add_child(player)

	# Set the player's starting position to the top-left corner of the plots
	if grid_size > 0:
		player.position = plotsArray[0][0].position  # Position matches the top-left plot

# Turn update button callback
# Turn update button callback
func _on_turn_complete():
	encode_current_grid()
	for row in plotsArray:
		for plot in row:
			#print("Plot coordinates: ", plot.coordinates, " | Position: ", plot.position, " | Plant: ", plot.plant)
			plot.update_plot(plot)
	check_level_complete()
	
func save():
	# Get the encoded grid data (PackedByteArray)
	var encoded_data = Plot.encode_grid(plotsArray, self)

	var file = FileAccess.open("user://grid_save.dat", FileAccess.WRITE)
	if file == null:
		print("Failed to open file for saving!")
		return

	# Write the packed byte array (TBS) to the file
	file.store_buffer(encoded_data)

	# Close the file after writing
	file.close()

	print("Grid data saved successfully!")
	
func load():
	# Create a File object
	var file = FileAccess.open("user://grid_save.dat", FileAccess.READ)

	# Open the file for reading (use the same path as in save function)
	if file == null:
		print("Failed to open file for loading!")
		return

	# Read the packed byte array from the file
	var byte_array = file.get_buffer(file.get_length())

	# Close the file after reading
	file.close()

	plot_scene.clear_grid(self, plotsArray)
	# Decode the grid data from the byte array
	var plotsArray = Plot.decode_grid(byte_array, self)

	# Assign the decoded grid to your variable or use it as needed
	print("Grid data loaded successfully!")
	
# Undo the last action
func undo():
	if undo_stack.size() > 0:
		# Pop the most recent state from the undo stack
		var last_state = undo_stack.pop_back()
		
		# Decode the grid from the packed byte array
		plot_scene.clear_grid(self, plotsArray)
		plotsArray = Plot.decode_grid(last_state, self)
		
		# Push the state to the redo stack for possible redo later
		redo_stack.append(last_state)

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
		plotsArray = Plot.decode_grid(redo_state, self)
		
		# Push the state back to the undo stack
		undo_stack.append(redo_state)

		print("Redo: Grid restored to the next state.")
	else:
		print("No more actions to redo.")
	
func encode_current_grid():
	# This assumes you have the encode_grid method from before
	var encoded_data = Plot.encode_grid(plotsArray, self)
	undo_stack.append(encoded_data)
	redo_stack.clear()  # Clear redo stack when new action happens
	print("Current grid state encoded and pushed to undo stack")
	print(undo_stack)

# Check if level is complete
func check_level_complete():
	var grown_plants = 0
	for row in plotsArray:
		for plot in row:
			if plot.has_plant() and plot.get_plant().is_fully_grown():
				grown_plants += 1

	# Check against your win condition
	if grown_plants >= 5:  # Example win condition
		print("Level Complete!")
		var level_complete_label = $LevelCompleteLabel
		level_complete_label.visible = true
