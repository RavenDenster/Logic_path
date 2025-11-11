extends Control

var input_a_textures = []
var input_b_textures = []
var desired_agtb_textures = []
var desired_altb_textures = []
var desired_aeqb_textures = []
var current_agtb_textures = []
var current_altb_textures = []
var current_aeqb_textures = []

func _ready():
	await get_tree().process_frame
	initialize_textures()

func initialize_textures():
	if not has_node("Background/GridContainer"):
		print("ERROR: Background/GridContainer not found!")
		return

	var grid_container = $Background/GridContainer
	var child_count = grid_container.get_child_count()
	print("TestResultsPanelComparator: GridContainer has ", child_count, " children")

	if child_count < 40:
		print("ERROR: GridContainer has only ", child_count, " children, expected 40")
		return

	input_a_textures = []
	input_b_textures = []
	desired_agtb_textures = []
	desired_altb_textures = []
	desired_aeqb_textures = []
	current_agtb_textures = []
	current_altb_textures = []
	current_aeqb_textures = []
	
	# Input A (строка 0) - индексы 1-4
	for i in range(1, 5):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			input_a_textures.append(child)

	# Input B (строка 1) - индексы 6-9
	for i in range(6, 10):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			input_b_textures.append(child)

	# Desired A>B (строка 2) - индексы 11-14
	for i in range(11, 15):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			desired_agtb_textures.append(child)

	# Desired A<B (строка 3) - индексы 16-19
	for i in range(16, 20):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			desired_altb_textures.append(child)

	# Desired A==B (строка 4) - индексы 21-24
	for i in range(21, 25):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			desired_aeqb_textures.append(child)

	# Current A>B (строка 5) - индексы 26-29
	for i in range(26, 30):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			current_agtb_textures.append(child)

	# Current A<B (строка 6) - индексы 31-34
	for i in range(31, 35):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			current_altb_textures.append(child)

	# Current A==B (строка 7) - индексы 36-39
	for i in range(36, 40):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			current_aeqb_textures.append(child)
	
	print("TestResultsPanelComparator: Successfully initialized")

func load_initial_data(inputs_a, inputs_b, expected_agtb, expected_altb, expected_aeqb):
	if input_a_textures.is_empty():
		print("ERROR: Textures arrays are not initialized!")
		return
	
	print("TestResultsPanelComparator: Loading initial data")
	
	# Input A
	for i in range(4):
		if i < input_a_textures.size():
			var texture_path = "res://assets/pointGreen.png" if inputs_a[i] == 1 else "res://assets/point.png"
			input_a_textures[i].texture = load(texture_path)

	# Input B
	for i in range(4):
		if i < input_b_textures.size():
			var texture_path = "res://assets/pointGreen.png" if inputs_b[i] == 1 else "res://assets/point.png"
			input_b_textures[i].texture = load(texture_path)
	
	# Desired A>B
	for i in range(4):
		if i < desired_agtb_textures.size():
			var texture_path = "res://assets/pointGreen.png" if expected_agtb[i] == 1 else "res://assets/point.png"
			desired_agtb_textures[i].texture = load(texture_path)

	# Desired A<B
	for i in range(4):
		if i < desired_altb_textures.size():
			var texture_path = "res://assets/pointGreen.png" if expected_altb[i] == 1 else "res://assets/point.png"
			desired_altb_textures[i].texture = load(texture_path)

	# Desired A==B
	for i in range(4):
		if i < desired_aeqb_textures.size():
			var texture_path = "res://assets/pointGreen.png" if expected_aeqb[i] == 1 else "res://assets/point.png"
			desired_aeqb_textures[i].texture = load(texture_path)

	# Current outputs (очищаем)
	reset_current_outputs()
	
	print("TestResultsPanelComparator: Initial data loaded")

func reset_current_outputs():
	for i in range(4):
		if i < current_agtb_textures.size():
			current_agtb_textures[i].texture = load("res://assets/point.png")
		if i < current_altb_textures.size():
			current_altb_textures[i].texture = load("res://assets/point.png")
		if i < current_aeqb_textures.size():
			current_aeqb_textures[i].texture = load("res://assets/point.png")

func update_current_outputs(actual_agtb, actual_altb, actual_aeqb):
	if current_agtb_textures.is_empty():
		print("ERROR: Current textures arrays are not initialized!")
		return

	print("TestResultsPanelComparator: Updating current outputs")
	
	# Current A>B
	for i in range(4):
		if i < current_agtb_textures.size():
			var texture_path = "res://assets/pointGreen.png" if actual_agtb[i] == 1 else "res://assets/point.png"
			current_agtb_textures[i].texture = load(texture_path)

	# Current A<B
	for i in range(4):
		if i < current_altb_textures.size():
			var texture_path = "res://assets/pointGreen.png" if actual_altb[i] == 1 else "res://assets/point.png"
			current_altb_textures[i].texture = load(texture_path)

	# Current A==B
	for i in range(4):
		if i < current_aeqb_textures.size():
			var texture_path = "res://assets/pointGreen.png" if actual_aeqb[i] == 1 else "res://assets/point.png"
			current_aeqb_textures[i].texture = load(texture_path)
	
	print("TestResultsPanelComparator: Current outputs updated")
