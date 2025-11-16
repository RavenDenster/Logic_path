extends Control

var input_a_textures = []
var input_b_textures = []
var input_cin_textures = []
var desired_sum_textures = []
var desired_cout_textures = []
var current_sum_textures = []
var current_cout_textures = []

func _ready():
	await get_tree().process_frame
	initialize_textures()

func initialize_textures():
	if not has_node("Background/GridContainer"):
		print("ERROR: Background/GridContainer not found!")
		return

	var grid_container = $Background/GridContainer

	if grid_container.get_child_count() < 63:  # 7 строк × 9 элементов
		print("ERROR: GridContainer has only ", grid_container.get_child_count(), " children, expected 63")
		return

	input_a_textures = []
	input_b_textures = []
	input_cin_textures = []
	desired_sum_textures = []
	desired_cout_textures = []
	current_sum_textures = []
	current_cout_textures = []
	
	# Input A (строка 0) - пропускаем Label (индекс 0), берем TextureRect с 1 по 8
	for i in range(1, 9):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			input_a_textures.append(child)

	# Input B (строка 1) - индексы 9-16
	for i in range(10, 18):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			input_b_textures.append(child)

	# Cin (строка 2) - индексы 18-25
	for i in range(19, 27):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			input_cin_textures.append(child)

	# Desired Sum (строка 3) - индексы 27-34
	for i in range(28, 36):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			desired_sum_textures.append(child)

	# Desired Cout (строка 4) - индексы 36-43
	for i in range(37, 45):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			desired_cout_textures.append(child)

	# Current Sum (строка 5) - индексы 45-52
	for i in range(46, 54):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			current_sum_textures.append(child)

	# Current Cout (строка 6) - индексы 54-61
	for i in range(55, 63):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			current_cout_textures.append(child)
	
	print("TestResultsPanelFullAdder: Successfully initialized with ", 
		  input_a_textures.size(), " A, ", 
		  input_b_textures.size(), " B, ",
		  input_cin_textures.size(), " Cin, ",
		  desired_sum_textures.size(), " desired sum, ",
		  desired_cout_textures.size(), " desired cout, ",
		  current_sum_textures.size(), " current sum, ",
		  current_cout_textures.size(), " current cout textures")

func load_initial_data(inputs_a, inputs_b, inputs_cin, expected_sum, expected_cout):
	if input_a_textures.is_empty() or input_b_textures.is_empty() or input_cin_textures.is_empty():
		print("ERROR: Textures arrays are not initialized!")
		return
	
	# Input A
	for i in range(8):
		if i < input_a_textures.size() and input_a_textures[i] is TextureRect:
			if inputs_a[i] == 1:
				input_a_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				input_a_textures[i].texture = preload("res://assets/point.png")

	# Input B
	for i in range(8):
		if i < input_b_textures.size() and input_b_textures[i] is TextureRect:
			if inputs_b[i] == 1:
				input_b_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				input_b_textures[i].texture = preload("res://assets/point.png")

	# Cin
	for i in range(8):
		if i < input_cin_textures.size() and input_cin_textures[i] is TextureRect:
			if inputs_cin[i] == 1:
				input_cin_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				input_cin_textures[i].texture = preload("res://assets/point.png")
	
	# Desired Sum
	for i in range(8):
		if i < desired_sum_textures.size() and desired_sum_textures[i] is TextureRect:
			if expected_sum[i] == 1:
				desired_sum_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				desired_sum_textures[i].texture = preload("res://assets/point.png")

	# Desired Cout
	for i in range(8):
		if i < desired_cout_textures.size() and desired_cout_textures[i] is TextureRect:
			if expected_cout[i] == 1:
				desired_cout_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				desired_cout_textures[i].texture = preload("res://assets/point.png")

	# Current Sum (очищаем)
	for i in range(8):
		if i < current_sum_textures.size() and current_sum_textures[i] is TextureRect:
			current_sum_textures[i].texture = preload("res://assets/point.png")

	# Current Cout (очищаем)
	for i in range(8):
		if i < current_cout_textures.size() and current_cout_textures[i] is TextureRect:
			current_cout_textures[i].texture = preload("res://assets/point.png")
	
	print("TestResultsPanelFullAdder: Initial data loaded")

func update_current_outputs(actual_sum, actual_cout):
	if current_sum_textures.is_empty() or current_cout_textures.is_empty():
		print("ERROR: Current textures arrays are not initialized!")
		return

	# Current Sum
	for i in range(8):
		if i < current_sum_textures.size() and current_sum_textures[i] is TextureRect:
			if actual_sum[i] == 1:
				current_sum_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				current_sum_textures[i].texture = preload("res://assets/point.png")

	# Current Cout
	for i in range(8):
		if i < current_cout_textures.size() and current_cout_textures[i] is TextureRect:
			if actual_cout[i] == 1:
				current_cout_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				current_cout_textures[i].texture = preload("res://assets/point.png")
	
	print("TestResultsPanelFullAdder: Current outputs updated")
