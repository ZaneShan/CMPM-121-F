extends Node2D
class_name Plant

var growth_level = 0
var max_growth_level = 2
var current_plot = null

# Requirements and conditions can be different for each plant
var growth_conditions = {}  # Conditions that will define how a plant grows
@export var sun_req = 1.0
@export var water_req = 1.0

# Plant type flags
@export var is_lettuce = false
@export var is_carrot = false
@export var is_tomato = false

# References to the plant stage sprites
var plant_stage_1 = null
var plant_stage_2 = null
var plant_stage_3 = null

func _ready():
	# Get references to the child Sprite nodes for each growth stage
	plant_stage_1 = $plant_stage_1
	plant_stage_2 = $plant_stage_2
	plant_stage_3 = $plant_stage_3
	plant_stage_1.visible = true
	plant_stage_2.visible = false
	plant_stage_3.visible = false
	
	# Set the initial visibility
	update_plant_growth()

	# Initialize plant growth conditions based on type
	set_growth_conditions()


# Set the plant's growth conditions based on the type
func set_growth_conditions():
	if is_lettuce:
		growth_conditions = {
			"neighbors": "lettuce",
			"water_range": [2, 4],
			"sun_range": [5, 8]
		}
	elif is_carrot:
		growth_conditions = {
			"neighbors": "none",
			"water_range": [3, 5],
			"sun_range": [4, 7]
		}
	elif is_tomato:
		growth_conditions = {
			"neighbors": "other_types",
			"water_range": [4, 6],
			"sun_range": [6, 9]
		}

# Update the plant growth level
func update_plant(plant, plot):
	if plot.sun_level >= plant.sun_req and plot.water_level >= plant.water_req:
		if growth_level < max_growth_level:
			if grow():
				growth_level += 1
				update_plant_growth()
	print("plant growth level: ", growth_level)

# Check if the plant can grow based on its conditions
func grow() -> bool:
	if growth_conditions.has("neighbors"):
		var neighbors_ok = check_neighbors(growth_conditions["neighbors"])
		if !neighbors_ok:
			return false
	if growth_conditions.has("water_range"):
		if !(current_plot.water_level in growth_conditions["water_range"]):
			return false
	if growth_conditions.has("sun_range"):
		if !(current_plot.sun_level in growth_conditions["sun_range"]):
			return false
	return true

# Check if neighbors are suitable for growth
func check_neighbors(neighbor_condition: String) -> bool:
	if neighbor_condition == "lettuce":
		return CheckIfNear("Lettuce", current_plot)
	elif neighbor_condition == "none":
		return !CheckIfNear("Lettuce", current_plot) && !CheckIfNear("Carrot", current_plot) && !CheckIfNear("Tomato", current_plot)
	elif neighbor_condition == "other_types":
		# Can grow next to anything except its own type
		if CheckIfNear("Lettuce", current_plot) or CheckIfNear("Carrot", current_plot) or CheckIfNear("Tomato", current_plot):
			return false
	return true

# Checks if the plant is fully grown
func is_fully_grown() -> bool:
	return growth_level == max_growth_level

# Update the plant sprite visibility based on growth level
func update_plant_growth():
	plant_stage_1.visible = growth_level == 0
	plant_stage_2.visible = growth_level == 1
	plant_stage_3.visible = growth_level == 2

# Check if the plant is near a plant of a specific type
func CheckIfNear(plant_type: String, currentPlot) -> bool:
	if currentPlot == null:
		print("Error: currentPlot is null!")
		return false
		
	var nearby_plots = currentPlot.get_adjacent_plots()
	
	for plot in nearby_plots:
		if plot.has_plant():
			var plant = plot.get_plant()
			if plant_type == "Carrot" and plant.is_carrot:
				return true
			elif plant_type == "Lettuce" and plant.is_lettuce:
				return true
			elif plant_type == "Tomato" and plant.is_tomato:
				return true
	
	return false
