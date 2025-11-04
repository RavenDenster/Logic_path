extends Control

var input_a1_textures = []
var input_a0_textures = []
var input_b1_textures = []
var input_b0_textures = []
var desired_s1_textures = []
var desired_s0_textures = []
var desired_cout_textures = []
var current_s1_textures = []
var current_s0_textures = []
var current_cout_textures = []

func _ready():
	await get_tree().process_frame
	initialize_textures()

func get_texture_rect_internal(grid_container, total_children, columns, row, col):
	var index = row * columns + col
	if index < total_children:
		var child = grid_container.get_child(index)
		if child is TextureRect:
			return child
	return null

func initialize_textures():
	if not has_node("Background/GridContainer"):
		print("ERROR: Background/GridContainer not found!")
		return

	var grid_container = $Background/GridContainer
	var total_children = grid_container.get_child_count()
	
	print("GridContainer has ", total_children, " children")

	var rows = 10
	var columns = 17
	var test_cases = 16 
	
	print("Using 10 rows and 16 test cases for 2-Bit Adder")

	input_a1_textures = []
	input_a0_textures = []
	input_b1_textures = []
	input_b0_textures = []
	desired_s1_textures = []
	desired_s0_textures = []
	desired_cout_textures = []
	current_s1_textures = []
	current_s0_textures = []
	current_cout_textures = []

	for i in range(test_cases):
		var tex = get_texture_rect_internal(grid_container, total_children, columns, 0, i + 1)
		if tex: input_a1_textures.append(tex)

		tex = get_texture_rect_internal(grid_container, total_children, columns, 1, i + 1)
		if tex: input_a0_textures.append(tex)

		tex = get_texture_rect_internal(grid_container, total_children, columns, 2, i + 1)
		if tex: input_b1_textures.append(tex)
		
		tex = get_texture_rect_internal(grid_container, total_children, columns, 3, i + 1)
		if tex: input_b0_textures.append(tex)

		tex = get_texture_rect_internal(grid_container, total_children, columns, 4, i + 1)
		if tex: desired_s1_textures.append(tex)
		
		tex = get_texture_rect_internal(grid_container, total_children, columns, 5, i + 1)
		if tex: desired_s0_textures.append(tex)
		
		tex = get_texture_rect_internal(grid_container, total_children, columns, 6, i + 1)
		if tex: desired_cout_textures.append(tex)
		
		tex = get_texture_rect_internal(grid_container, total_children, columns, 7, i + 1)
		if tex: current_s1_textures.append(tex)
		
		tex = get_texture_rect_internal(grid_container, total_children, columns, 8, i + 1)
		if tex: current_s0_textures.append(tex)
		
		tex = get_texture_rect_internal(grid_container, total_children, columns, 9, i + 1)
		if tex: current_cout_textures.append(tex)
	
	print("TestResultsPanel2BitAdder: Successfully initialized with ", 
		  input_a1_textures.size(), " test cases")

func load_initial_data(inputs_a1, inputs_a0, inputs_b1, inputs_b0, expected_s1, expected_s0, expected_cout):
	if input_a1_textures.is_empty():
		print("ERROR: Textures arrays are not initialized!")
		return
	
	var test_cases = input_a1_textures.size()
	print("Loading initial data for ", test_cases, " test cases")
	
	var actual_test_cases = min(test_cases, 16)
	
	for i in range(actual_test_cases):
		if i < input_a1_textures.size() and i < inputs_a1.size():
			if inputs_a1[i] == 1:
				input_a1_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				input_a1_textures[i].texture = preload("res://assets/point.png")

	for i in range(actual_test_cases):
		if i < input_a0_textures.size() and i < inputs_a0.size():
			if inputs_a0[i] == 1:
				input_a0_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				input_a0_textures[i].texture = preload("res://assets/point.png")

	for i in range(actual_test_cases):
		if i < input_b1_textures.size() and i < inputs_b1.size():
			if inputs_b1[i] == 1:
				input_b1_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				input_b1_textures[i].texture = preload("res://assets/point.png")

	for i in range(actual_test_cases):
		if i < input_b0_textures.size() and i < inputs_b0.size():
			if inputs_b0[i] == 1:
				input_b0_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				input_b0_textures[i].texture = preload("res://assets/point.png")
	
	for i in range(actual_test_cases):
		if i < desired_s1_textures.size() and i < expected_s1.size():
			if expected_s1[i] == 1:
				desired_s1_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				desired_s1_textures[i].texture = preload("res://assets/point.png")

	for i in range(actual_test_cases):
		if i < desired_s0_textures.size() and i < expected_s0.size():
			if expected_s0[i] == 1:
				desired_s0_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				desired_s0_textures[i].texture = preload("res://assets/point.png")

	for i in range(actual_test_cases):
		if i < desired_cout_textures.size() and i < expected_cout.size():
			if expected_cout[i] == 1:
				desired_cout_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				desired_cout_textures[i].texture = preload("res://assets/point.png")

	for i in range(actual_test_cases):
		if i < current_s1_textures.size():
			current_s1_textures[i].texture = preload("res://assets/point.png")
		if i < current_s0_textures.size():
			current_s0_textures[i].texture = preload("res://assets/point.png")
		if i < current_cout_textures.size():
			current_cout_textures[i].texture = preload("res://assets/point.png")
	
	print("TestResultsPanel2BitAdder: Initial data loaded for ", actual_test_cases, " test cases")

func update_current_outputs(actual_s1, actual_s0, actual_cout):
	if current_s1_textures.is_empty():
		print("ERROR: Current textures arrays are not initialized!")
		return

	var test_cases = current_s1_textures.size()
	print("Updating current outputs for ", test_cases, " test cases")

	var actual_test_cases = min(test_cases, 16)

	for i in range(actual_test_cases):
		if i < current_s1_textures.size() and i < actual_s1.size():
			if actual_s1[i] == 1:
				current_s1_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				current_s1_textures[i].texture = preload("res://assets/point.png")

	for i in range(actual_test_cases):
		if i < current_s0_textures.size() and i < actual_s0.size():
			if actual_s0[i] == 1:
				current_s0_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				current_s0_textures[i].texture = preload("res://assets/point.png")

	for i in range(actual_test_cases):
		if i < current_cout_textures.size() and i < actual_cout.size():
			if actual_cout[i] == 1:
				current_cout_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				current_cout_textures[i].texture = preload("res://assets/point.png")
	
	print("TestResultsPanel2BitAdder: Current outputs updated for ", actual_test_cases, " test cases")
