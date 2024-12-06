extends Node2D
class_name Plant

# Plant types (Lettuce, Tomato, Carrot)
enum PlantType { LETTUCE, TOMATO, CARROT }

# Growth stages
enum GrowthStage { STAGE_0, STAGE_1, STAGE_2 }

# Exported type for the plant (settable in the editor)
@export var type: PlantType

# Growth level of the plant
var growth_level = GrowthStage.STAGE_0
var max_growth_level = GrowthStage.STAGE_2  # Final growth stage

# The plot this plant is currently on (reference to Plot node)
var current_plot = null  # This will be set when the plant is placed

# Growth rule assigned dynamically based on plant type
var growth_rule: GrowthRule

# Visual nodes for each growth stage
@onready var plant_stage_0 : Sprite2D = $plant_stage_1
@onready var plant_stage_1 : Sprite2D = $plant_stage_2
@onready var plant_stage_2 : Sprite2D = $plant_stage_3

# Base class for growth rules
class GrowthRule:
	func can_grow(plant, plot) -> bool:
		return false

# Specific growth rules for each plant type
class LettuceGrowthRule extends GrowthRule:
	func can_grow(plant, plot) -> bool:
		return plot.get_adjacent_plots().any(
			func(adjacent) -> bool:
				return adjacent.has_plant() and adjacent.get_plant().type == PlantType.LETTUCE
		)

class TomatoGrowthRule extends GrowthRule:
	func can_grow(plant, plot) -> bool:
		return not plot.get_adjacent_plots().any(
			func(adjacent) -> bool:
				return adjacent.has_plant()
		)

class CarrotGrowthRule extends GrowthRule:
	func can_grow(plant, plot) -> bool:
		return not plot.get_adjacent_plots().any(
			func(adjacent) -> bool:
				return adjacent.has_plant() and adjacent.get_plant().type == PlantType.CARROT
		)

# Initialization function, called when the node is ready
func _ready():
	# Assign the growth rule based on the plant type
	assign_growth_rule()

	# Update visuals based on the current growth level
	update_visuals()

# Assign the appropriate growth rule based on the plant type
func assign_growth_rule():
	var plant_growth_rules = {
		PlantType.LETTUCE: LettuceGrowthRule.new(),
		PlantType.TOMATO: TomatoGrowthRule.new(),
		PlantType.CARROT: CarrotGrowthRule.new()
	}
	growth_rule = plant_growth_rules.get(type)

# Grow the plant by increasing its growth level
func grow(plot) -> bool:
	if growth_rule and growth_rule.can_grow(self, plot):
		if growth_level < max_growth_level:
			growth_level += 1
			update_visuals()
			return true
	return false

# Update the visuals of the plant based on its current growth stage
func update_visuals():
	# Hide all growth stages initially
	plant_stage_0.visible = false
	plant_stage_1.visible = false
	plant_stage_2.visible = false
	
	# Show the appropriate growth stage
	match growth_level:
		GrowthStage.STAGE_0:
			plant_stage_0.visible = true
			print("Plant of type %s is at initial growth stage." % [str(type)])
		GrowthStage.STAGE_1:
			plant_stage_1.visible = true
			print("Plant of type %s grew to stage 1." % [str(type)])
		GrowthStage.STAGE_2:
			plant_stage_2.visible = true
			print("Plant of type %s grew to its final stage." % [str(type)])

# Check if the plant has fully grown
func is_fully_grown() -> bool:
	return growth_level == max_growth_level
