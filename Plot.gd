extends Node2D

@export var sun_level: float = 0.0  # Current sun energy level in the plot
@export var water_level: float = 10.0  # Current water level in the plot
@export var sun_requirement: float = 5.0  # Sun requirement for plants in this plot
@export var water_requirement: float = 5.0  # Water requirement for plants in this plot

var plant = null  # Optional plant object (set externally)
var coordinates = Vector2()


# Returns true if there is a plant in the plot
func has_plant() -> bool:
	return plant != null

# Gets the plant in the plot
func get_plant():
	return plant

# Sets the plant in the plot
func set_plant(Plant):
	plant = Plant
	return

# Static method to create the grid
static func create_grid(grid_size: int, cell_size: int, parent: Node2D) -> Array:
	var plots = []
	var plot_scene = preload("res://Plot.tscn")
	
	# Get the size of the viewport
	var viewport_size = parent.get_viewport_rect().size
	var grid_width = grid_size * cell_size
	var grid_height = grid_size * cell_size
	
	# Calculate the top-left position to center the grid
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
