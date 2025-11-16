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

	if grid_container.get_child_count() < 54:  # 6 строк × 9 элементов
		print("ERROR: GridContainer has only ", grid_container.get_child_count(), " children, expected 54")
		return

	input_r_textures = []
	input_s_textures = []
	desired_q_textures = []
	desired_not_q_textures = []
	current_q_textures = []
	current_not_q_textures = []
	
	# Input R (строка 0) - пропускаем Label (индекс 0), берем TextureRect с 1 по 8
	for i in range(1, 9):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			input_r_textures.append(child)
			print("Found Input R texture at index ", i)

	# Input S (строка 1) - индексы 9-16
	for i in range(10, 18):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			input_s_textures.append(child)
			print("Found Input S texture at index ", i)

	# Desired Q (строка 2) - индексы 18-25
	for i in range(19, 27):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			desired_q_textures.append(child)
			print("Found Desired Q texture at index ", i)

	# Desired !Q (строка 3) - индексы 27-34
	for i in range(28, 36):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			desired_not_q_textures.append(child)
			print("Found Desired !Q texture at index ", i)

	# Current Q (строка 4) - индексы 36-43
	for i in range(37, 45):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			current_q_textures.append(child)
			print("Found Current Q texture at index ", i)

	# Current !Q (строка 5) - индексы 45-52
	for i in range(46, 54):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			current_not_q_textures.append(child)
			print("Found Current !Q texture at index ", i)
	
	print("TestResultsPanelRS: Successfully initialized with ", 
		  input_r_textures.size(), " R, ", 
		  input_s_textures.size(), " S, ",
		  desired_q_textures.size(), " desired Q, ",
		  desired_not_q_textures.size(), " desired !Q, ",
		  current_q_textures.size(), " current Q, ",
		  current_not_q_textures.size(), " current !Q textures")

func load_initial_data(inputs_r, inputs_s, expected_q, expected_not_q):
	print("TestResultsPanelRS: Loading initial data")
	print("Inputs R: ", inputs_r)
	print("Inputs S: ", inputs_s)
	print("Expected Q: ", expected_q)
	print("Expected !Q: ", expected_not_q)
	
	if input_r_textures.is_empty() or input_s_textures.is_empty():
		print("ERROR: Textures arrays are not initialized!")
		return
	
	# Проверяем существование текстур
	var point_texture = preload("res://assets/point.png")
	var point_green_texture = preload("res://assets/pointGreen.png")
	
	if point_texture == null:
		print("ERROR: Cannot load point.png")
		return
	if point_green_texture == null:
		print("ERROR: Cannot load pointGreen.png")
		return
	
	# Input R
	for i in range(8):
		if i < input_r_textures.size() and input_r_textures[i] is TextureRect:
			var texture_rect = input_r_textures[i]
			if texture_rect and is_instance_valid(texture_rect):
				if i < inputs_r.size() and inputs_r[i] == 1:
					texture_rect.texture = point_green_texture
					print("Set Input R[", i, "] to GREEN")
				else:
					texture_rect.texture = point_texture
					print("Set Input R[", i, "] to GRAY")

	# Input S
	for i in range(8):
		if i < input_s_textures.size() and input_s_textures[i] is TextureRect:
			var texture_rect = input_s_textures[i]
			if texture_rect and is_instance_valid(texture_rect):
				if i < inputs_s.size() and inputs_s[i] == 1:
					texture_rect.texture = point_green_texture
					print("Set Input S[", i, "] to GREEN")
				else:
					texture_rect.texture = point_texture
					print("Set Input S[", i, "] to GRAY")
	
	# Desired Q
	for i in range(8):
		if i < desired_q_textures.size() and desired_q_textures[i] is TextureRect:
			var texture_rect = desired_q_textures[i]
			if texture_rect and is_instance_valid(texture_rect):
				if i < expected_q.size() and expected_q[i] == 1:
					texture_rect.texture = point_green_texture
					print("Set Desired Q[", i, "] to GREEN")
				else:
					texture_rect.texture = point_texture
					print("Set Desired Q[", i, "] to GRAY")

	# Desired !Q
	for i in range(8):
		if i < desired_not_q_textures.size() and desired_not_q_textures[i] is TextureRect:
			var texture_rect = desired_not_q_textures[i]
			if texture_rect and is_instance_valid(texture_rect):
				if i < expected_not_q.size() and expected_not_q[i] == 1:
					texture_rect.texture = point_green_texture
					print("Set Desired !Q[", i, "] to GREEN")
				else:
					texture_rect.texture = point_texture
					print("Set Desired !Q[", i, "] to GRAY")

	# Current Q (очищаем)
	for i in range(8):
		if i < current_q_textures.size() and current_q_textures[i] is TextureRect:
			var texture_rect = current_q_textures[i]
			if texture_rect and is_instance_valid(texture_rect):
				texture_rect.texture = point_texture
				print("Set Current Q[", i, "] to GRAY")

	# Current !Q (очищаем)
	for i in range(8):
		if i < current_not_q_textures.size() and current_not_q_textures[i] is TextureRect:
			var texture_rect = current_not_q_textures[i]
			if texture_rect and is_instance_valid(texture_rect):
				texture_rect.texture = point_texture
				print("Set Current !Q[", i, "] to GRAY")
	
	print("TestResultsPanelRS: Initial data loaded")

func update_current_outputs(actual_q, actual_not_q):
	print("TestResultsPanelRS: Updating current outputs")
	print("Actual Q: ", actual_q)
	print("Actual !Q: ", actual_not_q)
	
	if current_q_textures.is_empty() or current_not_q_textures.is_empty():
		print("ERROR: Current textures arrays are not initialized!")
		return

	# Проверяем существование текстур
	var point_texture = preload("res://assets/point.png")
	var point_green_texture = preload("res://assets/pointGreen.png")
	
	if point_texture == null:
		print("ERROR: Cannot load point.png")
		return
	if point_green_texture == null:
		print("ERROR: Cannot load pointGreen.png")
		return

	# Current Q
	for i in range(8):
		if i < current_q_textures.size() and current_q_textures[i] is TextureRect:
			var texture_rect = current_q_textures[i]
			if texture_rect and is_instance_valid(texture_rect):
				if i < actual_q.size() and actual_q[i] == 1:
					texture_rect.texture = point_green_texture
					print("Set Current Q[", i, "] to GREEN")
				else:
					texture_rect.texture = point_texture
					print("Set Current Q[", i, "] to GRAY")

	# Current !Q
	for i in range(8):
		if i < current_not_q_textures.size() and current_not_q_textures[i] is TextureRect:
			var texture_rect = current_not_q_textures[i]
			if texture_rect and is_instance_valid(texture_rect):
				if i < actual_not_q.size() and actual_not_q[i] == 1:
					texture_rect.texture = point_green_texture
					print("Set Current !Q[", i, "] to GREEN")
				else:
					texture_rect.texture = point_texture
					print("Set Current !Q[", i, "] to GRAY")
	
	print("TestResultsPanelRS: Current outputs updated")
