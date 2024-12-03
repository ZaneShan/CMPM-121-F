extends Node2D
class_name Plant
var growth_level = 0
var max_growth_level = 2
var current_plot = null
@export var sun_req = 1.0
@export var water_req = 1.0

# References to the plant stage sprites
var plant_stage_1 = null
var plant_stage_2 = null
var plant_stage_3 = null

@export var is_lettuce = false
@export var is_carrot = false
@export var is_tomato = false

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
	

func update_plant(plant, plot):
	# Check if plant meets growth requirements
	if plot.sun_level >= plant.sun_req and plot.water_level >= plant.water_req:
		if (growth_level < max_growth_level):
			if (plant.grow() == true):
				growth_level += 1
				update_plant_growth()
	print ("plant growth level: ", plant.growth_level)
	

func grow() -> bool:
	# conditionals dependent on plant type
	if (is_lettuce):
		# lettuce can only grow near other lettuce
		if(!CheckIfNear("Lettuce", current_plot)):
			return false
	if (is_tomato):
		# tomato can only grow when alone, having any plants adjacent prohibits growth
		if(CheckIfNear("Lettuce", current_plot)):
			return false
		if(CheckIfNear("Carrot", current_plot)):
			return false
		if(CheckIfNear("Tomato", current_plot)):
			return false
	if (is_carrot):
		# carrots can only grow near other types other than themselves, or by themselves
		if(CheckIfNear("Carrot", current_plot)):
			return false
	return true

# Checks if the plant is fully grown
func is_fully_grown() -> bool:
	return growth_level == max_growth_level

func update_plant_growth():
	plant_stage_1.visible = growth_level == 0
	plant_stage_2.visible = growth_level == 1
	plant_stage_3.visible = growth_level == 2
	
func CheckIfNear(plant_type: String, currentPlot) -> bool:
	if currentPlot == null:
		print("Error: currentPlot is null!")
		return false
		
	var nearby_plots = currentPlot.get_adjacent_plots()
	
	# Check each adjacent plot for a plant of the given type
	for plot in nearby_plots:
		if plot.has_plant():
			var plant = plot.get_plant()
			
			# Check if the plant type matches
			if plant_type == "Carrot" and plant.is_carrot:
				return true
			elif plant_type == "Lettuce" and plant.is_lettuce:
				return true
			elif plant_type == "Tomato" and plant.is_tomato:
				return true
	
	# If no matching plants were found
	return false
