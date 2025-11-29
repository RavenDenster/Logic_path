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

func get_texture_rect_internal(grid_container, row, col):
	# Для GridContainer с 17 колонками (1 заголовок + 16 тестов)
	var index = row * 17 + col
	if index < grid_container.get_child_count():
		var child = grid_container.get_child(index)
		if child is TextureRect:
			return child
	return null

func initialize_textures():
	print("=== Initializing TestResultsPanel2BitComparator ===")
	
	# Первый HBoxContainer (Inputs & Expected)
	var hbox1 = get_node_or_null("Background/HBoxContainer")
	if not hbox1:
		print("ERROR: HBoxContainer not found!")
		return

	var grid1 = hbox1.get_node_or_null("GridContainer")
	if not grid1:
		print("ERROR: First GridContainer not found!")
		return

	var grid1_children = grid1.get_child_count()
	print("First GridContainer has ", grid1_children, " children")

	# Второй HBoxContainer (Current Outputs)
	var hbox2 = get_node_or_null("Background/HBoxContainer2")
	if not hbox2:
		print("ERROR: HBoxContainer2 not found!")
		return

	var grid2 = hbox2.get_node_or_null("GridContainer")
	if not grid2:
		print("ERROR: Second GridContainer not found!")
		return

	var grid2_children = grid2.get_child_count()
	print("Second GridContainer has ", grid2_children, " children")

	# Инициализируем массивы
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

	var test_cases = 16

	# Заполняем первый GridContainer (7 строк - Inputs & Expected)
	for i in range(test_cases):
		# Строка 0: Input A1
		var tex = get_texture_rect_internal(grid1, 0, i + 1)
		if tex: input_a1_textures.append(tex)

		# Строка 1: Input A0
		tex = get_texture_rect_internal(grid1, 1, i + 1)
		if tex: input_a0_textures.append(tex)

		# Строка 2: Input B1
		tex = get_texture_rect_internal(grid1, 2, i + 1)
		if tex: input_b1_textures.append(tex)
		
		# Строка 3: Input B0
		tex = get_texture_rect_internal(grid1, 3, i + 1)
		if tex: input_b0_textures.append(tex)

		# Строка 4: Desired A>B
		tex = get_texture_rect_internal(grid1, 4, i + 1)
		if tex: desired_agtb_textures.append(tex)
		
		# Строка 5: Desired A<B
		tex = get_texture_rect_internal(grid1, 5, i + 1)
		if tex: desired_altb_textures.append(tex)
		
		# Строка 6: Desired A==B
		tex = get_texture_rect_internal(grid1, 6, i + 1)
		if tex: desired_aeqb_textures.append(tex)

	# Заполняем второй GridContainer (3 строки - Current Outputs)
	for i in range(test_cases):
		# Строка 0: Current A>B
		var tex = get_texture_rect_internal(grid2, 0, i + 1)
		if tex: current_agtb_textures.append(tex)
		
		# Строка 1: Current A<B
		tex = get_texture_rect_internal(grid2, 1, i + 1)
		if tex: current_altb_textures.append(tex)
		
		# Строка 2: Current A==B
		tex = get_texture_rect_internal(grid2, 2, i + 1)
		if tex: current_aeqb_textures.append(tex)
	
	print("TestResultsPanel2BitComparator: Successfully initialized with")
	print("  Input A1: ", input_a1_textures.size())
	print("  Input A0: ", input_a0_textures.size())
	print("  Input B1: ", input_b1_textures.size())
	print("  Input B0: ", input_b0_textures.size())
	print("  Expected A>B: ", desired_agtb_textures.size())
	print("  Expected A<B: ", desired_altb_textures.size())
	print("  Expected A==B: ", desired_aeqb_textures.size())
	print("  Current A>B: ", current_agtb_textures.size())
	print("  Current A<B: ", current_altb_textures.size())
	print("  Current A==B: ", current_aeqb_textures.size())

func load_initial_data(inputs_a1, inputs_a0, inputs_b1, inputs_b0, expected_agtb, expected_altb, expected_aeqb):
	if input_a1_textures.is_empty():
		print("ERROR: Textures arrays are not initialized!")
		initialize_textures()
		if input_a1_textures.is_empty():
			return
	
	var test_cases = min(16, input_a1_textures.size())
	print("TestResultsPanel2BitComparator: Loading initial data for ", test_cases, " test cases")
	
	# Заполняем входы и ожидаемые выходы (первый GridContainer)
	for i in range(test_cases):
		update_texture(input_a1_textures[i], inputs_a1[i] if i < inputs_a1.size() else 0)
		update_texture(input_a0_textures[i], inputs_a0[i] if i < inputs_a0.size() else 0)
		update_texture(input_b1_textures[i], inputs_b1[i] if i < inputs_b1.size() else 0)
		update_texture(input_b0_textures[i], inputs_b0[i] if i < inputs_b0.size() else 0)
		update_texture(desired_agtb_textures[i], expected_agtb[i] if i < expected_agtb.size() else 0)
		update_texture(desired_altb_textures[i], expected_altb[i] if i < expected_altb.size() else 0)
		update_texture(desired_aeqb_textures[i], expected_aeqb[i] if i < expected_aeqb.size() else 0)
	
	# Сбрасываем текущие выходы (второй GridContainer)
	for i in range(test_cases):
		update_texture(current_agtb_textures[i] if i < current_agtb_textures.size() else null, 0)
		update_texture(current_altb_textures[i] if i < current_altb_textures.size() else null, 0)
		update_texture(current_aeqb_textures[i] if i < current_aeqb_textures.size() else null, 0)
	
	print("TestResultsPanel2BitComparator: Initial data loaded for ", test_cases, " test cases")

func update_current_outputs(actual_agtb, actual_altb, actual_aeqb):
	if current_agtb_textures.is_empty():
		print("ERROR: Current textures arrays are not initialized!")
		initialize_textures()
		if current_agtb_textures.is_empty():
			print("CRITICAL: Still cannot initialize current textures!")
			return

	var test_cases = min(16, current_agtb_textures.size())
	print("TestResultsPanel2BitComparator: Updating current outputs for ", test_cases, " test cases")

	# Обновляем только второй GridContainer (текущие выходы)
	for i in range(test_cases):
		update_texture(current_agtb_textures[i], actual_agtb[i] if i < actual_agtb.size() else 0)
		update_texture(current_altb_textures[i], actual_altb[i] if i < actual_altb.size() else 0)
		update_texture(current_aeqb_textures[i], actual_aeqb[i] if i < actual_aeqb.size() else 0)
	
	print("TestResultsPanel2BitComparator: Current outputs updated for ", test_cases, " test cases")

func update_texture(texture_rect, value):
	if texture_rect and is_instance_valid(texture_rect):
		if value == 1:
			texture_rect.texture = load("res://assets/pointGreen.png")
		else:
			texture_rect.texture = load("res://assets/point.png")
