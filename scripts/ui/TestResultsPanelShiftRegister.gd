extends Control

var input_data_textures = []
var input_clk_textures = []
var expected_q0_textures = []
var expected_q1_textures = []
var expected_q2_textures = []
var expected_q3_textures = []
var current_q0_textures = []
var current_q1_textures = []
var current_q2_textures = []
var current_q3_textures = []

func _ready():
	await get_tree().process_frame
	initialize_textures()

func initialize_textures():
	if not has_node("Background/GridContainer"):
		print("ERROR: Background/GridContainer not found!")
		return

	var grid_container = $Background/GridContainer
	var child_count = grid_container.get_child_count()
	print("GridContainer has ", child_count, " children")
	
	if child_count < 60:  # 10 строк × 6 элементов
		print("ERROR: GridContainer has only ", child_count, " children, expected 60")
		return

	# Очищаем все массивы
	input_data_textures.clear()
	input_clk_textures.clear()
	expected_q0_textures.clear()
	expected_q1_textures.clear()
	expected_q2_textures.clear()
	expected_q3_textures.clear()
	current_q0_textures.clear()
	current_q1_textures.clear()
	current_q2_textures.clear()
	current_q3_textures.clear()
	
	# Собираем текстуры по строкам
	for row in range(10):  # 10 строк
		var row_start_index = row * 6  # 6 элементов в строке
		
		for col in range(1, 6):  # Пропускаем первый элемент (Label), берем столбцы 1-5
			var index = row_start_index + col
			if index < child_count:
				var child = grid_container.get_child(index)
				if child is TextureRect:
					match row:
						0: input_data_textures.append(child)    # Input Data
						1: input_clk_textures.append(child)     # Input CLK
						2: expected_q0_textures.append(child)   # Expected Q0
						3: expected_q1_textures.append(child)   # Expected Q1
						4: expected_q2_textures.append(child)   # Expected Q2
						5: expected_q3_textures.append(child)   # Expected Q3
						6: current_q0_textures.append(child)    # Current Q0
						7: current_q1_textures.append(child)    # Current Q1
						8: current_q2_textures.append(child)    # Current Q2
						9: current_q3_textures.append(child)    # Current Q3
	
	print("TestResultsPanelShiftRegister: Successfully initialized textures")
	print("  Input Data: ", input_data_textures.size())
	print("  Input CLK: ", input_clk_textures.size())
	print("  Expected Q0: ", expected_q0_textures.size())
	print("  Expected Q1: ", expected_q1_textures.size())
	print("  Expected Q2: ", expected_q2_textures.size())
	print("  Expected Q3: ", expected_q3_textures.size())
	print("  Current Q0: ", current_q0_textures.size())
	print("  Current Q1: ", current_q1_textures.size())
	print("  Current Q2: ", current_q2_textures.size())
	print("  Current Q3: ", current_q3_textures.size())

func load_initial_data(input_data, input_clk, expected_q0, expected_q1, expected_q2, expected_q3):
	if input_data_textures.is_empty():
		print("ERROR: Textures arrays are not initialized!")
		return
	
	# Input Data
	for i in range(5):
		if i < input_data_textures.size() and input_data_textures[i] is TextureRect:
			input_data_textures[i].texture = preload("res://assets/pointGreen.png") if input_data[i] == 1 else preload("res://assets/point.png")

	# Input CLK
	for i in range(5):
		if i < input_clk_textures.size() and input_clk_textures[i] is TextureRect:
			input_clk_textures[i].texture = preload("res://assets/pointGreen.png") if input_clk[i] == 1 else preload("res://assets/point.png")
	
	# Expected Q0
	for i in range(5):
		if i < expected_q0_textures.size() and expected_q0_textures[i] is TextureRect:
			expected_q0_textures[i].texture = preload("res://assets/pointGreen.png") if expected_q0[i] == 1 else preload("res://assets/point.png")

	# Expected Q1
	for i in range(5):
		if i < expected_q1_textures.size() and expected_q1_textures[i] is TextureRect:
			expected_q1_textures[i].texture = preload("res://assets/pointGreen.png") if expected_q1[i] == 1 else preload("res://assets/point.png")

	# Expected Q2
	for i in range(5):
		if i < expected_q2_textures.size() and expected_q2_textures[i] is TextureRect:
			expected_q2_textures[i].texture = preload("res://assets/pointGreen.png") if expected_q2[i] == 1 else preload("res://assets/point.png")

	# Expected Q3
	for i in range(5):
		if i < expected_q3_textures.size() and expected_q3_textures[i] is TextureRect:
			expected_q3_textures[i].texture = preload("res://assets/pointGreen.png") if expected_q3[i] == 1 else preload("res://assets/point.png")

	# Current Q0-Q3 (очищаем)
	for i in range(5):
		if i < current_q0_textures.size() and current_q0_textures[i] is TextureRect:
			current_q0_textures[i].texture = preload("res://assets/point.png")
		if i < current_q1_textures.size() and current_q1_textures[i] is TextureRect:
			current_q1_textures[i].texture = preload("res://assets/point.png")
		if i < current_q2_textures.size() and current_q2_textures[i] is TextureRect:
			current_q2_textures[i].texture = preload("res://assets/point.png")
		if i < current_q3_textures.size() and current_q3_textures[i] is TextureRect:
			current_q3_textures[i].texture = preload("res://assets/point.png")
	
	print("TestResultsPanelShiftRegister: Initial data loaded")

func update_current_outputs(actual_q0, actual_q1, actual_q2, actual_q3):
	if current_q0_textures.is_empty():
		print("ERROR: Current textures arrays are not initialized!")
		return

	# Current Q0
	for i in range(5):
		if i < current_q0_textures.size() and current_q0_textures[i] is TextureRect:
			current_q0_textures[i].texture = preload("res://assets/pointGreen.png") if actual_q0[i] == 1 else preload("res://assets/point.png")

	# Current Q1
	for i in range(5):
		if i < current_q1_textures.size() and current_q1_textures[i] is TextureRect:
			current_q1_textures[i].texture = preload("res://assets/pointGreen.png") if actual_q1[i] == 1 else preload("res://assets/point.png")

	# Current Q2
	for i in range(5):
		if i < current_q2_textures.size() and current_q2_textures[i] is TextureRect:
			current_q2_textures[i].texture = preload("res://assets/pointGreen.png") if actual_q2[i] == 1 else preload("res://assets/point.png")

	# Current Q3
	for i in range(5):
		if i < current_q3_textures.size() and current_q3_textures[i] is TextureRect:
			current_q3_textures[i].texture = preload("res://assets/pointGreen.png") if actual_q3[i] == 1 else preload("res://assets/point.png")
	
	print("TestResultsPanelShiftRegister: Current outputs updated")
