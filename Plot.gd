extends Node2D

@export var sun_level: float = 0.0  # Current sun energy level in the plot
@export var water_level: float = 10.0  # Current water level in the plot
@export var sun_requirement: float = 5.0  # Sun requirement for plants in this plot
@export var water_requirement: float = 5.0  # Water requirement for plants in this plot

var plant = null  # Optional plant object (set externally)

# Returns true if there is a plant in the plot
func has_plant() -> bool:
	return plant != null

# Gets the plant in the plot
func get_plant():
	return plant
	
# sets the plant in the plot
func set_plant(Plant):
	plant = Plant
	return
