extends Node2D
class_name Plot
@export var sun_level: float = 0.0  # Current sun energy level in the plot
@export var water_level: float = 10.0  # Current water level in the plot
var sun_level_range = Vector2(5, 10)  # Default sun level range, will be overwritten
var water_change_range = Vector2(-2, 2)  # Default water change range, will be overwritten

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
	plot.water_level += randf_range(water_change_range.x, water_change_range.y)
	
	# Clamp water level to reasonable bounds
	plot.water_level = clamp(plot.water_level, 0, 20)
	
	# Update the plant in the plot, if any
	if plot.has_plant():
		plot.plant.update_plant(plot.plant, plot)

# Static method to create the grid
static func create_grid(grid_size: int, cell_size: int, parent: Node2D, sun_range: Dictionary, water_range: Dictionary) -> Array:
	var plots = []
	var plot_scene = preload("res://Plot.tscn")
	if !sun_range.has("min") or !sun_range.has("max"):
		print("Error: sun_range does not contain 'min' or 'max'")
	if !water_range.has("min") or !water_range.has("max"):
		print("Error: water_range does not contain 'min' or 'max'")



	# Dynamically set the sun and water ranges from the DSL
	#var sun_level_range = Vector2(sun_range["min"], sun_range["max"])
	#var water_change_range = Vector2(water_range["min"], water_range["max"])
	
	# Get the size of the viewport
	var grid_width = grid_size * cell_size
	var grid_height = grid_size * cell_size
	
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

# Static function to load the DSL and set up the grid
static func load_dsl_and_create_grid(dsl: Dictionary, parent: Node2D) -> Array:
	# Extract sun and water ranges from the DSL
	var sun_range = dsl["scenario"]["sun_range"]
	var water_range = dsl["scenario"]["water_range"]
	
	# Extract grid size and cell size from the DSL
	var grid_size = dsl["scenario"]["grid_size"]
	var cell_size = 64  # You can modify this if needed
	
	# Create the grid based on the DSL
	return create_grid(grid_size, cell_size, parent, sun_range, water_range)

var plots_array = []
# Static method to clear grid
static func clear_grid(parent: Node2D, plots_array: Array):
	for row in plots_array:
		for plot in row:
			plot.queue_free()
	plots_array.clear()

	var player_node = parent.get_node("Player") if parent.has_node("Player") else null
	var player2_node = parent.get_node("Player2") if parent.has_node("Player2") else null
	
	if player_node:
		player_node.queue_free()  # Delete the "Player" node

	if player2_node:
		player2_node.queue_free()  # Delete the "Player2" node
	
	print("Grid cleared and player deleted.")


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
	
	
static func encode_grid(grid: Array, parent_node: Node2D) -> PackedByteArray:
	var byte_array = PackedByteArray()
	
	# Encode the grid size and cell size
	var grid_size = grid.size()  # Assuming square grid (size x size)
	var cell_size = 64
	byte_array.append(grid_size)  # Encode the grid size (as an integer)
	byte_array.append(cell_size)  # Encode the cell size (as an integer)
	var offset = byte_array.size()  # The offset starts after the grid and cell size
	
	# Iterate through the grid and encode the plot data
	for row in grid:
		for plot in row:
			# Encode plot data (sun level, water level, etc.)
			var floatByteArray = PackedByteArray([0,0,0,0])
			floatByteArray.encode_float(0, plot.sun_level)
			byte_array.append_array(floatByteArray)
			floatByteArray.encode_float(0, plot.water_level)
			byte_array.append_array(floatByteArray)
			#print(byte_array)
			
			# Encode player presence
			if plot.player:
				byte_array.append(1)  # Player present (encoded as an integer)
			else:
				byte_array.append(0)  # No player (encoded as an integer)
				
			offset += 1
			
			# Encode plant data
			if plot.plant:
				byte_array.append(1)  # Plant present (encoded as an integer)
				byte_array.append(plot.plant.growth_level)  # Append growth level (integer)
				
				# Encode sun and water requirements as floats
				floatByteArray.encode_float(0, plot.plant.sun_req)
				byte_array.append_array(floatByteArray)
				floatByteArray.encode_float(0, plot.plant.water_req)
				byte_array.append_array(floatByteArray)
				byte_array.append(get_plant_type_flag(plot.plant))  # Append plant type flag (integer)
			else:
				byte_array.append(0)  # No plant (encoded as an integer)

	return byte_array

static func decode_grid(byte_array: PackedByteArray, parent_node: Node2D, sun_range: Dictionary, water_range: Dictionary) -> Array:
	# Step 1: Read grid size and cell size from byte array
	var grid_size = byte_array[0]  # The first byte contains the grid size
	var cell_size = byte_array[1]  # The second byte contains the cell size
	var grid = create_grid(grid_size, cell_size, parent_node, sun_range, water_range)  # Pass sun_range and water_range


	# Step 2: Decode the encoded grid data
	var offset = 2  # Start reading after the grid size and cell size bytes
	var player_found = false  # Ensure only one player is placed
	var player_x = 0
	var player_y = 0

	for x in range(grid_size):
		for y in range(grid_size):
			var plot = grid[x][y]
			
			# Decode plot data
			plot.sun_level = bytes_to_float(byte_array, offset)
			offset += 4
			plot.water_level = bytes_to_float(byte_array, offset)
			offset += 4

			# Decode player presence
			var player_flag = byte_array[offset]
			offset += 1
			if player_flag == 1:
				if player_found:
					print("Warning: Multiple plots have a player! Fixing data...")
					plot.player = null  # Reset the extra player flags
				else:
					var player = preload("res://Player.tscn").instantiate()
					plot.player = Player.new()  # Assign player instance
					player_found = true
					print("PLAYER FOUND")
					player_x = x
					player_y = y
			else:
				plot.player = null

			# Decode plant presence
			var plant_flag = byte_array[offset]
			offset += 1
			if plant_flag == 1:
				# Decode plant type
				var growth_level = byte_array[offset]
				offset += 1
				var sun_req = bytes_to_float(byte_array, offset)
				offset += 4
				var water_req = bytes_to_float(byte_array, offset)
				offset += 4
				var plant_type_flag = byte_array[offset]
				offset += 1

				# Instantiate the appropriate plant type based on the flag
				var plant: Node2D
				if plant_type_flag & 1:  # Lettuce
					plant = preload("res://plants/Lettuce.tscn").instantiate()
				elif plant_type_flag & 2:  # Carrot
					plant = preload("res://plants/Carrot.tscn").instantiate()
				elif plant_type_flag & 4:  # Tomato
					plant = preload("res://plants/Tomato.tscn").instantiate()
				else:
					print("Error: Unknown plant type flag:", plant_type_flag)
					continue  # Skip to next plot if unknown flag

				# Set common plant properties
				plant.growth_level = growth_level
				plant.sun_req = sun_req
				plant.water_req = water_req

				# Assign the plant to the plot
				# Assign the plant to the plot
				plot.plant = plant
				plot.add_child(plant)  # Add the plant to the plot, making it its parent
				plant.global_position = plot.global_position  # Position the plant

			else:
				plot.plant = null

	# Step 3: Error handling for missing player
	if not player_found:
		print("Error: No player found in the grid!")

	#place player
	if (player_found):
		var player = preload("res://Player.tscn").instantiate()
		player.plots = grid
		player.grid_size = grid_size
		player.moveTo(player_x, player_y)
		parent_node.add_child(player)
		player.name = "Player"
	
	return grid


static func bytes_to_float(byte_array: PackedByteArray, offset: int) -> float:
	# Extract the 4-byte slice from the PackedByteArray
	var slice = byte_array.slice(offset, offset + 4)
	
	# Create a Buffer from the slice to interpret it as a float
	var buffer = PackedByteArray(slice)
	return buffer.decode_float(0)  # Interpret the 4 bytes as a float32



static func bytes_to_int(byte_array: PackedByteArray, offset: int) -> int:
	# Extract the 4-byte slice from the PackedByteArray
	var slice = byte_array.slice(offset, offset + 4)
	
	# Create a Buffer from the slice to interpret it as an integer
	var buffer = PackedByteArray(slice)
	return buffer.decode_s32(0)  # Interpret the 4 bytes as an int32

static func get_plant_type_flag(plant: Plant) -> int:
	if plant.is_lettuce:
		return 1
	elif plant.is_carrot:
		return 2
	elif plant.is_tomato:
		return 4
	return 0

static func set_plant_type_from_flag(plant: Plant, flag: int) -> void:
	plant.is_lettuce = (flag & 1) != 0
	plant.is_carrot = (flag & 2) != 0
	plant.is_tomato = (flag & 4) != 0
