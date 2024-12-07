extends Area2D
class_name Player

enum PlantType { LETTUCE, TOMATO, CARROT } #Scuffed way should inherit from plant.gd
@export var grid_size: int = 5
@export var cell_size: int = 64
var plots = []  # Reference to the plot grid
var current_coordinates = Vector2(0, 0)
var target_position: Vector2
var current_plot = null  # Holds current plot under player

func _ready():
	current_plot = plots[current_coordinates.x][current_coordinates.y]
	target_position = current_plot.position
	global_position = target_position
	current_plot.set_player(self)

func _physics_process(delta):
	position = position.move_toward(target_position, cell_size * 5 * delta)

func _input(event):
	if event.is_action_pressed("ui_up") or event.is_action_pressed("up"):
		move(Vector2(0, -1))
	elif event.is_action_pressed("ui_down") or event.is_action_pressed("down"):
		move(Vector2(0, 1))
	elif event.is_action_pressed("ui_left") or event.is_action_pressed("left"):
		move(Vector2(-1, 0))
	elif event.is_action_pressed("ui_right") or event.is_action_pressed("right"):
		move(Vector2(1, 0))
	elif event.is_action_pressed("plant1"):
		plant_seed_on_current_plot(PlantType.CARROT)
	elif event.is_action_pressed("plant2"):
		plant_seed_on_current_plot(PlantType.LETTUCE)
	elif event.is_action_pressed("plant3"):
		plant_seed_on_current_plot(PlantType.TOMATO)
	elif event.is_action_pressed("harvest"):
		harvest_plant_on_current_plot()

func move(direction: Vector2):
	var new_coordinates = current_coordinates + direction
	if new_coordinates.x >= 0 and new_coordinates.x < grid_size and new_coordinates.y >= 0 and new_coordinates.y < grid_size:
		current_plot = plots[current_coordinates.x][current_coordinates.y]
		current_plot.remove_player()

		current_coordinates = new_coordinates
		current_plot = plots[current_coordinates.x][current_coordinates.y]
		current_plot.set_player(self)
		target_position = current_plot.position

func moveTo(x: int, y: int):
	current_plot = plots[current_coordinates.x][current_coordinates.y]
	current_plot.remove_player()

	current_coordinates.x = x
	current_coordinates.y = y
	current_plot = plots[current_coordinates.x][current_coordinates.y]
	current_plot.set_player(self)
	target_position = current_plot.position

func plant_seed_on_current_plot(plant_type: PlantType):
	var plant_scene : PackedScene = preload("res://plants/Plant.tscn")  # Default plant scene

	# Determine which plant type to load
	if plant_type == PlantType.LETTUCE:  # Lettuce
		plant_scene = preload("res://plants/Lettuce.tscn")
	elif plant_type == PlantType.CARROT:  # Carrot
		plant_scene = preload("res://plants/Carrot.tscn")
	elif plant_type == PlantType.TOMATO:  # Tomato
		plant_scene = preload("res://plants/Tomato.tscn")
	else:
		print("Error: Unknown plant type flag:", plant_type)

	# Instantiate the plant scene
	var plant = plant_scene.instantiate()  # Use the correct method for PackedScene
	plant.type = plant_type  # Set the plant type

	# Plant it on the plot if it's empty
	if current_plot and not current_plot.has_plant():
		current_plot.set_plant(plant)
		current_plot.add_child(plant)
		plant.global_position = current_plot.position
		plant.current_plot = current_plot
		print("Planted a ", plant.type, " on current plot.")

	# Trigger grid encoding if applicable
	var parent_node = get_parent()
	if parent_node.has_method("encode_current_grid"):
		parent_node.encode_current_grid()

var harvested_plants: Dictionary = {}

func harvest_plant_on_current_plot():
	if current_plot:
		if current_plot.has_plant():
			var plant = current_plot.plant
			if plant.is_fully_grown():
				# Remove the plant from the plot
				current_plot.remove_child(plant)
				current_plot.remove_plant()
				print("Plant harvested.")

				# Update the harvested plants dictionary
				var plant_type = plant.type  # Use the exported `type` property
				print("plant type in player: ", plant_type)
				if harvested_plants.has(plant_type):
					harvested_plants[plant_type] += 1
				else:
					harvested_plants[plant_type] = 1
				var parent_node = get_parent()
				if parent_node.has_method("check_win_condition"):
					parent_node.check_win_condition()
				print("Harvested plants:", harvested_plants)
			else:
				print("Plant is not fully grown.")
		else:
			print("No plant to harvest.")
	else:
		print("Current plot is null.")
