# TestResultsPanelDecoder.gd
extends Control

var input_a_textures = []
var input_b_textures = []
var desired_y0_textures = []
var desired_y1_textures = []
var desired_y2_textures = []
var desired_y3_textures = []
var current_y0_textures = []
var current_y1_textures = []
var current_y2_textures = []
var current_y3_textures = []

func _ready():
	await get_tree().process_frame
	initialize_textures()

func initialize_textures():
	if not has_node("Background/HBoxContainer/GridContainer") or not has_node("Background/HBoxContainer2/GridContainer"):
		print("ERROR: GridContainers not found in new structure!")
		return

	var left_grid_container = $Background/HBoxContainer/GridContainer
	var right_grid_container = $Background/HBoxContainer2/GridContainer

	if left_grid_container.get_child_count() < 30:  # 6 строк × 5 элементов
		print("ERROR: Left GridContainer has only ", left_grid_container.get_child_count(), " children, expected 30")
		return

	if right_grid_container.get_child_count() < 20:  # 4 строки × 5 элементов
		print("ERROR: Right GridContainer has only ", right_grid_container.get_child_count(), " children, expected 20")
		return

	input_a_textures = []
	input_b_textures = []
	desired_y0_textures = []
	desired_y1_textures = []
	desired_y2_textures = []
	desired_y3_textures = []
	current_y0_textures = []
	current_y1_textures = []
	current_y2_textures = []
	current_y3_textures = []
	
	# ЛЕВАЯ ЧАСТЬ (Inputs & Desired) - 6 строк
	
	# Input A (строка 0) - пропускаем Label (индекс 0), берем TextureRect с 1 по 4
	for i in range(1, 5):
		var child = left_grid_container.get_child(i)
		if child is TextureRect:
			input_a_textures.append(child)

	# Input B (строка 1) - индексы 5-9
	for i in range(6, 10):
		var child = left_grid_container.get_child(i)
		if child is TextureRect:
			input_b_textures.append(child)

	# Desired Y0 (строка 2) - индексы 10-14
	for i in range(11, 15):
		var child = left_grid_container.get_child(i)
		if child is TextureRect:
			desired_y0_textures.append(child)

	# Desired Y1 (строка 3) - индексы 15-19
	for i in range(16, 20):
		var child = left_grid_container.get_child(i)
		if child is TextureRect:
			desired_y1_textures.append(child)

	# Desired Y2 (строка 4) - индексы 20-24
	for i in range(21, 25):
		var child = left_grid_container.get_child(i)
		if child is TextureRect:
			desired_y2_textures.append(child)

	# Desired Y3 (строка 5) - индексы 25-29
	for i in range(26, 30):
		var child = left_grid_container.get_child(i)
		if child is TextureRect:
			desired_y3_textures.append(child)

	# ПРАВАЯ ЧАСТЬ (Current Outputs) - 4 строки
	
	# Current Y0 (строка 0) - индексы 0-4 (пропускаем Label индекс 0, берем 1-4)
	for i in range(1, 5):
		var child = right_grid_container.get_child(i)
		if child is TextureRect:
			current_y0_textures.append(child)

	# Current Y1 (строка 1) - индексы 5-9
	for i in range(6, 10):
		var child = right_grid_container.get_child(i)
		if child is TextureRect:
			current_y1_textures.append(child)

	# Current Y2 (строка 2) - индексы 10-14
	for i in range(11, 15):
		var child = right_grid_container.get_child(i)
		if child is TextureRect:
			current_y2_textures.append(child)

	# Current Y3 (строка 3) - индексы 15-19
	for i in range(16, 20):
		var child = right_grid_container.get_child(i)
		if child is TextureRect:
			current_y3_textures.append(child)
	
	print("TestResultsPanelDecoder: Successfully initialized with 6+4 structure")
	print("Left panel (6 rows): ", input_a_textures.size(), " A, ", input_b_textures.size(), " B, ",
		  desired_y0_textures.size(), " desired Y0, ", desired_y1_textures.size(), " desired Y1, ",
		  desired_y2_textures.size(), " desired Y2, ", desired_y3_textures.size(), " desired Y3")
	print("Right panel (4 rows): ", current_y0_textures.size(), " current Y0, ",
		  current_y1_textures.size(), " current Y1, ", current_y2_textures.size(), " current Y2, ",
		  current_y3_textures.size(), " current Y3")

func load_initial_data(inputs_a, inputs_b, expected_y0, expected_y1, expected_y2, expected_y3):
	if input_a_textures.is_empty() or input_b_textures.is_empty():
		print("ERROR: Textures arrays are not initialized!")
		return
	
	# ЛЕВАЯ ЧАСТЬ: Inputs и Desired outputs (6 строк)
	
	# Input A
	for i in range(4):
		if i < input_a_textures.size() and input_a_textures[i] is TextureRect:
			if inputs_a[i] == 1:
				input_a_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				input_a_textures[i].texture = preload("res://assets/point.png")

	# Input B
	for i in range(4):
		if i < input_b_textures.size() and input_b_textures[i] is TextureRect:
			if inputs_b[i] == 1:
				input_b_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				input_b_textures[i].texture = preload("res://assets/point.png")
	
	# Desired Y0
	for i in range(4):
		if i < desired_y0_textures.size() and desired_y0_textures[i] is TextureRect:
			if expected_y0[i] == 1:
				desired_y0_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				desired_y0_textures[i].texture = preload("res://assets/point.png")

	# Desired Y1
	for i in range(4):
		if i < desired_y1_textures.size() and desired_y1_textures[i] is TextureRect:
			if expected_y1[i] == 1:
				desired_y1_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				desired_y1_textures[i].texture = preload("res://assets/point.png")

	# Desired Y2
	for i in range(4):
		if i < desired_y2_textures.size() and desired_y2_textures[i] is TextureRect:
			if expected_y2[i] == 1:
				desired_y2_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				desired_y2_textures[i].texture = preload("res://assets/point.png")

	# Desired Y3
	for i in range(4):
		if i < desired_y3_textures.size() and desired_y3_textures[i] is TextureRect:
			if expected_y3[i] == 1:
				desired_y3_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				desired_y3_textures[i].texture = preload("res://assets/point.png")

	# ПРАВАЯ ЧАСТЬ: Current outputs (очищаем) - 4 строки
	for i in range(4):
		if i < current_y0_textures.size() and current_y0_textures[i] is TextureRect:
			current_y0_textures[i].texture = preload("res://assets/point.png")
		if i < current_y1_textures.size() and current_y1_textures[i] is TextureRect:
			current_y1_textures[i].texture = preload("res://assets/point.png")
		if i < current_y2_textures.size() and current_y2_textures[i] is TextureRect:
			current_y2_textures[i].texture = preload("res://assets/point.png")
		if i < current_y3_textures.size() and current_y3_textures[i] is TextureRect:
			current_y3_textures[i].texture = preload("res://assets/point.png")
	
	print("TestResultsPanelDecoder: Initial data loaded with 6+4 structure")

func update_current_outputs(actual_y0, actual_y1, actual_y2, actual_y3):
	if current_y0_textures.is_empty() or current_y1_textures.is_empty() or current_y2_textures.is_empty() or current_y3_textures.is_empty():
		print("ERROR: Current textures arrays are not initialized!")
		return

	# ПРАВАЯ ЧАСТЬ: Обновляем Current outputs (4 строки)

	# Current Y0
	for i in range(4):
		if i < current_y0_textures.size() and current_y0_textures[i] is TextureRect:
			if actual_y0[i] == 1:
				current_y0_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				current_y0_textures[i].texture = preload("res://assets/point.png")

	# Current Y1
	for i in range(4):
		if i < current_y1_textures.size() and current_y1_textures[i] is TextureRect:
			if actual_y1[i] == 1:
				current_y1_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				current_y1_textures[i].texture = preload("res://assets/point.png")

	# Current Y2
	for i in range(4):
		if i < current_y2_textures.size() and current_y2_textures[i] is TextureRect:
			if actual_y2[i] == 1:
				current_y2_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				current_y2_textures[i].texture = preload("res://assets/point.png")

	# Current Y3
	for i in range(4):
		if i < current_y3_textures.size() and current_y3_textures[i] is TextureRect:
			if actual_y3[i] == 1:
				current_y3_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				current_y3_textures[i].texture = preload("res://assets/point.png")
	
	print("TestResultsPanelDecoder: Current outputs updated in right panel (4 rows)")
