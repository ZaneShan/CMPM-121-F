extends Node2D
class_name Plot
@export var sun_level: float = 0.0  # Current sun energy level in the plot
@export var water_level: float = 10.0  # Current water level in the plot
@export var sun_requirement: float = 5.0  # Sun requirement for plants in this plot
@export var water_requirement: float = 5.0  # Water requirement for plants in this plot
var sun_level_range = Vector2(5, 10)  # Random sun level range for each turn
var water_change_range = Vector2(-2, 2)  # Random water change range for each turn

var plant = null  # Optional plant object (set externally)
var player = null  # Reference to the player on this plot
var coordinates = Vector2()

# Returns true if there is a plant in the plot
func has_plant() -> bool:
	return plant != null

# Gets the plant in the plot
func get_plant():
	return plant

# Sets the plant in the plot
func set_plant(new_plant):
	plant = new_plant
	
func remove_plant():
	plant = null
	
func set_player(new_player):
	player = new_player
	
func remove_player():
	player = null

# Update individual plot
func update_plot(plot):
	# Randomize sun and water levels
	plot.sun_level = randf_range(sun_level_range.x, sun_level_range.y)
	#print("plot.sun_level: ", plot.sun_level)
	plot.water_level += randf_range(water_change_range.x, water_change_range.y)
	#print("plot.water_level: ", plot.water_level)
	
	# Clamp water level to reasonable bounds
	plot.water_level = clamp(plot.water_level, 0, 20)
	
	# Update the plant in the plot, if any
	if plot.has_plant():
		# Ensure plot.plant is a valid instance of Plant
		plot.plant.update_plant(plot.plant, plot)
		#if plot.plant is Plant:
			#plot.plant.update_plant(plot)
		#else:
			#print("No valid plant in the plot!")


# Static method to create the grid
static func create_grid(grid_size: int, cell_size: int, parent: Node2D) -> Array:
	var plots = []
	var plot_scene = preload("res://Plot.tscn")
	
	# Get the size of the viewport
	#var viewport_size = parent.get_viewport_rect().size
	var grid_width = grid_size * cell_size
	var grid_height = grid_size * cell_size
	
	# Get the size of the viewport
	var viewport_size = parent.get_viewport_rect().size
	var start_x = (viewport_size.x - grid_width) / 2
	var start_y = (viewport_size.y - grid_height) / 2
	
	# Create grid matrix
	for x in range(grid_size):
		var row = []
		for y in range(grid_size):
			var plot = plot_scene.instantiate()
			parent.add_child(plot)  # Add plot to the provided parent node
			plot.position = Vector2(start_x + x * cell_size, start_y + y * cell_size)
			plot.coordinates = Vector2(x, y)
			row.append(plot)
		plots.append(row)
	return plots
	
var plots_array = []  # Reference to the parent grid of plots

# Set the plots array explicitly when creating the grid
func set_plots_array(new_plots_array):
	plots_array = new_plots_array

func get_adjacent_plots() -> Array:
	var adjacent_plots = []
	var current_x = coordinates.x
	var current_y = coordinates.y
	
	# Ensure the grid is set and access it directly
	if plots_array.size() == 0:
		return adjacent_plots  # Early exit if grid is not set properly

	var grid_size_x = plots_array.size()  # Number of rows
	var grid_size_y = plots_array[0].size()  # Number of columns (assuming all rows have same number of columns)
	
	# Ensure coordinates are within bounds of the grid
	if current_x > 0:
		adjacent_plots.append(plots_array[current_x - 1][current_y])  # Left
	if current_x < grid_size_x - 1:
		adjacent_plots.append(plots_array[current_x + 1][current_y])  # Right
	if current_y > 0:
		adjacent_plots.append(plots_array[current_x][current_y - 1])  # Up
	if current_y < grid_size_y - 1:
		adjacent_plots.append(plots_array[current_x][current_y + 1])  # Down
	
	return adjacent_plots
