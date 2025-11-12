
extends Control

var input_i0_textures = []
var input_i1_textures = []
var input_i2_textures = []
var input_i3_textures = []
var desired_o0_textures = []
var desired_o1_textures = []
var current_o0_textures = []
var current_o1_textures = []

func _ready():
	await get_tree().process_frame
	initialize_textures()

func initialize_textures():
	if not has_node("Background/GridContainer"):
		print("ERROR: Background/GridContainer not found!")
		return

	var grid_container = $Background/GridContainer

	if grid_container.get_child_count() < 32:  # 8 строк × 4 элементов + метки
		print("ERROR: GridContainer has only ", grid_container.get_child_count(), " children, expected 32")
		return

	input_i0_textures = []
	input_i1_textures = []
	input_i2_textures = []
	input_i3_textures = []
	desired_o0_textures = []
	desired_o1_textures = []
	current_o0_textures = []
	current_o1_textures = []
	
	# Input I0 (строка 0) - пропускаем Label (индекс 0), берем TextureRect с 1 по 4
	for i in range(1, 5):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			input_i0_textures.append(child)

	# Input I1 (строка 1) - индексы 5-8
	for i in range(6, 10):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			input_i1_textures.append(child)

	# Input I2 (строка 2) - индексы 10-13
	for i in range(11, 15):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			input_i2_textures.append(child)

	# Input I3 (строка 3) - индексы 15-18
	for i in range(16, 20):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			input_i3_textures.append(child)

	# Desired O0 (строка 4) - индексы 20-23
	for i in range(21, 25):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			desired_o0_textures.append(child)

	# Desired O1 (строка 5) - индексы 25-28
	for i in range(26, 30):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			desired_o1_textures.append(child)

	# Current O0 (строка 6) - индексы 30-33
	for i in range(31, 35):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			current_o0_textures.append(child)

	# Current O1 (строка 7) - индексы 35-38
	for i in range(36, 40):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			current_o1_textures.append(child)
	
	print("TestResultsPanelEncoder: Successfully initialized with ", 
		  input_i0_textures.size(), " I0, ", 
		  input_i1_textures.size(), " I1, ",
		  input_i2_textures.size(), " I2, ",
		  input_i3_textures.size(), " I3, ",
		  desired_o0_textures.size(), " desired O0, ",
		  desired_o1_textures.size(), " desired O1, ",
		  current_o0_textures.size(), " current O0, ",
		  current_o1_textures.size(), " current O1 textures")

func load_initial_data(inputs_i0, inputs_i1, inputs_i2, inputs_i3, expected_o0, expected_o1):
	if input_i0_textures.is_empty() or input_i1_textures.is_empty():
		print("ERROR: Textures arrays are not initialized!")
		return
	
	# Input I0
	for i in range(4):
		if i < input_i0_textures.size() and input_i0_textures[i] is TextureRect:
			if inputs_i0[i] == 1:
				input_i0_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				input_i0_textures[i].texture = preload("res://assets/point.png")

	# Input I1
	for i in range(4):
		if i < input_i1_textures.size() and input_i1_textures[i] is TextureRect:
			if inputs_i1[i] == 1:
				input_i1_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				input_i1_textures[i].texture = preload("res://assets/point.png")

	# Input I2
	for i in range(4):
		if i < input_i2_textures.size() and input_i2_textures[i] is TextureRect:
			if inputs_i2[i] == 1:
				input_i2_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				input_i2_textures[i].texture = preload("res://assets/point.png")

	# Input I3
	for i in range(4):
		if i < input_i3_textures.size() and input_i3_textures[i] is TextureRect:
			if inputs_i3[i] == 1:
				input_i3_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				input_i3_textures[i].texture = preload("res://assets/point.png")
	
	# Desired O0
	for i in range(4):
		if i < desired_o0_textures.size() and desired_o0_textures[i] is TextureRect:
			if expected_o0[i] == 1:
				desired_o0_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				desired_o0_textures[i].texture = preload("res://assets/point.png")

	# Desired O1
	for i in range(4):
		if i < desired_o1_textures.size() and desired_o1_textures[i] is TextureRect:
			if expected_o1[i] == 1:
				desired_o1_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				desired_o1_textures[i].texture = preload("res://assets/point.png")

	# Current O0 (очищаем)
	for i in range(4):
		if i < current_o0_textures.size() and current_o0_textures[i] is TextureRect:
			current_o0_textures[i].texture = preload("res://assets/point.png")

	# Current O1 (очищаем)
	for i in range(4):
		if i < current_o1_textures.size() and current_o1_textures[i] is TextureRect:
			current_o1_textures[i].texture = preload("res://assets/point.png")
	
	print("TestResultsPanelEncoder: Initial data loaded")

func update_current_outputs(actual_o0, actual_o1):
	if current_o0_textures.is_empty() or current_o1_textures.is_empty():
		print("ERROR: Current textures arrays are not initialized!")
		return

	# Current O0
	for i in range(4):
		if i < current_o0_textures.size() and current_o0_textures[i] is TextureRect:
			if actual_o0[i] == 1:
				current_o0_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				current_o0_textures[i].texture = preload("res://assets/point.png")

	# Current O1
	for i in range(4):
		if i < current_o1_textures.size() and current_o1_textures[i] is TextureRect:
			if actual_o1[i] == 1:
				current_o1_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				current_o1_textures[i].texture = preload("res://assets/point.png")
	
	print("TestResultsPanelEncoder: Current outputs updated")
