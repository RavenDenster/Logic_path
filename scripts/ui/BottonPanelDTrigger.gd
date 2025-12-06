# BottonPanelDTrigger.gd
extends Control

var input_d_textures = []
var input_clk_textures = []
var desired_q_textures = []
var current_q_textures = []

# Добавляем переменные для Label
var desired_q_label: Label
var current_q_label: Label

func _ready():
	anchor_left = 0.0
	anchor_right = 1.0
	anchor_top = 1.0
	anchor_bottom = 1.0
	
	_update_panel_position()

	# Устанавливаем фиксированную высоту панели
	custom_minimum_size = Vector2(0, 150)
	
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

	if grid_container.get_child_count() < 36:  # 4 строки × 9 элементов
		print("ERROR: GridContainer has only ", grid_container.get_child_count(), " children, expected 36")
		return

	# Получаем ссылки на заголовки
	desired_q_label = grid_container.get_child(18) as Label  # "Desired Q"
	current_q_label = grid_container.get_child(27) as Label  # "Current Q"

	# Проверяем, что нашли все Label
	print("DTrigger Label search results:")
	print("  Desired Q: ", desired_q_label != null)
	print("  Current Q: ", current_q_label != null)

	# Остальной код инициализации текстур
	input_d_textures = []
	input_clk_textures = []
	desired_q_textures = []
	current_q_textures = []
	
	# Input D (строка 0) - пропускаем Label (индекс 0), берем TextureRect с 1 по 8
	for i in range(1, 9):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			input_d_textures.append(child)

	# Input CLK (строка 1) - индексы 9-16
	for i in range(10, 18):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			input_clk_textures.append(child)

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
	
	print("TestResultsPanelDTrigger: Successfully initialized with ", 
		  input_d_textures.size(), " D, ", 
		  input_clk_textures.size(), " CLK, ",
		  desired_q_textures.size(), " desired Q, ",
		  current_q_textures.size(), " current Q textures")

# Добавляем метод для изменения заголовков
func set_titles(desired_q_text: String, current_q_text: String):
	print("Setting DTrigger titles: ", desired_q_text, ", ", current_q_text)
	
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
	
	print("TestResultsPanelDTrigger: Titles updated")

func load_initial_data(inputs_d, inputs_clk, expected_q):
	if input_d_textures.is_empty() or input_clk_textures.is_empty():
		print("ERROR: Textures arrays are not initialized!")
		return
	
	# Input D
	for i in range(8):
		if i < input_d_textures.size() and input_d_textures[i] is TextureRect:
			if inputs_d[i] == 1:
				input_d_textures[i].texture = load("res://assets/pointGreen.png")
			else:
				input_d_textures[i].texture = load("res://assets/point.png")

	# Input CLK
	for i in range(8):
		if i < input_clk_textures.size() and input_clk_textures[i] is TextureRect:
			if inputs_clk[i] == 1:
				input_clk_textures[i].texture = load("res://assets/pointGreen.png")
			else:
				input_clk_textures[i].texture = load("res://assets/point.png")
	
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
	
	print("TestResultsPanelDTrigger: Initial data loaded")

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
	
	print("TestResultsPanelDTrigger: Current outputs updated")

func reset_all_highlights():
	if not has_node("Background/GridContainer"):
		return
		
	var grid_container = $Background/GridContainer
	for child in grid_container.get_children():
		if child is Label:
			child.modulate = Color.WHITE
	print("TestResultsPanelDTrigger: Reset all highlights")
