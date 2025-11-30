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
	custom_minimum_size = Vector2(window_size.x, 170)
	size = Vector2(window_size.x, 170)
	position = Vector2(0, window_size.y - 170)
	
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
	# Левый GridContainer (6 строк) - Inputs & Desired
	var left_grid_container = get_node_or_null("Background/MainContainer/LeftColumn/GridContainer")
	if not left_grid_container:
		print("ERROR: Left GridContainer not found!")
		return

	var left_total_children = left_grid_container.get_child_count()
	print("Left GridContainer has ", left_total_children, " children")

	var left_rows = 6
	var left_columns = 5
	var test_cases = 4

	input_a_textures = []
	input_b_textures = []
	desired_y0_textures = []
	desired_y1_textures = []
	desired_y2_textures = []
	desired_y3_textures = []

	# Заполняем левый GridContainer (6 строк)
	for i in range(test_cases):
		var tex = get_texture_rect_internal(left_grid_container, left_total_children, left_columns, 0, i + 1)
		if tex: input_a_textures.append(tex)

		tex = get_texture_rect_internal(left_grid_container, left_total_children, left_columns, 1, i + 1)
		if tex: input_b_textures.append(tex)

		tex = get_texture_rect_internal(left_grid_container, left_total_children, left_columns, 2, i + 1)
		if tex: desired_y0_textures.append(tex)
		
		tex = get_texture_rect_internal(left_grid_container, left_total_children, left_columns, 3, i + 1)
		if tex: desired_y1_textures.append(tex)

		tex = get_texture_rect_internal(left_grid_container, left_total_children, left_columns, 4, i + 1)
		if tex: desired_y2_textures.append(tex)
		
		tex = get_texture_rect_internal(left_grid_container, left_total_children, left_columns, 5, i + 1)
		if tex: desired_y3_textures.append(tex)

	# Правый GridContainer (4 строки) - Current Outputs
	var right_grid_container = get_node_or_null("Background/MainContainer/RightColumn/GridContainer")
	if not right_grid_container:
		print("ERROR: Right GridContainer not found!")
		return

	var right_total_children = right_grid_container.get_child_count()
	print("Right GridContainer has ", right_total_children, " children")

	var right_rows = 4
	var right_columns = 5

	current_y0_textures = []
	current_y1_textures = []
	current_y2_textures = []
	current_y3_textures = []

	# Заполняем правый GridContainer (4 строки)
	for i in range(test_cases):
		var tex = get_texture_rect_internal(right_grid_container, right_total_children, right_columns, 0, i + 1)
		if tex: current_y0_textures.append(tex)
		
		tex = get_texture_rect_internal(right_grid_container, right_total_children, right_columns, 1, i + 1)
		if tex: current_y1_textures.append(tex)
		
		tex = get_texture_rect_internal(right_grid_container, right_total_children, right_columns, 2, i + 1)
		if tex: current_y2_textures.append(tex)
		
		tex = get_texture_rect_internal(right_grid_container, right_total_children, right_columns, 3, i + 1)
		if tex: current_y3_textures.append(tex)
	
	print("TestResultsPanelDecoder: Successfully initialized with")
	print("  Input A: ", input_a_textures.size())
	print("  Input B: ", input_b_textures.size())
	print("  Desired Y0: ", desired_y0_textures.size())
	print("  Desired Y1: ", desired_y1_textures.size())
	print("  Desired Y2: ", desired_y2_textures.size())
	print("  Desired Y3: ", desired_y3_textures.size())
	print("  Current Y0: ", current_y0_textures.size())
	print("  Current Y1: ", current_y1_textures.size())
	print("  Current Y2: ", current_y2_textures.size())
	print("  Current Y3: ", current_y3_textures.size())

func load_initial_data(inputs_a, inputs_b, expected_y0, expected_y1, expected_y2, expected_y3):
	if input_a_textures.is_empty():
		print("ERROR: Textures arrays are not initialized!")
		initialize_textures()
		if input_a_textures.is_empty():
			return
	
	var test_cases = min(4, input_a_textures.size())
	print("Loading initial data for ", test_cases, " test cases")
	
	# Левый столбец - входы и ожидаемые выходы
	for i in range(test_cases):
		update_texture(input_a_textures[i], inputs_a[i] if i < inputs_a.size() else 0)
		update_texture(input_b_textures[i], inputs_b[i] if i < inputs_b.size() else 0)
		update_texture(desired_y0_textures[i], expected_y0[i] if i < expected_y0.size() else 0)
		update_texture(desired_y1_textures[i], expected_y1[i] if i < expected_y1.size() else 0)
		update_texture(desired_y2_textures[i], expected_y2[i] if i < expected_y2.size() else 0)
		update_texture(desired_y3_textures[i], expected_y3[i] if i < expected_y3.size() else 0)
	
	# Правый столбец - текущие выходы (сбрасываем)
	for i in range(test_cases):
		update_texture(current_y0_textures[i] if i < current_y0_textures.size() else null, 0)
		update_texture(current_y1_textures[i] if i < current_y1_textures.size() else null, 0)
		update_texture(current_y2_textures[i] if i < current_y2_textures.size() else null, 0)
		update_texture(current_y3_textures[i] if i < current_y3_textures.size() else null, 0)
	
	print("TestResultsPanelDecoder: Initial data loaded for ", test_cases, " test cases")

func update_current_outputs(actual_y0, actual_y1, actual_y2, actual_y3):
	if current_y0_textures.is_empty():
		print("ERROR: Current textures arrays are not initialized!")
		initialize_textures()
		if current_y0_textures.is_empty():
			print("CRITICAL: Still cannot initialize current textures!")
			return

	var test_cases = min(4, current_y0_textures.size())
	print("Updating current outputs for ", test_cases, " test cases")

	# Обновляем только правый столбец (текущие выходы)
	for i in range(test_cases):
		update_texture(current_y0_textures[i], actual_y0[i] if i < actual_y0.size() else 0)
		update_texture(current_y1_textures[i], actual_y1[i] if i < actual_y1.size() else 0)
		update_texture(current_y2_textures[i], actual_y2[i] if i < actual_y2.size() else 0)
		update_texture(current_y3_textures[i], actual_y3[i] if i < actual_y3.size() else 0)
	
	print("TestResultsPanelDecoder: Current outputs updated for ", test_cases, " test cases")

func update_texture(texture_rect, value):
	if texture_rect and is_instance_valid(texture_rect):
		if value == 1:
			texture_rect.texture = preload("res://assets/pointGreen.png")
		else:
			texture_rect.texture = preload("res://assets/point.png")
