extends Area2D
const Plant = preload("res://plants/Plant.gd")

@export var grid_size: int = 5  # Default size of the grid (number of cells per row/column)
@export var cell_size: int = 64  # Size of each grid cell
var plots = []  # Reference to the plot grid

var current_coordinates = Vector2(0, 0)  # Current grid position (x, y)
var target_position: Vector2  # The target position in world coordinates

func _ready():
	# Initialize the player's position to the center of the first plot
	var initial_plot = plots[current_coordinates.x][current_coordinates.y]
	target_position = initial_plot.position
	global_position = global_position
	print("player coordinates: ", current_coordinates, " | Position: ", target_position)
	initial_plot.set_player(self)

func _physics_process(delta):
	# Smoothly move the player towards the target position
	position = position.move_toward(target_position, cell_size * 5 * delta)  # Adjust speed scaling as needed

func _input(event):
	# Handle arrow key input for movement
	if event.is_action_pressed("ui_up"):
		move(Vector2(0, -1))
	elif event.is_action_pressed("ui_down"):
		move(Vector2(0, 1))
	elif event.is_action_pressed("ui_left"):
		move(Vector2(-1, 0))
	elif event.is_action_pressed("ui_right"):
		move(Vector2(1, 0))
	elif event.is_action_pressed("ui_accept"):
		var plant = Plant.new(get_coords)
		plant.seed_plant()

func move(direction: Vector2):
	# Calculate new grid coordinates
	var new_coordinates = current_coordinates + direction

	# Ensure the player doesn't move off the grid
	if new_coordinates.x >= 0 and new_coordinates.x < grid_size and new_coordinates.y >= 0 and new_coordinates.y < grid_size:
		# Remove the player from the current plot
		var current_plot = plots[current_coordinates.x][current_coordinates.y]
		current_plot.remove_player()

		# Update player's grid coordinates
		current_coordinates = new_coordinates
		var new_plot = plots[current_coordinates.x][current_coordinates.y]
		new_plot.set_player(self)

		# Update the target position based on the new plot's position
		target_position = new_plot.position
		
func get_coords():
	return current_coordinates
