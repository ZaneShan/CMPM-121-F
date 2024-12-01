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
	var file = FileAccess.open("user://grid_save.dat", FileAccess.WRITE)
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

func load():
	var file = FileAccess.open("user://grid_save.dat", FileAccess.READ)
	if file == null:
		print("Failed to open file for loading!")
		return

	# Load the encoded grid data
	var grid_size = file.get_32()
	var encoded_data = file.get_buffer(grid_size)
	plot_scene.clear_grid(self, plotsArray)
	plotsArray = Plot.decode_grid(encoded_data, self)

	# Load the undo stack
	undo_stack.clear()
	var undo_stack_size = file.get_32()
	print("Undo stack size: ", undo_stack_size)
	for i in range(undo_stack_size):
		var state_size = file.get_32()
		var state = file.get_buffer(state_size)
		undo_stack.append(state)

	# Load the redo stack
	redo_stack.clear()
	var redo_stack_size = file.get_32()
	print("Redo stack size: ", redo_stack_size)
	for i in range(redo_stack_size):
		var state_size = file.get_32()
		var state = file.get_buffer(state_size)
		redo_stack.append(state)

	file.close()
	print("Grid data and stacks loaded successfully!")

	
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
