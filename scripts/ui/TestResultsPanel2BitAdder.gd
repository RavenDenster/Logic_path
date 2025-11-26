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
	# Левый GridContainer (7 строк) - Inputs & Expected
	var left_grid_container = get_node_or_null("Background/VBoxContainer/GridContainer")
	if not left_grid_container:
		print("ERROR: Left GridContainer not found!")
		return

	var left_total_children = left_grid_container.get_child_count()
	print("Left GridContainer has ", left_total_children, " children")

	var left_rows = 7
	var left_columns = 17
	var test_cases = 16

	input_a1_textures = []
	input_a0_textures = []
	input_b1_textures = []
	input_b0_textures = []
	desired_s1_textures = []
	desired_s0_textures = []
	desired_cout_textures = []

	# Заполняем левый GridContainer (7 строк)
	for i in range(test_cases):
		var tex = get_texture_rect_internal(left_grid_container, left_total_children, left_columns, 0, i + 1)
		if tex: input_a1_textures.append(tex)

		tex = get_texture_rect_internal(left_grid_container, left_total_children, left_columns, 1, i + 1)
		if tex: input_a0_textures.append(tex)

		tex = get_texture_rect_internal(left_grid_container, left_total_children, left_columns, 2, i + 1)
		if tex: input_b1_textures.append(tex)
		
		tex = get_texture_rect_internal(left_grid_container, left_total_children, left_columns, 3, i + 1)
		if tex: input_b0_textures.append(tex)

		tex = get_texture_rect_internal(left_grid_container, left_total_children, left_columns, 4, i + 1)
		if tex: desired_s1_textures.append(tex)
		
		tex = get_texture_rect_internal(left_grid_container, left_total_children, left_columns, 5, i + 1)
		if tex: desired_s0_textures.append(tex)
		
		tex = get_texture_rect_internal(left_grid_container, left_total_children, left_columns, 6, i + 1)
		if tex: desired_cout_textures.append(tex)

	# Правый GridContainer (3 строки) - Current Outputs
	var right_grid_container = get_node_or_null("Background/VBoxContainer2/GridContainer")
	if not right_grid_container:
		print("ERROR: Right GridContainer (VBoxContainer2) not found!")
		# Попробуем найти в старом расположении
		right_grid_container = get_node_or_null("Background/HBoxContainer/RightColumn/RightGridContainer")
		if not right_grid_container:
			print("ERROR: No Right GridContainer found at all!")
			return

	var right_total_children = right_grid_container.get_child_count()
	print("Right GridContainer has ", right_total_children, " children")

	var right_rows = 3
	var right_columns = 17

	current_s1_textures = []
	current_s0_textures = []
	current_cout_textures = []

	# Заполняем правый GridContainer (3 строки)
	for i in range(test_cases):
		var tex = get_texture_rect_internal(right_grid_container, right_total_children, right_columns, 0, i + 1)
		if tex: current_s1_textures.append(tex)
		
		tex = get_texture_rect_internal(right_grid_container, right_total_children, right_columns, 1, i + 1)
		if tex: current_s0_textures.append(tex)
		
		tex = get_texture_rect_internal(right_grid_container, right_total_children, right_columns, 2, i + 1)
		if tex: current_cout_textures.append(tex)
	
	print("TestResultsPanel2BitAdder: Successfully initialized with")
	print("  Input A1: ", input_a1_textures.size())
	print("  Input A0: ", input_a0_textures.size())
	print("  Input B1: ", input_b1_textures.size())
	print("  Input B0: ", input_b0_textures.size())
	print("  Expected S1: ", desired_s1_textures.size())
	print("  Expected S0: ", desired_s0_textures.size())
	print("  Expected Cout: ", desired_cout_textures.size())
	print("  Current S1: ", current_s1_textures.size())
	print("  Current S0: ", current_s0_textures.size())
	print("  Current Cout: ", current_cout_textures.size())

func load_initial_data(inputs_a1, inputs_a0, inputs_b1, inputs_b0, expected_s1, expected_s0, expected_cout):
	if input_a1_textures.is_empty():
		print("ERROR: Textures arrays are not initialized!")
		initialize_textures()
		if input_a1_textures.is_empty():
			return
	
	var test_cases = min(16, input_a1_textures.size())
	print("Loading initial data for ", test_cases, " test cases")
	
	# Левый столбец - входы и ожидаемые выходы
	for i in range(test_cases):
		update_texture(input_a1_textures[i], inputs_a1[i] if i < inputs_a1.size() else 0)
		update_texture(input_a0_textures[i], inputs_a0[i] if i < inputs_a0.size() else 0)
		update_texture(input_b1_textures[i], inputs_b1[i] if i < inputs_b1.size() else 0)
		update_texture(input_b0_textures[i], inputs_b0[i] if i < inputs_b0.size() else 0)
		update_texture(desired_s1_textures[i], expected_s1[i] if i < expected_s1.size() else 0)
		update_texture(desired_s0_textures[i], expected_s0[i] if i < expected_s0.size() else 0)
		update_texture(desired_cout_textures[i], expected_cout[i] if i < expected_cout.size() else 0)
	
	# Правый столбец - текущие выходы (сбрасываем)
	for i in range(test_cases):
		update_texture(current_s1_textures[i] if i < current_s1_textures.size() else null, 0)
		update_texture(current_s0_textures[i] if i < current_s0_textures.size() else null, 0)
		update_texture(current_cout_textures[i] if i < current_cout_textures.size() else null, 0)
	
	print("TestResultsPanel2BitAdder: Initial data loaded for ", test_cases, " test cases")

func update_current_outputs(actual_s1, actual_s0, actual_cout):
	if current_s1_textures.is_empty():
		print("ERROR: Current textures arrays are not initialized!")
		initialize_textures()
		if current_s1_textures.is_empty():
			print("CRITICAL: Still cannot initialize current textures!")
			return

	var test_cases = min(16, current_s1_textures.size())
	print("Updating current outputs for ", test_cases, " test cases")

	# Обновляем только правый столбец (текущие выходы)
	for i in range(test_cases):
		update_texture(current_s1_textures[i], actual_s1[i] if i < actual_s1.size() else 0)
		update_texture(current_s0_textures[i], actual_s0[i] if i < actual_s0.size() else 0)
		update_texture(current_cout_textures[i], actual_cout[i] if i < actual_cout.size() else 0)
	
	print("TestResultsPanel2BitAdder: Current outputs updated for ", test_cases, " test cases")

func update_texture(texture_rect, value):
	if texture_rect and is_instance_valid(texture_rect):
		if value == 1:
			texture_rect.texture = preload("res://assets/pointGreen.png")
		else:
			texture_rect.texture = preload("res://assets/point.png")
