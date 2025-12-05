# TestResultsPanelDLatch.gd
extends Control

var input_d_textures = []
var input_enable_textures = []
var desired_q_textures = []
var current_q_textures = []

# Добавляем переменные для Label
var desired_q_label: Label
var current_q_label: Label

func _ready():
	# Устанавливаем якоря для привязки к низу экрана
	anchor_left = 0.0
	anchor_right = 1.0
	anchor_top = 1.0
	anchor_bottom = 1.0
	
	# Обновляем позицию панели
	_update_panel_position()

	# Устанавливаем фиксированную высоту панели
	custom_minimum_size = Vector2(0, 150)  # Высота 150 пикселей (меньше, т.к. 4 строки)
	
	var viewport_size = get_viewport_rect().size
	size = Vector2(viewport_size.x, 150)
	
	# Подписываемся на изменение размера окна
	get_tree().root.connect("size_changed", _on_window_size_changed)
	
	await get_tree().process_frame
	initialize_textures()

func _update_panel_position():
	var window_size = get_viewport_rect().size
	custom_minimum_size = Vector2(window_size.x, 150)
	size = Vector2(window_size.x, 150)
	position = Vector2(0, window_size.y - 150)
	queue_redraw()

func _on_window_size_changed():
	# Обновляем размер панели при изменении размера окна
	var window_size = get_viewport_rect().size
	custom_minimum_size = Vector2(window_size.x, 150)
	size = Vector2(window_size.x, 150)
	position = Vector2(0, window_size.y - 150)
	
	# Принудительно обновляем layout
	queue_redraw()
func initialize_textures():
	if not has_node("Background/GridContainer"):
		print("ERROR: Background/GridContainer not found!")
		return
	
	var grid_container = $Background/GridContainer
	
	if grid_container.get_child_count() < 36: # 4 строки × 9 элементов
		print("ERROR: GridContainer has only ", grid_container.get_child_count(), " children, expected 36")
		return
	
	# Получаем ссылки на заголовки ВСЕХ строк
	var input_d_label = grid_container.get_child(0) as Label  # "Input D" (строка 0, колонка 0)
	var input_enable_label = grid_container.get_child(9) as Label  # "Input Enable" (строка 1, колонка 0)
	desired_q_label = grid_container.get_child(18) as Label  # "Desired Q" (строка 2, колонка 0)
	current_q_label = grid_container.get_child(27) as Label  # "Current Q" (строка 3, колонка 0)
	
	print("DLatch Label search results:")
	print("  Input D: ", input_d_label != null, " text: '", input_d_label.text if input_d_label else "'")
	print("  Input Enable: ", input_enable_label != null, " text: '", input_enable_label.text if input_enable_label else "'")
	print("  Desired Q: ", desired_q_label != null, " text: '", desired_q_label.text if desired_q_label else "'")
	print("  Current Q: ", current_q_label != null, " text: '", current_q_label.text if current_q_label else "'")
	
	# Сохраняем ссылки в свойствах панели для доступа из других скриптов
	if input_d_label:
		set_meta("input_d_label", input_d_label)
	if input_enable_label:
		set_meta("input_enable_label", input_enable_label)
	if desired_q_label:
		set_meta("desired_q_label", desired_q_label)
	if current_q_label:
		set_meta("current_q_label", current_q_label)
	
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

# Добавляем метод для сброса всех подсветок
func reset_all_highlights():
	var grid_container = $Background/GridContainer
	for i in range(0, min(36, grid_container.get_child_count())):
		var child = grid_container.get_child(i)
		if child is Label:
			child.modulate = Color.WHITE
	
# Метод для изменения заголовков (если нужно)
func set_titles(desired_q_text: String, current_q_text: String):
	print("Setting DLatch titles: ", desired_q_text, ", ", current_q_text)
	
	if desired_q_label and is_instance_valid(desired_q_label):
		print("Changing Desired Q from '", desired_q_label.text, "' to '", desired_q_text, "'")
		desired_q_label.text = desired_q_text
	else:
		print("ERROR: desired_q_label is invalid")
	
	if current_q_label and is_instance_valid(current_q_label):
		print("Changing Current Q from '", current_q_label.text, "' to '", current_q_text, "'")
		current_q_label.text = current_q_text
	else:
		print("ERROR: current_q_label is invalid")
	
	print("TestResultsPanelDLatch: Titles updated")

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
