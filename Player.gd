# Player.gd
extends Area2D
class_name Player

@export var grid_size: int = 5
@export var cell_size: int = 64
var plots = []  # Reference to the plot grid
var current_coordinates = Vector2(0, 0)
var target_position: Vector2
var current_plot = null # Holds current plot under player


func _ready():
	current_plot = plots[current_coordinates.x][current_coordinates.y]
	target_position = current_plot.position
	global_position = target_position
	current_plot.set_player(self)

func _physics_process(delta):
	position = position.move_toward(target_position, cell_size * 5 * delta)

func _input(event):
	if event.is_action_pressed("ui_up"):
		move(Vector2(0, -1))
	elif event.is_action_pressed("ui_down"):
		move(Vector2(0, 1))
	elif event.is_action_pressed("ui_left"):
		move(Vector2(-1, 0))
	elif event.is_action_pressed("ui_right"):
		move(Vector2(1, 0))
	elif event.is_action_pressed("ui_accept"):
		# Call plant_seed when ui_accept is pressed
		plant_seed_on_current_plot("")  # Specify the plant type here (e.g., "Carrot")
	elif event.is_action_pressed("plant1"):
		# Call plant_seed when ui_accept is pressed
		plant_seed_on_current_plot("Carrot")  # Specify the plant type here (e.g., "Carrot")
	elif event.is_action_pressed("plant2"):
		# Call plant_seed when ui_accept is pressed
		plant_seed_on_current_plot("Lettuce")  # Specify the plant type here (e.g., "Carrot")
	elif event.is_action_pressed("plant3"):
		# Call plant_seed when ui_accept is pressed
		plant_seed_on_current_plot("Tomato")  # Specify the plant type here (e.g., "Carrot")
	elif event.is_action_pressed("harvest"):
		# Call plant_seed when ui_accept is pressed
		harvest_plant_on_current_plot()

func move(direction: Vector2):
	var new_coordinates = current_coordinates + direction
	if new_coordinates.x >= 0 and new_coordinates.x < grid_size and new_coordinates.y >= 0 and new_coordinates.y < grid_size:
		current_plot = plots[current_coordinates.x][current_coordinates.y]
		current_plot.remove_player()

		current_coordinates = new_coordinates
		var new_plot = plots[current_coordinates.x][current_coordinates.y]
		new_plot.set_player(self)
		target_position = new_plot.position

# New method to plant a seed on the current plot

# CAN BE MOVED TO PLANT.GD but this works so i dont wanna do that rn
func plant_seed_on_current_plot(plant_type: String):
	var plant_scene = preload("res://plants/Plant.tscn")
	var current_plant = plant_scene # Default value
	var carrot_scene = preload("res://plants/Carrot.tscn")
	var lettuce_scene = preload("res://plants/Lettuce.tscn")
	var tomato_scene = preload("res://plants/Tomato.tscn")
	if (plant_type == "Carrot"):
		current_plant = carrot_scene
	elif (plant_type == "Lettuce"):
		current_plant = lettuce_scene
	elif (plant_type == "Tomato"):
		current_plant = tomato_scene
	else:
		current_plant = plant_scene
	var plant = current_plant.instantiate()
	if current_plot and not current_plot.has_plant():
		current_plot.set_plant(plant)
		current_plot.add_child(plant)
		print("current plot plant: ", current_plot.plant)
		plant.global_position = current_plot.position
		
func harvest_plant_on_current_plot():
	if current_plot:
		if current_plot.has_plant():
			if current_plot.plant.is_fully_grown():
				current_plot.remove_child(current_plot.plant)
				current_plot.remove_plant()
				print("plant harvested")
				print(current_plot.plant)
			else:
				print("current plot plant is not fully grown")
		else:
			print("current plot does not have plant")
	else:
		print("current plot is null when harvesting")
