extends Node2D

var growth_level = 0
var max_growth_level = 3
var sun_req = 5.0
var water_req = 3.0

# Grow plant based on conditions
func grow(sun, water):
	if sun >= sun_req and water >= water_req:
		growth_level += 1

# Checks if the plant is fully grown
func is_fully_grown() -> bool:
	return growth_level == max_growth_level
