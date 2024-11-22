extends Node2D

var growth_level = 0
var sun_req = 5.0
var water_req = 3.0

# Grow plant based on conditions
func grow(sun, water):
	if sun >= sun_req and water >= water_req:
		growth_level += 1
