extends Control

var input_a1_textures = []
var input_a0_textures = []
var input_b1_textures = []
var input_b0_textures = []
var desired_agtb_textures = []
var desired_altb_textures = []
var desired_aeqb_textures = []
var current_agtb_textures = []
var current_altb_textures = []
var current_aeqb_textures = []

func _ready():
	await get_tree().process_frame
	initialize_textures()

func initialize_textures():
	if not has_node("Background/GridContainer"):
		print("ERROR: Background/GridContainer not found!")
		return

	var grid_container = $Background/GridContainer
	var child_count = grid_container.get_child_count()
	print("TestResultsPanel2BitComparator: GridContainer has ", child_count, " children")

	
	if child_count < 170:
		print("ERROR: GridContainer has only ", child_count, " children, expected 170")
		return

	input_a1_textures = []
	input_a0_textures = []
	input_b1_textures = []
	input_b0_textures = []
	desired_agtb_textures = []
	desired_altb_textures = []
	desired_aeqb_textures = []
	current_agtb_textures = []
	current_altb_textures = []
	current_aeqb_textures = []

	for i in range(1, 17):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			input_a1_textures.append(child)

	for i in range(18, 34):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			input_a0_textures.append(child)

	for i in range(35, 51):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			input_b1_textures.append(child)

	for i in range(52, 68):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			input_b0_textures.append(child)

	for i in range(69, 85):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			desired_agtb_textures.append(child)

	for i in range(86, 102):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			desired_altb_textures.append(child)

	for i in range(103, 119):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			desired_aeqb_textures.append(child)

	for i in range(120, 136):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			current_agtb_textures.append(child)

	for i in range(137, 153):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			current_altb_textures.append(child)

	for i in range(154, 170):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			current_aeqb_textures.append(child)
	
	print("TestResultsPanel2BitComparator: Successfully initialized with ",
		  input_a1_textures.size(), " A1, ",
		  input_a0_textures.size(), " A0, ",
		  input_b1_textures.size(), " B1, ",
		  input_b0_textures.size(), " B0, ",
		  desired_agtb_textures.size(), " desired A>B, ",
		  desired_altb_textures.size(), " desired A<B, ",
		  desired_aeqb_textures.size(), " desired A==B, ",
		  current_agtb_textures.size(), " current A>B, ",
		  current_altb_textures.size(), " current A<B, ",
		  current_aeqb_textures.size(), " current A==B textures")

func load_initial_data(inputs_a1, inputs_a0, inputs_b1, inputs_b0, expected_agtb, expected_altb, expected_aeqb):
	if input_a1_textures.is_empty() or input_a0_textures.is_empty() or input_b1_textures.is_empty() or input_b0_textures.is_empty():
		print("ERROR: Textures arrays are not initialized!")
		return
	
	print("TestResultsPanel2BitComparator: Loading initial data")

	for i in range(16):
		if i < input_a1_textures.size() and input_a1_textures[i] is TextureRect:
			if inputs_a1[i] == 1:
				input_a1_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				input_a1_textures[i].texture = preload("res://assets/point.png")

	for i in range(16):
		if i < input_a0_textures.size() and input_a0_textures[i] is TextureRect:
			if inputs_a0[i] == 1:
				input_a0_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				input_a0_textures[i].texture = preload("res://assets/point.png")

	for i in range(16):
		if i < input_b1_textures.size() and input_b1_textures[i] is TextureRect:
			if inputs_b1[i] == 1:
				input_b1_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				input_b1_textures[i].texture = preload("res://assets/point.png")

	for i in range(16):
		if i < input_b0_textures.size() and input_b0_textures[i] is TextureRect:
			if inputs_b0[i] == 1:
				input_b0_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				input_b0_textures[i].texture = preload("res://assets/point.png")

	for i in range(16):
		if i < desired_agtb_textures.size() and desired_agtb_textures[i] is TextureRect:
			if expected_agtb[i] == 1:
				desired_agtb_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				desired_agtb_textures[i].texture = preload("res://assets/point.png")

	for i in range(16):
		if i < desired_altb_textures.size() and desired_altb_textures[i] is TextureRect:
			if expected_altb[i] == 1:
				desired_altb_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				desired_altb_textures[i].texture = preload("res://assets/point.png")

	for i in range(16):
		if i < desired_aeqb_textures.size() and desired_aeqb_textures[i] is TextureRect:
			if expected_aeqb[i] == 1:
				desired_aeqb_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				desired_aeqb_textures[i].texture = preload("res://assets/point.png")

	reset_current_outputs()
	
	print("TestResultsPanel2BitComparator: Initial data loaded")

func reset_current_outputs():
	for i in range(16):
		if i < current_agtb_textures.size() and current_agtb_textures[i] is TextureRect:
			current_agtb_textures[i].texture = preload("res://assets/point.png")

	for i in range(16):
		if i < current_altb_textures.size() and current_altb_textures[i] is TextureRect:
			current_altb_textures[i].texture = preload("res://assets/point.png")

	for i in range(16):
		if i < current_aeqb_textures.size() and current_aeqb_textures[i] is TextureRect:
			current_aeqb_textures[i].texture = preload("res://assets/point.png")

func update_current_outputs(actual_agtb, actual_altb, actual_aeqb):
	if current_agtb_textures.is_empty() or current_altb_textures.is_empty() or current_aeqb_textures.is_empty():
		print("ERROR: Current textures arrays are not initialized!")
		return

	print("TestResultsPanel2BitComparator: Updating current outputs")

	for i in range(16):
		if i < current_agtb_textures.size() and current_agtb_textures[i] is TextureRect:
			if actual_agtb[i] == 1:
				current_agtb_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				current_agtb_textures[i].texture = preload("res://assets/point.png")

	for i in range(16):
		if i < current_altb_textures.size() and current_altb_textures[i] is TextureRect:
			if actual_altb[i] == 1:
				current_altb_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				current_altb_textures[i].texture = preload("res://assets/point.png")

	for i in range(16):
		if i < current_aeqb_textures.size() and current_aeqb_textures[i] is TextureRect:
			if actual_aeqb[i] == 1:
				current_aeqb_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				current_aeqb_textures[i].texture = preload("res://assets/point.png")
	
	print("TestResultsPanel2BitComparator: Current outputs updated")
