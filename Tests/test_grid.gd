extends Node2D

# Preload your Plot and Player scenes
@onready var player_scene = preload("res://Player.tscn")

# Grid parameters
const GRID_SIZE = 3
const CELL_SIZE = 64

# Preload the Plot scene (this will be used to access the static functions)
var plot_scene = preload("res://Plot.tscn")

func _ready():
	## Access GridParent node in the scene
	#var parent_node = $GridParent  # Ensure this exists in the scene
#
	## Create the grid using the static function from Plot.gd
	#var grid = Plot.create_grid(GRID_SIZE, CELL_SIZE, parent_node)
#
	## Test encoding the grid
	#var encoded_grid = Plot.encode_grid(grid, parent_node)  # Pass parent_node to encode function
	#
	#print("Encoded Grid:", encoded_grid)
	#
	## Test decoding the grid back to its original form
	#var decoded_grid = Plot.decode_grid(encoded_grid, parent_node)  # Pass parent_node to decode function
#
	## Optionally, print the results for verification
	#print("Decoded Grid:", decoded_grid)
	test_encoder_decoder()
# Test function
func test_encoder_decoder():
	# Create a grid and parent node
	var parent_node = $GridParent  # Add a Node2D in your scene and name it "GridParent"
	var test_grid = Plot.create_grid(GRID_SIZE, CELL_SIZE, parent_node)  # Create the grid using static method

	# Populate the test grid with sample data
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			var plot = test_grid[x][y]
			plot.sun_level = x * 10.0 + y
			plot.water_level = 20.0 - (x + y)

			# Assign the player to a specific plot
			if plot == test_grid[0][0]:
				plot.player = player_scene.instantiate()  # Instantiate the player scene for this plot
			else:
				plot.player = null

			# Generate a plant based on a systematic condition (e.g., modulo)
			if (x + y) % 2 == 0:
				var plant_scene: PackedScene = null
				if (x + y) % 6 == 0:
					plant_scene = preload("res://plants/Lettuce.tscn")  # Lettuce plant scene
				elif (x + y) % 6 == 2:
					plant_scene = preload("res://plants/Carrot.tscn")  # Carrot plant scene
				elif (x + y) % 6 == 4:
					plant_scene = preload("res://plants/Tomato.tscn")  # Tomato plant scene

				if plant_scene:
					var plant = plant_scene.instantiate()
					plant.growth_level = (x + y) % 3
					plant.sun_req = float(x + 1)
					plant.water_req = float(y + 1)
					plot.plant = plant
			else:
				plot.plant = null


	# Encode the grid (Pass parent_node to encode function)
	var encoded_data = Plot.encode_grid(test_grid, parent_node)
	print("Encoded Data: ", encoded_data)

	# Decode the grid (Pass parent_node to decode function)
	var decoded_grid = Plot.decode_grid(encoded_data, parent_node)

	# Compare original and decoded grids
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			var original_plot = test_grid[x][y]
			var decoded_plot = decoded_grid[x][y]

			# Check if sun levels match
			assert(original_plot.sun_level == decoded_plot.sun_level, "Sun levels do not match at ($x, $y)")
			# Check if water levels match
			assert(original_plot.water_level == decoded_plot.water_level, "Water levels do not match at ($x, $y)")
			# Check if player presence matches
			assert((original_plot.player != null) == (decoded_plot.player != null), "Player presence mismatch at ($x, $y)")

			# Check plant data
			if original_plot.plant != null:
				assert(decoded_plot.plant != null, "Plant missing at ($x, $y)")
				assert(original_plot.plant.growth_level == decoded_plot.plant.growth_level, "Growth level mismatch at ($x, $y)")
				assert(original_plot.plant.sun_req == decoded_plot.plant.sun_req, "Sun requirement mismatch at ($x, $y)")
				assert(original_plot.plant.water_req == decoded_plot.plant.water_req, "Water requirement mismatch at ($x, $y)")
			else:
				assert(decoded_plot.plant == null, "Unexpected plant at ($x, $y)")
	print_grid_state(test_grid)
	#print("Test passed!")

# Helper function to print grid state for debugging
func print_grid_state(grid):
	for row in grid:
		for plot in row:
			var plant_info = "None"
			if plot.plant:
				var plant_type = "Unknown"
				if plot.plant.is_lettuce:
					plant_type = "Lettuce"
				elif plot.plant.is_carrot:
					plant_type = "Carrot"
				elif plot.plant.is_tomato:
					plant_type = "Tomato"

				plant_info = "Growth Level: %d, Type: %s" % [plot.plant.growth_level, plant_type]

			print("Plot @ ", plot.coordinates, 
				  " | Sun: ", plot.sun_level, 
				  " | Water: ", plot.water_level, 
				  " | Player: ", plot.player, 
				  " | Plant: ", plant_info)
