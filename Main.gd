extends Node2D

var grid_size = 3
var plotsArray = []

const plot_scene = preload("res://Plot.gd")  # Load the Plot script

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

	# Decode the grid data from the byte array
	var decoded_grid = Plot.decode_grid(byte_array, self)

	# Assign the decoded grid to your variable or use it as needed
	print("Grid data loaded successfully!")

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
