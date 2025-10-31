extends Control

var input1_textures = []
var input2_textures = []
var input3_textures = []
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

	if grid_container.get_child_count() < 40:  
		print("ERROR: GridContainer has only ", grid_container.get_child_count(), " children, expected at least 40")
		return

	input1_textures = []
	input2_textures = []
	input3_textures = []
	desired_textures = []
	current_textures = []
	
	for i in range(1, 9):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			input1_textures.append(child)
		else:
			print("WARNING: Child at index ", i, " is not a TextureRect")
	
	for i in range(10, 18):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			input2_textures.append(child)
		else:
			print("WARNING: Child at index ", i, " is not a TextureRect")

	for i in range(19, 27):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			input3_textures.append(child)
		else:
			print("WARNING: Child at index ", i, " is not a TextureRect")

	for i in range(28, 36):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			desired_textures.append(child)
		else:
			print("WARNING: Child at index ", i, " is not a TextureRect")

	for i in range(37, 45):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			current_textures.append(child)
		else:
			print("WARNING: Child at index ", i, " is not a TextureRect")
	
	print("TestResultsPanel3Inputs: Successfully initialized with ", 
		  input1_textures.size(), " A, ", 
		  input2_textures.size(), " B, ",
		  input3_textures.size(), " C, ",
		  desired_textures.size(), " desired, ",
		  current_textures.size(), " current textures")

func load_initial_data(inputs_a, inputs_b, inputs_c, expected_outputs):

	if input1_textures.is_empty() or input2_textures.is_empty() or input3_textures.is_empty() or desired_textures.is_empty():
		print("ERROR: Textures arrays are not initialized!")
		return
	
	for i in range(8):
		if i < input1_textures.size() and input1_textures[i] is TextureRect:
			if inputs_a[i] == 1:
				input1_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				input1_textures[i].texture = preload("res://assets/point.png")

	for i in range(8):
		if i < input2_textures.size() and input2_textures[i] is TextureRect:
			if inputs_b[i] == 1:
				input2_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				input2_textures[i].texture = preload("res://assets/point.png")

	for i in range(8):
		if i < input3_textures.size() and input3_textures[i] is TextureRect:
			if inputs_c[i] == 1:
				input3_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				input3_textures[i].texture = preload("res://assets/point.png")
	
	for i in range(8):
		if i < desired_textures.size() and desired_textures[i] is TextureRect:
			if expected_outputs[i] == 1:
				desired_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				desired_textures[i].texture = preload("res://assets/point.png")

	for i in range(8):
		if i < current_textures.size() and current_textures[i] is TextureRect:
			current_textures[i].texture = preload("res://assets/point.png")
	
	print("TestResultsPanel3Inputs: Initial data loaded")

func update_current_outputs(actual_outputs):

	if current_textures.is_empty():
		print("ERROR: Current textures array is not initialized!")
		return

	for i in range(8):
		if i < current_textures.size() and current_textures[i] is TextureRect:
			if actual_outputs[i] == 1:
				current_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				current_textures[i].texture = preload("res://assets/point.png")
	
	print("TestResultsPanel3Inputs: Current outputs updated")
