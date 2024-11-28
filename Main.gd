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
	level_complete_label.position = plotsArray[0][0].global_position#Vector2(viewport_size.x/2, viewport_size.y/2)
	# Assign the plotsArray to each plot
	for row in plotsArray:
		for plot in row:
			plot.set_plots_array(plotsArray)  # Set the grid reference in each plot
	
	print(plotsArray[0][0].get_adjacent_plots())  # This will print the adjacent plots for the top-left plot

	# Connect the turn button
	var button = $TurnButton
	button.connect("pressed", Callable(self, "_on_turn_complete"))

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
