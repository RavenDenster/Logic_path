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
	# Ждем два кадра, чтобы окно точно было инициализировано
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Устанавливаем правильную позицию и размер при инициализации
	_update_panel_position()
	
	# Подписываемся на изменение размера окна
	get_tree().root.connect("size_changed", _on_window_size_changed)
	
	initialize_textures()

func _update_panel_position():
	var window_size = get_viewport_rect().size
	custom_minimum_size = Vector2(window_size.x, 220)
	size = Vector2(window_size.x, 220)
	position = Vector2(0, window_size.y - 220)
	
	# Центрируем содержимое панели
	_center_panel_content()
	
	queue_redraw()

func _center_panel_content():
	var background = $Background
	var main_container = background.get_node_or_null("MainContainer")
	
	if main_container:
		# Центрируем MainContainer по горизонтали
		main_container.position.x = (background.size.x - main_container.size.x) / 2

func _on_window_size_changed():
	_update_panel_position()

func get_texture_rect_internal(grid_container, total_children, columns, row, col):
	var index = row * columns + col
	if index < total_children:
		var child = grid_container.get_child(index)
		if child is TextureRect:
			return child
	return null

func initialize_textures():
	print("=== Initializing TestResultsPanel2BitComparator ===")
	
	# Первый GridContainer (Inputs & Expected)
	var grid1 = get_node_or_null("Background/MainContainer/LeftColumn/GridContainer")
	if not grid1:
		print("ERROR: First GridContainer not found!")
		return

	var grid1_children = grid1.get_child_count()
	print("First GridContainer has ", grid1_children, " children")

	# Второй GridContainer (Current Outputs)
	var grid2 = get_node_or_null("Background/MainContainer/RightColumn/GridContainer")
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
	var columns = 17

	# Заполняем первый GridContainer (7 строк - Inputs & Expected)
	for i in range(test_cases):
		# Строка 0: Input A1
		var tex = get_texture_rect_internal(grid1, grid1_children, columns, 0, i + 1)
		if tex: 
			input_a1_textures.append(tex)
		else:
			print("WARNING: Could not find TextureRect for A1 at index ", i)

		# Строка 1: Input A0
		tex = get_texture_rect_internal(grid1, grid1_children, columns, 1, i + 1)
		if tex: 
			input_a0_textures.append(tex)
		else:
			print("WARNING: Could not find TextureRect for A0 at index ", i)

		# Строка 2: Input B1
		tex = get_texture_rect_internal(grid1, grid1_children, columns, 2, i + 1)
		if tex: 
			input_b1_textures.append(tex)
		else:
			print("WARNING: Could not find TextureRect for B1 at index ", i)
		
		# Строка 3: Input B0
		tex = get_texture_rect_internal(grid1, grid1_children, columns, 3, i + 1)
		if tex: 
			input_b0_textures.append(tex)
		else:
			print("WARNING: Could not find TextureRect for B0 at index ", i)

		# Строка 4: Desired A>B
		tex = get_texture_rect_internal(grid1, grid1_children, columns, 4, i + 1)
		if tex: 
			desired_agtb_textures.append(tex)
		else:
			print("WARNING: Could not find TextureRect for Desired A>B at index ", i)
		
		# Строка 5: Desired A<B
		tex = get_texture_rect_internal(grid1, grid1_children, columns, 5, i + 1)
		if tex: 
			desired_altb_textures.append(tex)
		else:
			print("WARNING: Could not find TextureRect for Desired A<B at index ", i)
		
		# Строка 6: Desired A==B
		tex = get_texture_rect_internal(grid1, grid1_children, columns, 6, i + 1)
		if tex: 
			desired_aeqb_textures.append(tex)
		else:
			print("WARNING: Could not find TextureRect for Desired A==B at index ", i)

	# Заполняем второй GridContainer (3 строки - Current Outputs)
	for i in range(test_cases):
		# Строка 0: Current A>B
		var tex = get_texture_rect_internal(grid2, grid2_children, columns, 0, i + 1)
		if tex: 
			current_agtb_textures.append(tex)
		else:
			print("WARNING: Could not find TextureRect for Current A>B at index ", i)
		
		# Строка 1: Current A<B
		tex = get_texture_rect_internal(grid2, grid2_children, columns, 1, i + 1)
		if tex: 
			current_altb_textures.append(tex)
		else:
			print("WARNING: Could not find TextureRect for Current A<B at index ", i)
		
		# Строка 2: Current A==B
		tex = get_texture_rect_internal(grid2, grid2_children, columns, 2, i + 1)
		if tex: 
			current_aeqb_textures.append(tex)
		else:
			print("WARNING: Could not find TextureRect for Current A==B at index ", i)
	
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
	# Переинициализируем текстуры, если они пусты
	if input_a1_textures.is_empty():
		print("WARNING: Textures arrays are empty, reinitializing...")
		initialize_textures()
		if input_a1_textures.is_empty():
			print("ERROR: Still cannot initialize textures after retry!")
			return
	
	var test_cases = min(16, input_a1_textures.size(), input_a0_textures.size(), input_b1_textures.size(), input_b0_textures.size())
	print("TestResultsPanel2BitComparator: Loading initial data for ", test_cases, " test cases")
	
	# Заполняем входы и ожидаемые выходы (первый GridContainer)
	for i in range(test_cases):
		if i < input_a1_textures.size():
			update_texture(input_a1_textures[i], inputs_a1[i] if i < inputs_a1.size() else 0)
		if i < input_a0_textures.size():
			update_texture(input_a0_textures[i], inputs_a0[i] if i < inputs_a0.size() else 0)
		if i < input_b1_textures.size():
			update_texture(input_b1_textures[i], inputs_b1[i] if i < inputs_b1.size() else 0)
		if i < input_b0_textures.size():
			update_texture(input_b0_textures[i], inputs_b0[i] if i < inputs_b0.size() else 0)
		if i < desired_agtb_textures.size():
			update_texture(desired_agtb_textures[i], expected_agtb[i] if i < expected_agtb.size() else 0)
		if i < desired_altb_textures.size():
			update_texture(desired_altb_textures[i], expected_altb[i] if i < expected_altb.size() else 0)
		if i < desired_aeqb_textures.size():
			update_texture(desired_aeqb_textures[i], expected_aeqb[i] if i < expected_aeqb.size() else 0)
	
	# Сбрасываем текущие выходы (второй GridContainer)
	for i in range(test_cases):
		if i < current_agtb_textures.size():
			update_texture(current_agtb_textures[i], 0)
		if i < current_altb_textures.size():
			update_texture(current_altb_textures[i], 0)
		if i < current_aeqb_textures.size():
			update_texture(current_aeqb_textures[i], 0)
	
	print("TestResultsPanel2BitComparator: Initial data loaded for ", test_cases, " test cases")

func update_current_outputs(actual_agtb, actual_altb, actual_aeqb):
	if current_agtb_textures.is_empty():
		print("WARNING: Current textures arrays are empty, reinitializing...")
		initialize_textures()
		if current_agtb_textures.is_empty():
			print("ERROR: Still cannot initialize current textures after retry!")
			return

	var test_cases = min(16, current_agtb_textures.size(), current_altb_textures.size(), current_aeqb_textures.size())
	print("TestResultsPanel2BitComparator: Updating current outputs for ", test_cases, " test cases")

	# Обновляем только второй GridContainer (текущие выходы)
	for i in range(test_cases):
		if i < current_agtb_textures.size():
			update_texture(current_agtb_textures[i], actual_agtb[i] if i < actual_agtb.size() else 0)
		if i < current_altb_textures.size():
			update_texture(current_altb_textures[i], actual_altb[i] if i < actual_altb.size() else 0)
		if i < current_aeqb_textures.size():
			update_texture(current_aeqb_textures[i], actual_aeqb[i] if i < actual_aeqb.size() else 0)
	
	print("TestResultsPanel2BitComparator: Current outputs updated for ", test_cases, " test cases")

func update_texture(texture_rect, value):
	if texture_rect and is_instance_valid(texture_rect):
		if value == 1:
			texture_rect.texture = load("res://assets/pointGreen.png")
		else:
			texture_rect.texture = load("res://assets/point.png")
