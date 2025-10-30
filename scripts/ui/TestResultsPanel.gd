extends Control

var input1_textures = []
var input2_textures = []
var desired_textures = []
var current_textures = []

func _ready():
	await get_tree().process_frame
	initialize_textures()

func initialize_textures():
	if not has_node("Background/GridContainer"):
		print("ERROR: Background/GridContainer not found!")
		return
	
	var grid_container = $Background/GridContainer
	
	if grid_container.get_child_count() < 24:
		print("ERROR: GridContainer has only ", grid_container.get_child_count(), " children, expected 24")
		return

	input1_textures = [
		grid_container.get_child(1),
		grid_container.get_child(2),
		grid_container.get_child(3),
		grid_container.get_child(4)
	]
	
	input2_textures = [
		grid_container.get_child(7),
		grid_container.get_child(8),
		grid_container.get_child(9),
		grid_container.get_child(10)
	]
	
	desired_textures = [
		grid_container.get_child(13),
		grid_container.get_child(14),
		grid_container.get_child(15),
		grid_container.get_child(16)
	]
	
	current_textures = [
		grid_container.get_child(19),
		grid_container.get_child(20),
		grid_container.get_child(21),
		grid_container.get_child(22)
	]
	
	print("TestResultsPanel: Successfully initialized with ", input1_textures.size(), " textures per category")

func load_initial_data(inputs_a, inputs_b, expected_outputs):
	if input1_textures.is_empty():
		print("ERROR: Textures arrays are not initialized!")
		return

	for i in range(4):
		if inputs_a[i] == 1:
			input1_textures[i].texture = preload("res://assets/pointGreen.png")
		else:
			input1_textures[i].texture = preload("res://assets/point.png")

	for i in range(4):
		if inputs_b[i] == 1:
			input2_textures[i].texture = preload("res://assets/pointGreen.png")
		else:
			input2_textures[i].texture = preload("res://assets/point.png")

	for i in range(4):
		if expected_outputs[i] == 1:
			desired_textures[i].texture = preload("res://assets/pointGreen.png")
		else:
			desired_textures[i].texture = preload("res://assets/point.png")

	print("TestResultsPanel: Initial data loaded")

func update_results(inputs_a, inputs_b, expected_outputs, actual_outputs):

	load_initial_data(inputs_a, inputs_b, expected_outputs)

	for i in range(4):
		if actual_outputs[i] == 1:
			current_textures[i].texture = preload("res://assets/pointGreen.png")
		else:
			current_textures[i].texture = preload("res://assets/point.png")
	
	print("TestResultsPanel: Results updated with current outputs")

func update_current_outputs(actual_outputs):

	if current_textures.is_empty():
		print("ERROR: Textures arrays are not initialized!")
		return
	for i in range(4):
		if actual_outputs[i] == 1:
			current_textures[i].texture = preload("res://assets/pointGreen.png")
		else:
			current_textures[i].texture = preload("res://assets/point.png")
	
	print("TestResultsPanel: Current outputs updated")
