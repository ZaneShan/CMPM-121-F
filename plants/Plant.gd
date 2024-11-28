extends Node2D
class_name Plant
var growth_level = 0
var max_growth_level = 3
@export var sun_req = 1.0
@export var water_req = 1.0

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
	

func update_plant(plant, plot):
	# Check if plant meets growth requirements
	if plot.sun_level >= plant.sun_req and plot.water_level >= plant.water_req:
		if (growth_level < max_growth_level):
			growth_level += 1
			if (growth_level < max_growth_level):
				plant.grow()
		
func grow():
	update_plant_growth()

# Checks if the plant is fully grown
func is_fully_grown() -> bool:
	return growth_level == max_growth_level

func update_plant_growth():
	plant_stage_1.visible = growth_level == 0
	plant_stage_2.visible = growth_level == 1
	plant_stage_3.visible = growth_level == 2
