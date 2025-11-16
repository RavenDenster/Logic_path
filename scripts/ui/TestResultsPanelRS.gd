extends Control

var input_r_textures = []
var input_s_textures = []
var desired_q_textures = []
var desired_not_q_textures = []
var current_q_textures = []
var current_not_q_textures = []

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

	# Проверяем, что у нас ровно 54 элемента (6 строк × 9 колонок)
	if child_count != 54:
		print("ERROR: Expected 54 children in GridContainer, but got ", child_count)
		# Попробуем все равно проинициализировать с тем, что есть
		if child_count < 54:
			print("Not enough children - some textures will be missing")
		else:
			print("Too many children - using first 54")

	# Очищаем массивы
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
	print("  Input R: ", input_r_textures.size(), " textures")
	print("  Input S: ", input_s_textures.size(), " textures")
	print("  Desired Q: ", desired_q_textures.size(), " textures")
	print("  Desired !Q: ", desired_not_q_textures.size(), " textures")
	print("  Current Q: ", current_q_textures.size(), " textures")
	print("  Current !Q: ", current_not_q_textures.size(), " textures")

func load_initial_data(inputs_r, inputs_s, expected_q, expected_not_q):
	# Загружаем входные данные R
	for i in range(min(8, input_r_textures.size())):
		var texture_rect = input_r_textures[i]
		if texture_rect and is_instance_valid(texture_rect):
			if i < inputs_r.size() and inputs_r[i] == 1:
				texture_rect.texture = preload("res://assets/pointGreen.png")
			else:
				texture_rect.texture = preload("res://assets/point.png")

	# Загружаем входные данные S
	for i in range(min(8, input_s_textures.size())):
		var texture_rect = input_s_textures[i]
		if texture_rect and is_instance_valid(texture_rect):
			if i < inputs_s.size() and inputs_s[i] == 1:
				texture_rect.texture = preload("res://assets/pointGreen.png")
			else:
				texture_rect.texture = preload("res://assets/point.png")

	# Загружаем ожидаемые значения Q
	for i in range(min(8, desired_q_textures.size())):
		var texture_rect = desired_q_textures[i]
		if texture_rect and is_instance_valid(texture_rect):
			if i < expected_q.size() and expected_q[i] == 1:
				texture_rect.texture = preload("res://assets/pointGreen.png")
			else:
				texture_rect.texture = preload("res://assets/point.png")

	# Загружаем ожидаемые значения !Q
	for i in range(min(8, desired_not_q_textures.size())):
		var texture_rect = desired_not_q_textures[i]
		if texture_rect and is_instance_valid(texture_rect):
			if i < expected_not_q.size() and expected_not_q[i] == 1:
				texture_rect.texture = preload("res://assets/pointGreen.png")
			else:
				texture_rect.texture = preload("res://assets/point.png")

	# Очищаем текущие значения Q
	for i in range(min(8, current_q_textures.size())):
		var texture_rect = current_q_textures[i]
		if texture_rect and is_instance_valid(texture_rect):
			texture_rect.texture = preload("res://assets/point.png")

	# Очищаем текущие значения !Q
	for i in range(min(8, current_not_q_textures.size())):
		var texture_rect = current_not_q_textures[i]
		if texture_rect and is_instance_valid(texture_rect):
			texture_rect.texture = preload("res://assets/point.png")

	print("TestResultsPanelRS: Initial data loaded successfully")

func update_current_outputs(actual_q, actual_not_q):
	# Обновляем текущие значения Q
	for i in range(min(8, current_q_textures.size())):
		var texture_rect = current_q_textures[i]
		if texture_rect and is_instance_valid(texture_rect):
			if i < actual_q.size() and actual_q[i] == 1:
				texture_rect.texture = preload("res://assets/pointGreen.png")
			else:
				texture_rect.texture = preload("res://assets/point.png")

	# Обновляем текущие значения !Q
	for i in range(min(8, current_not_q_textures.size())):
		var texture_rect = current_not_q_textures[i]
		if texture_rect and is_instance_valid(texture_rect):
			if i < actual_not_q.size() and actual_not_q[i] == 1:
				texture_rect.texture = preload("res://assets/pointGreen.png")
			else:
				texture_rect.texture = preload("res://assets/point.png")

	print("TestResultsPanelRS: Current outputs updated")
