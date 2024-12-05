extends Node2D
class_name Plant

enum PlantType { LETTUCE, TOMATO, CARROT }

var growth_level = 0
var max_growth_level = 2
var current_plot = null  # The plot this plant is currently on

# Growth rule assigned dynamically based on type
var growth_rule: GrowthRule
@export var type: PlantType

# Base class for growth rules
class GrowthRule:
	func can_grow(plant, plot) -> bool:
		return false

# Specific growth rules
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

# Main plant functionality
func _ready():
	assign_growth_rule()
	update_visuals()


func assign_growth_rule():
	var plant_growth_rules = {
		PlantType.LETTUCE: LettuceGrowthRule.new(),
		PlantType.TOMATO: TomatoGrowthRule.new(),
		PlantType.CARROT: CarrotGrowthRule.new()
	}
	growth_rule = plant_growth_rules.get(type)

func grow(plot) -> bool:
	if growth_rule and growth_rule.can_grow(self, plot):
		if growth_level < max_growth_level:
			growth_level += 1
			update_visuals()
			return true
	return false

func update_visuals():
	match growth_level:
		0:
			print("Plant of type %s is at initial growth stage." % [str(type)])
		1:
			print("Plant of type %s grew to stage 1." % [str(type)])
		2:
			print("Plant of type %s grew to its final stage." % [str(type)])

func is_fully_grown() -> bool:
	return growth_level == max_growth_level
