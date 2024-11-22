extends Area2D

# Player movement speed (adjust for grid size)
var speed = 64  # Size of one grid cell
# MAGIC NUMBER, CHANGE TO CELL SIZE VAR
var target_position: Vector2  # The target position the player moves to

func _ready():
	# Initialize the player's position
	target_position = position

func _physics_process(delta):
	# Smoothly move the player towards the target position
	position = position.move_toward(target_position, speed * delta)

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

func move(direction: Vector2):
	# Calculate new target position based on the direction
	var new_position = target_position + direction * speed

	# Ensure the player doesn't move off the grid
	var grid_width = 5  # Update with the actual grid size
	var grid_height = 5
	var cell_size = 64
	if new_position.x >= 0 and new_position.x < grid_width * cell_size and new_position.y >= 0 and new_position.y < grid_height * cell_size:
		target_position = new_position
