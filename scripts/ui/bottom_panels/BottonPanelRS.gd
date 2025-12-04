# TestResultsPanelRS.gd
extends Control

var input_r_textures = []
var input_s_textures = []
var desired_q_textures = []
var desired_not_q_textures = []
var current_q_textures = []
var current_not_q_textures = []

# Добавляем переменные для всех Label (6 строк)
var all_labels = []
var input_r_label: Label
var input_s_label: Label
var desired_q_label: Label
var desired_not_q_label: Label
var current_q_label: Label
var current_not_q_label: Label

func _ready():
	# Устанавливаем якоря для привязки к низу экрана
	anchor_left = 0.0
	anchor_right = 1.0
	anchor_top = 1.0
	anchor_bottom = 1.0
	
	# Обновляем позицию панели
	_update_panel_position()

	# Устанавливаем фиксированную высоту панели
	custom_minimum_size = Vector2(0, 220)  # Высота 220 пикселей
	
	var viewport_size = get_viewport_rect().size
	size = Vector2(viewport_size.x, 220)
	
	# Подписываемся на изменение размера окна
	get_tree().root.connect("size_changed", _on_window_size_changed)
	
	await get_tree().process_frame
	initialize_textures()

func _update_panel_position():
	var window_size = get_viewport_rect().size
	custom_minimum_size = Vector2(window_size.x, 220)
	size = Vector2(window_size.x, 220)
	position = Vector2(0, window_size.y - 220)
	queue_redraw()

func _on_window_size_changed():
	# Обновляем размер панели при изменении размера окна
	var window_size = get_viewport_rect().size
	custom_minimum_size = Vector2(window_size.x, 220)
	size = Vector2(window_size.x, 220)
	position = Vector2(0, window_size.y - 220)
	
	# Принудительно обновляем layout
	queue_redraw()

func initialize_textures():
	if not has_node("Background/GridContainer"):
		print("ERROR: Background/GridContainer not found!")
		return
	
	var grid_container = $Background/GridContainer
	var child_count = grid_container.get_child_count()
	print("GridContainer has ", child_count, " children")
	
	# Проверяем, что у нас ровно 54 элемента (6 строк × 9 колонок)
	if child_count != 54:
		print("ERROR: Expected 54 children in GridContainer, but got ", child_count)
		# Используем что есть, но с проверкой границ
	
	# Инициализируем массив всех Label (6 штук)
	all_labels = []
	for row in range(6):
		var index = row * 9  # Первый элемент каждой строки
		if index < child_count:
			var child = grid_container.get_child(index)
			if child is Label:
				all_labels.append(child)
				print("Row ", row, " label: ", child.text)
	
	# Сохраняем отдельные ссылки для удобства
	if all_labels.size() >= 6:
		input_r_label = all_labels[0]  # "Input R"
		input_s_label = all_labels[1]  # "Input S"
		desired_q_label = all_labels[2]  # "Desired Q"
		desired_not_q_label = all_labels[3]  # "Desired !Q"
		current_q_label = all_labels[4]  # "Current Q"
		current_not_q_label = all_labels[5]  # "Current !Q"
	
	print("RS Label search results:")
	print("  Input R: ", input_r_label != null)
	print("  Input S: ", input_s_label != null)
	print("  Desired Q: ", desired_q_label != null)
	print("  Desired !Q: ", desired_not_q_label != null)
	print("  Current Q: ", current_q_label != null)
	print("  Current !Q: ", current_not_q_label != null)
	
	# Очищаем массивы текстур
	input_r_textures = []
	input_s_textures = []
	desired_q_textures = []
	desired_not_q_textures = []
	current_q_textures = []
	current_not_q_textures = []
	
	# Разбиваем элементы по строкам (по 9 элементов в каждой строке)
	for row in range(6):
		for col in range(9):
			var index = row * 9 + col
			if index >= child_count:
				break
			var child = grid_container.get_child(index)
			
			# Пропускаем первый столбец (это labels)
			if col == 0:
				continue
			
			# Распределяем по строкам
			match row:
				0: # Input R
					if child is TextureRect:
						input_r_textures.append(child)
				1: # Input S
					if child is TextureRect:
						input_s_textures.append(child)
				2: # Desired Q
					if child is TextureRect:
						desired_q_textures.append(child)
				3: # Desired !Q
					if child is TextureRect:
						desired_not_q_textures.append(child)
				4: # Current Q
					if child is TextureRect:
						current_q_textures.append(child)
				5: # Current !Q
					if child is TextureRect:
						current_not_q_textures.append(child)
	
	print("TestResultsPanelRS: Successfully initialized with:")
	print(" Input R: ", input_r_textures.size(), " textures")
	print(" Input S: ", input_s_textures.size(), " textures")
	print(" Desired Q: ", desired_q_textures.size(), " textures")
	print(" Desired !Q: ", desired_not_q_textures.size(), " textures")
	print(" Current Q: ", current_q_textures.size(), " textures")
	print(" Current !Q: ", current_not_q_textures.size(), " textures")

# Метод для подсветки конкретных заголовков
func highlight_labels(label_indices: Array):
	if all_labels.is_empty():
		print("TestResultsPanelRS: Labels not initialized yet")
		return
	
	# Сначала сбрасываем все подсветки
	reset_all_highlights()
	
	# Подсвечиваем запрошенные метки
	for index in label_indices:
		if index < all_labels.size():
			all_labels[index].modulate = Color.YELLOW
			print("Highlighted label ", index, ": ", all_labels[index].text)

# Метод для сброса всех подсветок
func reset_all_highlights():
	for label in all_labels:
		if label and is_instance_valid(label):
			label.modulate = Color.WHITE

func load_initial_data(inputs_r, inputs_s, expected_q, expected_not_q):
	if input_r_textures.is_empty() or input_s_textures.is_empty():
		print("ERROR: Textures arrays are not initialized!")
		return
	
	# Загружаем входные данные R
	for i in range(8):
		if i < input_r_textures.size() and input_r_textures[i] is TextureRect:
			if i < inputs_r.size() and inputs_r[i] == 1:
				input_r_textures[i].texture = load("res://assets/pointGreen.png")
			else:
				input_r_textures[i].texture = load("res://assets/point.png")
	
	# Загружаем входные данные S
	for i in range(8):
		if i < input_s_textures.size() and input_s_textures[i] is TextureRect:
			if i < inputs_s.size() and inputs_s[i] == 1:
				input_s_textures[i].texture = load("res://assets/pointGreen.png")
			else:
				input_s_textures[i].texture = load("res://assets/point.png")
	
	# Загружаем ожидаемые значения Q
	for i in range(8):
		if i < desired_q_textures.size() and desired_q_textures[i] is TextureRect:
			if i < expected_q.size() and expected_q[i] == 1:
				desired_q_textures[i].texture = load("res://assets/pointGreen.png")
			else:
				desired_q_textures[i].texture = load("res://assets/point.png")
	
	# Загружаем ожидаемые значения !Q
	for i in range(8):
		if i < desired_not_q_textures.size() and desired_not_q_textures[i] is TextureRect:
			if i < expected_not_q.size() and expected_not_q[i] == 1:
				desired_not_q_textures[i].texture = load("res://assets/pointGreen.png")
			else:
				desired_not_q_textures[i].texture = load("res://assets/point.png")
	
	# Очищаем текущие значения Q
	for i in range(8):
		if i < current_q_textures.size() and current_q_textures[i] is TextureRect:
			current_q_textures[i].texture = load("res://assets/point.png")
	
	# Очищаем текущие значения !Q
	for i in range(8):
		if i < current_not_q_textures.size() and current_not_q_textures[i] is TextureRect:
			current_not_q_textures[i].texture = load("res://assets/point.png")
	
	print("TestResultsPanelRS: Initial data loaded successfully")

func update_current_outputs(actual_q, actual_not_q):
	if current_q_textures.is_empty() or current_not_q_textures.is_empty():
		print("ERROR: Current textures arrays are not initialized!")
		return
	
	# Обновляем текущие значения Q
	for i in range(8):
		if i < current_q_textures.size() and current_q_textures[i] is TextureRect:
			if i < actual_q.size() and actual_q[i] == 1:
				current_q_textures[i].texture = load("res://assets/pointGreen.png")
			else:
				current_q_textures[i].texture = load("res://assets/point.png")
	
	# Обновляем текущие значения !Q
	for i in range(8):
		if i < current_not_q_textures.size() and current_not_q_textures[i] is TextureRect:
			if i < actual_not_q.size() and actual_not_q[i] == 1:
				current_not_q_textures[i].texture = load("res://assets/pointGreen.png")
			else:
				current_not_q_textures[i].texture = load("res://assets/point.png")
	
	print("TestResultsPanelRS: Current outputs updated")
