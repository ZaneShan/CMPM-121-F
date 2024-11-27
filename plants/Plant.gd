extends Node2D
const Plot = preload("res://Plot.gd")

var plant_name = "plant"
var growth_level = 0
var max_growth_level = 3
var sun_req = 5.0
var water_req = 3.0
var current_plot = null 

# References to the plant stage sprites
var plant_stage_1 = null
var plant_stage_2 = null
var plant_stage_3 = null

func _init(plot) -> void:
	current_plot = plot
	
func _ready():
	# Get references to the child Sprite nodes for each growth stage
	plant_stage_1 = $plant_stage_1
	plant_stage_2 = $plant_stage_2
	plant_stage_3 = $plant_stage_3
	
	# Set the initial visibility
	update_plant_growth()

func get_current_plot():
	return current_plot

func seed_plant():
	if current_plot.has_plant():
		return
	print("seeded a plant")
	return
	
func harvest_plant():
	if current_plot.has_plant():
		print("Harvesting Plant")
	return
	
	
# Grow plant based on conditions
func grow():
	if (growth_level == max_growth_level):
		print("Plant is fully grown")
		return
	if (current_plot.sun_level >= current_plot.sun_req 
	and current_plot.water_level >= current_plot.water_req 
	and growth_level < max_growth_level):
		growth_level += 1
		update_plant_growth()

func get_plant_level():
	return growth_level

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
			print("Plant at stage 1")
		1:
			plant_stage_2.visible = true
			print("Plant at stage 2")
		2:
			plant_stage_3.visible = true
			print("Plant at stage 3")
		_:
			print("Invalid growth level: ", growth_level)
