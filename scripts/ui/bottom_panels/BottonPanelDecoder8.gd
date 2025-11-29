# TestResultsPanelDecoder8.gd
extends Control

var input_a_textures = []
var input_b_textures = []
var input_c_textures = []
var desired_y0_textures = []
var desired_y1_textures = []
var desired_y2_textures = []
var desired_y3_textures = []
var desired_y4_textures = []
var desired_y5_textures = []
var desired_y6_textures = []
var desired_y7_textures = []
var current_y0_textures = []
var current_y1_textures = []
var current_y2_textures = []
var current_y3_textures = []
var current_y4_textures = []
var current_y5_textures = []
var current_y6_textures = []
var current_y7_textures = []

func _ready():
	await get_tree().process_frame
	initialize_textures()

func initialize_textures():
	if not has_node("Background/HBoxContainer/GridContainer") or not has_node("Background/HBoxContainer2/GridContainer"):
		print("ERROR: GridContainers not found in new structure!")
		return

	var left_grid_container = $Background/HBoxContainer/GridContainer
	var right_grid_container = $Background/HBoxContainer2/GridContainer

	if left_grid_container.get_child_count() < 99:  # 11 строк × 9 элементов
		print("ERROR: Left GridContainer has only ", left_grid_container.get_child_count(), " children, expected 99")
		return

	if right_grid_container.get_child_count() < 72:  # 8 строк × 9 элементов
		print("ERROR: Right GridContainer has only ", right_grid_container.get_child_count(), " children, expected 72")
		return

	input_a_textures = []
	input_b_textures = []
	input_c_textures = []
	desired_y0_textures = []
	desired_y1_textures = []
	desired_y2_textures = []
	desired_y3_textures = []
	desired_y4_textures = []
	desired_y5_textures = []
	desired_y6_textures = []
	desired_y7_textures = []
	current_y0_textures = []
	current_y1_textures = []
	current_y2_textures = []
	current_y3_textures = []
	current_y4_textures = []
	current_y5_textures = []
	current_y6_textures = []
	current_y7_textures = []
	
	# ЛЕВАЯ ЧАСТЬ (Inputs & Desired) - 11 строк
	
	# Input A (строка 0) - пропускаем Label (индекс 0), берем TextureRect с 1 по 8
	for i in range(1, 9):
		var child = left_grid_container.get_child(i)
		if child is TextureRect:
			input_a_textures.append(child)

	# Input B (строка 1) - индексы 9-16
	for i in range(10, 18):
		var child = left_grid_container.get_child(i)
		if child is TextureRect:
			input_b_textures.append(child)

	# Input C (строка 2) - индексы 18-25
	for i in range(19, 27):
		var child = left_grid_container.get_child(i)
		if child is TextureRect:
			input_c_textures.append(child)

	# Desired Y0 (строка 3) - индексы 27-34
	for i in range(28, 36):
		var child = left_grid_container.get_child(i)
		if child is TextureRect:
			desired_y0_textures.append(child)

	# Desired Y1 (строка 4) - индексы 36-43
	for i in range(37, 45):
		var child = left_grid_container.get_child(i)
		if child is TextureRect:
			desired_y1_textures.append(child)

	# Desired Y2 (строка 5) - индексы 45-52
	for i in range(46, 54):
		var child = left_grid_container.get_child(i)
		if child is TextureRect:
			desired_y2_textures.append(child)

	# Desired Y3 (строка 6) - индексы 54-61
	for i in range(55, 63):
		var child = left_grid_container.get_child(i)
		if child is TextureRect:
			desired_y3_textures.append(child)

	# Desired Y4 (строка 7) - индексы 63-70
	for i in range(64, 72):
		var child = left_grid_container.get_child(i)
		if child is TextureRect:
			desired_y4_textures.append(child)

	# Desired Y5 (строка 8) - индексы 72-79
	for i in range(73, 81):
		var child = left_grid_container.get_child(i)
		if child is TextureRect:
			desired_y5_textures.append(child)

	# Desired Y6 (строка 9) - индексы 81-88
	for i in range(82, 90):
		var child = left_grid_container.get_child(i)
		if child is TextureRect:
			desired_y6_textures.append(child)

	# Desired Y7 (строка 10) - индексы 90-97
	for i in range(91, 99):
		var child = left_grid_container.get_child(i)
		if child is TextureRect:
			desired_y7_textures.append(child)

	# ПРАВАЯ ЧАСТЬ (Current Outputs) - 8 строк
	
	# Current Y0 (строка 0) - индексы 0-8 (пропускаем Label индекс 0, берем 1-8)
	for i in range(1, 9):
		var child = right_grid_container.get_child(i)
		if child is TextureRect:
			current_y0_textures.append(child)

	# Current Y1 (строка 1) - индексы 9-16
	for i in range(10, 18):
		var child = right_grid_container.get_child(i)
		if child is TextureRect:
			current_y1_textures.append(child)

	# Current Y2 (строка 2) - индексы 18-25
	for i in range(19, 27):
		var child = right_grid_container.get_child(i)
		if child is TextureRect:
			current_y2_textures.append(child)

	# Current Y3 (строка 3) - индексы 27-34
	for i in range(28, 36):
		var child = right_grid_container.get_child(i)
		if child is TextureRect:
			current_y3_textures.append(child)

	# Current Y4 (строка 4) - индексы 36-43
	for i in range(37, 45):
		var child = right_grid_container.get_child(i)
		if child is TextureRect:
			current_y4_textures.append(child)

	# Current Y5 (строка 5) - индексы 45-52
	for i in range(46, 54):
		var child = right_grid_container.get_child(i)
		if child is TextureRect:
			current_y5_textures.append(child)

	# Current Y6 (строка 6) - индексы 54-61
	for i in range(55, 63):
		var child = right_grid_container.get_child(i)
		if child is TextureRect:
			current_y6_textures.append(child)

	# Current Y7 (строка 7) - индексы 63-70
	for i in range(64, 72):
		var child = right_grid_container.get_child(i)
		if child is TextureRect:
			current_y7_textures.append(child)
	
	print("TestResultsPanelDecoder8: Successfully initialized with 11+8 structure")
	print("Left panel (11 rows): ", input_a_textures.size(), " A, ", input_b_textures.size(), " B, ", input_c_textures.size(), " C, ",
		  desired_y0_textures.size(), " desired Y0, ", desired_y1_textures.size(), " desired Y1, ",
		  desired_y2_textures.size(), " desired Y2, ", desired_y3_textures.size(), " desired Y3, ",
		  desired_y4_textures.size(), " desired Y4, ", desired_y5_textures.size(), " desired Y5, ",
		  desired_y6_textures.size(), " desired Y6, ", desired_y7_textures.size(), " desired Y7")
	print("Right panel (8 rows): ", current_y0_textures.size(), " current Y0, ",
		  current_y1_textures.size(), " current Y1, ", current_y2_textures.size(), " current Y2, ",
		  current_y3_textures.size(), " current Y3, ", current_y4_textures.size(), " current Y4, ",
		  current_y5_textures.size(), " current Y5, ", current_y6_textures.size(), " current Y6, ",
		  current_y7_textures.size(), " current Y7")

func load_initial_data(inputs_a, inputs_b, inputs_c, expected_y0, expected_y1, expected_y2, expected_y3, expected_y4, expected_y5, expected_y6, expected_y7):
	if (input_a_textures.is_empty() or input_b_textures.is_empty() or input_c_textures.is_empty()):
		print("ERROR: Input textures arrays are not initialized!")
		return
	
	print("Loading initial data for 3→8 decoder panel with new structure")
	
	# ЛЕВАЯ ЧАСТЬ: Inputs и Desired outputs (11 строк)
	
	# Input A
	for i in range(8):
		if i < input_a_textures.size():
			if inputs_a[i] == 1:
				input_a_textures[i].texture = load("res://assets/pointGreen.png")
			else:
				input_a_textures[i].texture = load("res://assets/point.png")
	
	# Input B
	for i in range(8):
		if i < input_b_textures.size():
			if inputs_b[i] == 1:
				input_b_textures[i].texture = load("res://assets/pointGreen.png")
			else:
				input_b_textures[i].texture = load("res://assets/point.png")
	
	# Input C
	for i in range(8):
		if i < input_c_textures.size():
			if inputs_c[i] == 1:
				input_c_textures[i].texture = load("res://assets/pointGreen.png")
			else:
				input_c_textures[i].texture = load("res://assets/point.png")
	
	# Desired outputs Y0-Y7
	load_desired_outputs(desired_y0_textures, expected_y0)
	load_desired_outputs(desired_y1_textures, expected_y1)
	load_desired_outputs(desired_y2_textures, expected_y2)
	load_desired_outputs(desired_y3_textures, expected_y3)
	load_desired_outputs(desired_y4_textures, expected_y4)
	load_desired_outputs(desired_y5_textures, expected_y5)
	load_desired_outputs(desired_y6_textures, expected_y6)
	load_desired_outputs(desired_y7_textures, expected_y7)
	
	# ПРАВАЯ ЧАСТЬ: Current outputs (очищаем) - 8 строк
	clear_current_outputs()
	
	print("TestResultsPanelDecoder8: Initial data loaded with 11+8 structure")

func load_desired_outputs(texture_array, expected_values):
	for i in range(8):
		if i < texture_array.size() and texture_array[i] is TextureRect:
			if expected_values[i] == 1:
				texture_array[i].texture = load("res://assets/pointGreen.png")
			else:
				texture_array[i].texture = load("res://assets/point.png")

func clear_current_outputs():
	# Очищаем все текущие выходы (ставим серые точки)
	for i in range(8):
		if i < current_y0_textures.size():
			current_y0_textures[i].texture = load("res://assets/point.png")
		if i < current_y1_textures.size():
			current_y1_textures[i].texture = load("res://assets/point.png")
		if i < current_y2_textures.size():
			current_y2_textures[i].texture = load("res://assets/point.png")
		if i < current_y3_textures.size():
			current_y3_textures[i].texture = load("res://assets/point.png")
		if i < current_y4_textures.size():
			current_y4_textures[i].texture = load("res://assets/point.png")
		if i < current_y5_textures.size():
			current_y5_textures[i].texture = load("res://assets/point.png")
		if i < current_y6_textures.size():
			current_y6_textures[i].texture = load("res://assets/point.png")
		if i < current_y7_textures.size():
			current_y7_textures[i].texture = load("res://assets/point.png")

func update_current_outputs(actual_y0, actual_y1, actual_y2, actual_y3, actual_y4, actual_y5, actual_y6, actual_y7):
	# Проверяем что массивы текущих выходов инициализированы
	if (current_y0_textures.is_empty() or current_y1_textures.is_empty() or
		current_y2_textures.is_empty() or current_y3_textures.is_empty() or
		current_y4_textures.is_empty() or current_y5_textures.is_empty() or
		current_y6_textures.is_empty() or current_y7_textures.is_empty()):
		print("ERROR: Current textures arrays are not initialized!")
		return
	
	print("Updating current outputs for 3→8 decoder in right panel")
	
	# ПРАВАЯ ЧАСТЬ: Обновляем Current outputs (8 строк)
	update_current_output(current_y0_textures, actual_y0)
	update_current_output(current_y1_textures, actual_y1)
	update_current_output(current_y2_textures, actual_y2)
	update_current_output(current_y3_textures, actual_y3)
	update_current_output(current_y4_textures, actual_y4)
	update_current_output(current_y5_textures, actual_y5)
	update_current_output(current_y6_textures, actual_y6)
	update_current_output(current_y7_textures, actual_y7)
	
	print("TestResultsPanelDecoder8: Current outputs updated successfully in right panel")

func update_current_output(texture_array, actual_values):
	for i in range(8):
		if i < texture_array.size() and texture_array[i] is TextureRect:
			if actual_values[i] == 1:
				texture_array[i].texture = load("res://assets/pointGreen.png")
			else:
				texture_array[i].texture = load("res://assets/point.png")
