extends Node2D

	
var grid_size = 3
var plotsArray = []
var sun_level_range = Vector2(5, 10)  # Random sun level range for each turn
var water_change_range = Vector2(-2, 2)  # Random water change range for each turn

const Plot = preload("res://Plot.gd")  # Load the Plot script

func _ready():
	# Use the static method from Plot to create the grid
	var cell_size = 64
	plotsArray = Plot.create_grid(grid_size, cell_size, self)

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
	for row in plotsArray:
		for plot in row:
			if plot.has_plant() and plot.get_plant().is_fully_grown():
				grown_plants += 1

	# Check against your win condition
	if grown_plants >= 5:  # Example win condition
		print("Level Complete!")

func plant_seed(plant_type: String):
	var plant_scene
	if plant_type == "Carrot":
		plant_scene = preload("res://plants/Carrot.tscn")
	elif plant_type == "Tomato":
		plant_scene = preload("res://plants/Tomato.tscn")
	elif plant_type == "Lettuce":
		plant_scene = preload("res://plants/Lettuce.tscn")
	else:
		print("Unknown plant type")
		return

	var plant = plant_scene.instantiate()  # Create an instance of the plant
	var current_plot = get_plot_under_player()  # Get the plot under the player
	if current_plot and not current_plot.has_plant():
		current_plot.set_plant(plant)  # Set the plant in the plot
		add_child(plant)  # Add the plant to the scene
		plant.position = current_plot.position  # Position the plant in the plot
		print("Planted a ", plant_type)

func get_plot_under_player():
	return 
