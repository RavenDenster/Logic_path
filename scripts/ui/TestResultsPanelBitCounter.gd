extends Control

var input_clk_textures = []
var desired_q0_textures = []
var desired_q1_textures = []
var current_q0_textures = []
var current_q1_textures = []

func _ready():
	await get_tree().process_frame
	initialize_textures()

func initialize_textures():
	if not has_node("Background/GridContainer"):
		print("ERROR: Background/GridContainer not found!")
		return

	var grid_container = $Background/GridContainer
	var child_count = grid_container.get_child_count()
	print("TestResultsPanelBitCounter: GridContainer has ", child_count, " children")
	
	# Выведем информацию о всех детях для отладки
	for i in range(child_count):
		var child = grid_container.get_child(i)
		print("Child ", i, ": ", child.name, " (", child.get_class(), ")")
	
	# Очищаем массивы
	input_clk_textures = []
	desired_q0_textures = []
	desired_q1_textures = []
	current_q0_textures = []
	current_q1_textures = []
	
	# Более надежный способ: группируем элементы по строкам
	# Предполагаем, что GridContainer имеет 5 строк и 7 колонок (метка + 6 значений)
	var rows = []
	var current_row = []
	
	for i in range(child_count):
		var child = grid_container.get_child(i)
		current_row.append(child)
		
		# Если достигли конца строки (7 элементов) или конца контейнера
		if current_row.size() == 7 or i == child_count - 1:
			rows.append(current_row)
			current_row = []
	
	print("TestResultsPanelBitCounter: Found ", rows.size(), " rows")
	
	# Теперь распределяем TextureRect по строкам
	if rows.size() >= 1:
		# Первая строка: CLK
		for i in range(1, min(7, rows[0].size())):  # Пропускаем первый элемент (метку)
			var child = rows[0][i]
			if child is TextureRect:
				input_clk_textures.append(child)
				print("Added CLK texture at position ", i-1)
	
	if rows.size() >= 2:
		# Вторая строка: Desired Q0
		for i in range(1, min(7, rows[1].size())):
			var child = rows[1][i]
			if child is TextureRect:
				desired_q0_textures.append(child)
				print("Added Desired Q0 texture at position ", i-1)
	
	if rows.size() >= 3:
		# Третья строка: Desired Q1
		for i in range(1, min(7, rows[2].size())):
			var child = rows[2][i]
			if child is TextureRect:
				desired_q1_textures.append(child)
				print("Added Desired Q1 texture at position ", i-1)
	
	if rows.size() >= 4:
		# Четвертая строка: Current Q0
		for i in range(1, min(7, rows[3].size())):
			var child = rows[3][i]
			if child is TextureRect:
				current_q0_textures.append(child)
				print("Added Current Q0 texture at position ", i-1)
	
	if rows.size() >= 5:
		# Пятая строка: Current Q1
		for i in range(1, min(7, rows[4].size())):
			var child = rows[4][i]
			if child is TextureRect:
				current_q1_textures.append(child)
				print("Added Current Q1 texture at position ", i-1)
	
	print("TestResultsPanelBitCounter: Successfully initialized with ", 
		  input_clk_textures.size(), " CLK, ",
		  desired_q0_textures.size(), " desired Q0, ",
		  desired_q1_textures.size(), " desired Q1, ",
		  current_q0_textures.size(), " current Q0, ",
		  current_q1_textures.size(), " current Q1 textures")

func load_initial_data(inputs_clk, expected_q0, expected_q1):
	print("TestResultsPanelBitCounter: Loading initial data")
	print("CLK: ", inputs_clk)
	print("Expected Q0: ", expected_q0)
	print("Expected Q1: ", expected_q1)
	
	if input_clk_textures.is_empty() or desired_q0_textures.is_empty() or desired_q1_textures.is_empty():
		print("ERROR: Textures arrays are not initialized!")
		return
	
	# Input CLK
	for i in range(min(6, input_clk_textures.size())):
		if i < inputs_clk.size() and input_clk_textures[i] is TextureRect:
			if inputs_clk[i] == 1:
				input_clk_textures[i].texture = preload("res://assets/pointGreen.png")
				print("Set CLK[", i, "] to GREEN")
			else:
				input_clk_textures[i].texture = preload("res://assets/point.png")
				print("Set CLK[", i, "] to RED")

	# Desired Q0
	for i in range(min(6, desired_q0_textures.size())):
		if i < expected_q0.size() and desired_q0_textures[i] is TextureRect:
			if expected_q0[i] == 1:
				desired_q0_textures[i].texture = preload("res://assets/pointGreen.png")
				print("Set Desired Q0[", i, "] to GREEN")
			else:
				desired_q0_textures[i].texture = preload("res://assets/point.png")
				print("Set Desired Q0[", i, "] to RED")

	# Desired Q1
	for i in range(min(6, desired_q1_textures.size())):
		if i < expected_q1.size() and desired_q1_textures[i] is TextureRect:
			if expected_q1[i] == 1:
				desired_q1_textures[i].texture = preload("res://assets/pointGreen.png")
				print("Set Desired Q1[", i, "] to GREEN")
			else:
				desired_q1_textures[i].texture = preload("res://assets/point.png")
				print("Set Desired Q1[", i, "] to RED")

	# Current Q0 (очищаем)
	for i in range(min(6, current_q0_textures.size())):
		if current_q0_textures[i] is TextureRect:
			current_q0_textures[i].texture = preload("res://assets/point.png")
			print("Reset Current Q0[", i, "] to RED")

	# Current Q1 (очищаем)
	for i in range(min(6, current_q1_textures.size())):
		if current_q1_textures[i] is TextureRect:
			current_q1_textures[i].texture = preload("res://assets/point.png")
			print("Reset Current Q1[", i, "] to RED")
	
	print("TestResultsPanelBitCounter: Initial data loaded")

func update_current_outputs(actual_q0, actual_q1):
	print("TestResultsPanelBitCounter: Updating current outputs")
	print("Actual Q0: ", actual_q0)
	print("Actual Q1: ", actual_q1)
	
	if current_q0_textures.is_empty() or current_q1_textures.is_empty():
		print("ERROR: Current textures arrays are not initialized!")
		return

	# Current Q0
	for i in range(min(6, current_q0_textures.size())):
		if i < actual_q0.size() and current_q0_textures[i] is TextureRect:
			if actual_q0[i] == 1:
				current_q0_textures[i].texture = preload("res://assets/pointGreen.png")
				print("Set Current Q0[", i, "] to GREEN")
			else:
				current_q0_textures[i].texture = preload("res://assets/point.png")
				print("Set Current Q0[", i, "] to RED")

	# Current Q1
	for i in range(min(6, current_q1_textures.size())):
		if i < actual_q1.size() and current_q1_textures[i] is TextureRect:
			if actual_q1[i] == 1:
				current_q1_textures[i].texture = preload("res://assets/pointGreen.png")
				print("Set Current Q1[", i, "] to GREEN")
			else:
				current_q1_textures[i].texture = preload("res://assets/point.png")
				print("Set Current Q1[", i, "] to RED")
	
	print("TestResultsPanelBitCounter: Current outputs updated")
