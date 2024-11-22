extends Node2D  # You can also use a custom class if needed.

# Plot properties
var sun_level = 0.0
var water_level = 0.0
var plant = null  # A reference to a Plant object, if any.

# Method to update plot
func update_plot(sun_energy, moisture_change):
	sun_level += sun_energy
	water_level += moisture_change
	if plant:
		plant.grow(sun_level, water_level)
