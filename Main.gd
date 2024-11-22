extends Node2D

	
var grid_size = 3
var plots = []

func _ready():
	create_grid()

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
