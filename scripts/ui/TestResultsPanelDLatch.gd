# TestResultsPanelDLatch.gd
extends Control

var input_d_textures = []
var input_enable_textures = []
var desired_q_textures = []
var current_q_textures = []

func _ready():
	await get_tree().process_frame
	initialize_textures()

func initialize_textures():
	if not has_node("Background/GridContainer"):
		print("ERROR: Background/GridContainer not found!")
		return

	var grid_container = $Background/GridContainer

	if grid_container.get_child_count() < 36:  # 4 строки × 9 элементов
		print("ERROR: GridContainer has only ", grid_container.get_child_count(), " children, expected 36")
		return

	input_d_textures = []
	input_enable_textures = []
	desired_q_textures = []
	current_q_textures = []
	
	# Input D (строка 0) - пропускаем Label (индекс 0), берем TextureRect с 1 по 8
	for i in range(1, 9):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			input_d_textures.append(child)

	# Input Enable (строка 1) - индексы 9-16
	for i in range(10, 18):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			input_enable_textures.append(child)

	# Desired Q (строка 2) - индексы 18-25
	for i in range(19, 27):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			desired_q_textures.append(child)

	# Current Q (строка 3) - индексы 27-34
	for i in range(28, 36):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			current_q_textures.append(child)
	
	print("TestResultsPanelDLatch: Successfully initialized with ", 
		  input_d_textures.size(), " D, ", 
		  input_enable_textures.size(), " Enable, ",
		  desired_q_textures.size(), " desired Q, ",
		  current_q_textures.size(), " current Q textures")

func load_initial_data(inputs_d, inputs_enable, expected_q):
	if input_d_textures.is_empty() or input_enable_textures.is_empty():
		print("ERROR: Textures arrays are not initialized!")
		return
	
	# Input D
	for i in range(8):
		if i < input_d_textures.size() and input_d_textures[i] is TextureRect:
			if inputs_d[i] == 1:
				input_d_textures[i].texture = load("res://assets/pointGreen.png")
			else:
				input_d_textures[i].texture = load("res://assets/point.png")

	# Input Enable
	for i in range(8):
		if i < input_enable_textures.size() and input_enable_textures[i] is TextureRect:
			if inputs_enable[i] == 1:
				input_enable_textures[i].texture = load("res://assets/pointGreen.png")
			else:
				input_enable_textures[i].texture = load("res://assets/point.png")
	
	# Desired Q
	for i in range(8):
		if i < desired_q_textures.size() and desired_q_textures[i] is TextureRect:
			if expected_q[i] == 1:
				desired_q_textures[i].texture = load("res://assets/pointGreen.png")
			else:
				desired_q_textures[i].texture = load("res://assets/point.png")

	# Current Q (очищаем)
	for i in range(8):
		if i < current_q_textures.size() and current_q_textures[i] is TextureRect:
			current_q_textures[i].texture = load("res://assets/point.png")
	
	print("TestResultsPanelDLatch: Initial data loaded")

func update_current_outputs(actual_q):
	if current_q_textures.is_empty():
		print("ERROR: Current textures arrays are not initialized!")
		return

	# Current Q
	for i in range(8):
		if i < current_q_textures.size() and current_q_textures[i] is TextureRect:
			if actual_q[i] == 1:
				current_q_textures[i].texture = load("res://assets/pointGreen.png")
			else:
				current_q_textures[i].texture = load("res://assets/point.png")
	
	print("TestResultsPanelDLatch: Current outputs updated")
