extends Node2D

	
var grid_size = 3
var plots = []
var sun_level_range = Vector2(5, 10)  # Random sun level range for each turn
var water_change_range = Vector2(-2, 2)  # Random water change range for each turn


func _ready():
	create_grid()
	var button = $TurnButton
	button.connect("pressed", Callable(self, "_on_turn_complete"))


	# Add the player
	var player = preload("res://Player.tscn").instantiate()
	add_child(player)

	# Set the player's starting position to the top-left corner of the plots
	if grid_size > 0:
		player.position = plots[0][0].position  # Position matches the top-left plot

# Create grid matrix
func create_grid():
	var plot_scene = preload("res://Plot.tscn")
	var cell_size = 64  # Adjust to match the size of your plot sprites
	var grid_width = grid_size * cell_size
	var grid_height = grid_size * cell_size

	# Get the size of the viewport
	var viewport_size = get_viewport_rect().size

	# Calculate the top-left position to center the grid
	var start_x = (viewport_size.x - grid_width) / 2
	var start_y = (viewport_size.y - grid_height) / 2

	for x in range(grid_size):
		var row = []
		for y in range(grid_size):
			var plot = plot_scene.instantiate()
			add_child(plot)
			plot.position = Vector2(start_x + x * cell_size, start_y + y * cell_size)
			row.append(plot)
		plots.append(row)

# Turn update button callback
# Turn update button callback
func _on_turn_complete():
	for row in plots:
		for plot in row:
			update_plot(plot)
	check_level_complete()

# Update individual plot
func update_plot(plot):
	# Randomize sun and water levels
	plot.sun_level = randf_range(sun_level_range.x, sun_level_range.y)
	print("plot.sun_level: ", plot.sun_level)
	plot.water_level += randf_range(water_change_range.x, water_change_range.y)
	print("plot.water_lvel: ", plot.water_level)
	# Clamp water level to reasonable bounds
	plot.water_level = clamp(plot.water_level, 0, 20)
	
	# Update the plant in the plot, if any
	if plot.has_plant():
		var plant = plot.get_plant()
		update_plant(plant, plot)

# Update plant logic
func update_plant(plant, plot):
	# Check if plant meets growth requirements
	if plot.sun_level >= plant.sun_requirement and plot.water_level >= plant.water_requirement:
		plant.grow()

# Check if level is complete
func check_level_complete():
	var grown_plants = 0
	for row in plots:
		for plot in row:
			if plot.has_plant() and plot.get_plant().is_fully_grown():
				grown_plants += 1

	# Check against your win condition
	if grown_plants >= 5:  # Example win condition
		print("Level Complete!")
