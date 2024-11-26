extends Node2D

var growth_level = 0
var max_growth_level = 3
var sun_req = 5.0
var water_req = 3.0

# References to the plant stage sprites
var plant_stage_1 = null
var plant_stage_2 = null
var plant_stage_3 = null

func _ready():
	# Get references to the child Sprite nodes for each growth stage
	plant_stage_1 = $plant_stage_1
	plant_stage_2 = $plant_stage_2
	plant_stage_3 = $plant_stage_3
	
	# Set the initial visibility
	update_plant_growth()

# Grow plant based on conditions
func grow(sun, water):
	if sun >= sun_req and water >= water_req and growth_level < max_growth_level:
		growth_level += 1
		update_plant_growth()

# Checks if the plant is fully grown
func is_fully_grown() -> bool:
	return growth_level == max_growth_level

# Update plant growth visual representation
func update_plant_growth():
	# Make all stages invisible by default
	plant_stage_1.visible = false
	plant_stage_2.visible = false
	plant_stage_3.visible = false

	# Set visibility for the current growth level
	match growth_level:
		0:
			plant_stage_1.visible = true
		1:
			plant_stage_2.visible = true
		2:
			plant_stage_3.visible = true
		_:
			print("Invalid growth level: ", growth_level)
