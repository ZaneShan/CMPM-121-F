extends Node2D

@export var sun_level: float = 0.0  # Current sun energy level in the plot
@export var water_level: float = 10.0  # Current water level in the plot
@export var sun_requirement: float = 5.0  # Sun requirement for plants in this plot
@export var water_requirement: float = 5.0  # Water requirement for plants in this plot

var growth_stage: int = 0  # Current growth stage of the plant
var max_growth_stage: int = 3  # Maximum growth stage of the plant
var plant = null  # Optional plant object (set externally)

# Method to grow the plant if growth conditions are met
func grow():
	if growth_stage < max_growth_stage:
		growth_stage += 1
		print("Plant grew to stage ", growth_stage)

# Checks if the plant in this plot is fully grown
func is_fully_grown() -> bool:
	return growth_stage == max_growth_stage

# Returns true if there is a plant in the plot
func has_plant() -> bool:
	return plant != null

# Gets the plant in the plot
func get_plant():
	return plant
