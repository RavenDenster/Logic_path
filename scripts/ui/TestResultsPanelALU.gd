extends Control

var input_a_textures = []
var input_b_textures = []
var input_op1_textures = []
var input_op0_textures = []
var desired_result_textures = []
var current_result_textures = []

func _ready():
	await get_tree().process_frame
	initialize_textures()

func initialize_textures():
	if not has_node("Background/GridContainer"):
		print("ERROR: Background/GridContainer not found!")
		return
	var grid_container = $Background/GridContainer
	if grid_container.get_child_count() < 78: # 6 строк × 13 элементов (label + 12 textures на строку)
		print("ERROR: GridContainer has only ", grid_container.get_child_count(), " children, expected 78")
		return
	input_a_textures = []
	input_b_textures = []
	input_op1_textures = []
	input_op0_textures = []
	desired_result_textures = []
	current_result_textures = []
	# Input A (строка 0) - Label (0), textures 1-12
	for i in range(1, 13):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			input_a_textures.append(child)
		else:
			print("WARNING: Child ", i, " is not TextureRect: ", child.get_class())
	# Input B (строка 1) - Label (13), textures 14-25
	for i in range(14, 26):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			input_b_textures.append(child)
		else:
			print("WARNING: Child ", i, " is not TextureRect: ", child.get_class())
	# Op1 (строка 2) - Label (26), textures 27-38
	for i in range(27, 39):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			input_op1_textures.append(child)
		else:
			print("WARNING: Child ", i, " is not TextureRect: ", child.get_class())
	# Op0 (строка 3) - Label (39), textures 40-51
	for i in range(40, 52):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			input_op0_textures.append(child)
		else:
			print("WARNING: Child ", i, " is not TextureRect: ", child.get_class())
	# Desired Result (строка 4) - Label (52), textures 53-64
	for i in range(53, 65):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			desired_result_textures.append(child)
		else:
			print("WARNING: Child ", i, " is not TextureRect: ", child.get_class())
	# Current Result (строка 5) - Label (65), textures 66-77
	for i in range(66, 78):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			current_result_textures.append(child)
		else:
			print("WARNING: Child ", i, " is not TextureRect: ", child.get_class())
	print("TestResultsPanelALU: Successfully initialized with ",
	  input_a_textures.size(), " A, ",
	  input_b_textures.size(), " B, ",
	  input_op1_textures.size(), " Op1, ",
	  input_op0_textures.size(), " Op0, ",
	  desired_result_textures.size(), " desired result, ",
	  current_result_textures.size(), " current result textures")

func load_initial_data(inputs_a, inputs_b, inputs_op0, inputs_op1, expected_result):
	if input_a_textures.is_empty() or input_b_textures.is_empty() or input_op1_textures.is_empty() or input_op0_textures.is_empty():
		print("ERROR: Textures arrays are not initialized!")
		return
	print("load_initial_data called with inputs_a: ", inputs_a)
	print("inputs_b: ", inputs_b)
	print("inputs_op0: ", inputs_op0)
	print("inputs_op1: ", inputs_op1)
	print("expected_result: ", expected_result)
	# Input A
	for i in range(12):
		if i < input_a_textures.size() and input_a_textures[i] is TextureRect:
			var texture_path = "res://assets/pointGreen.png" if inputs_a[i] == 1 else "res://assets/point.png"
			print("Setting input_a[", i, "] to ", texture_path, " (value: ", inputs_a[i], ")")
			input_a_textures[i].texture = load(texture_path)
	# Input B
	for i in range(12):
		if i < input_b_textures.size() and input_b_textures[i] is TextureRect:
			var texture_path = "res://assets/pointGreen.png" if inputs_b[i] == 1 else "res://assets/point.png"
			print("Setting input_b[", i, "] to ", texture_path, " (value: ", inputs_b[i], ")")
			input_b_textures[i].texture = load(texture_path)
	# Op1
	for i in range(12):
		if i < input_op1_textures.size() and input_op1_textures[i] is TextureRect:
			var texture_path = "res://assets/pointGreen.png" if inputs_op1[i] == 1 else "res://assets/point.png"
			print("Setting op1[", i, "] to ", texture_path, " (value: ", inputs_op1[i], ")")
			input_op1_textures[i].texture = load(texture_path)
	# Op0
	for i in range(12):
		if i < input_op0_textures.size() and input_op0_textures[i] is TextureRect:
			var texture_path = "res://assets/pointGreen.png" if inputs_op0[i] == 1 else "res://assets/point.png"
			print("Setting op0[", i, "] to ", texture_path, " (value: ", inputs_op0[i], ")")
			input_op0_textures[i].texture = load(texture_path)
	# Desired Result
	for i in range(12):
		if i < desired_result_textures.size() and desired_result_textures[i] is TextureRect:
			var texture_path = "res://assets/pointGreen.png" if expected_result[i] == 1 else "res://assets/point.png"
			print("Setting desired_result[", i, "] to ", texture_path, " (value: ", expected_result[i], ")")
			desired_result_textures[i].texture = load(texture_path)
	# Current Result (очищаем)
	for i in range(12):
		if i < current_result_textures.size() and current_result_textures[i] is TextureRect:
			print("Clearing current_result[", i, "] to point.png")
			current_result_textures[i].texture = load("res://assets/point.png")
	print("TestResultsPanelALU: Initial data loaded")

func update_current_outputs(actual_result):
	if current_result_textures.is_empty():
		print("ERROR: Current textures arrays are not initialized!")
		return
	print("update_current_outputs called with actual_result: ", actual_result)
	# Current Result
	for i in range(12):
		if i < current_result_textures.size() and current_result_textures[i] is TextureRect:
			var texture_path = "res://assets/pointGreen.png" if actual_result[i] == 1 else "res://assets/point.png"
			print("Setting current_result[", i, "] to ", texture_path, " (value: ", actual_result[i], ")")
			current_result_textures[i].texture = load(texture_path)
	print("TestResultsPanelALU: Current outputs updated")
