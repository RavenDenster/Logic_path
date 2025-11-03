extends Control

var input1_textures = []
var input2_textures = []
var desired_sum_textures = []
var desired_carry_textures = []
var current_sum_textures = []
var current_carry_textures = []

var initialized = false

func _ready():
	await get_tree().process_frame
	initialize_textures()
	initialized = true
 
func initialize_textures():
	if not has_node("Background/GridContainer"):
		print("ERROR: Background/GridContainer not found!")
		return

	var grid_container = $Background/GridContainer

	if grid_container.get_child_count() < 36:
		print("ERROR: GridContainer has only ", grid_container.get_child_count(), " children, expected at least 36")
		return

	input1_textures.clear()
	input2_textures.clear()
	desired_sum_textures.clear()
	desired_carry_textures.clear()
	current_sum_textures.clear()
	current_carry_textures.clear()

	for i in range(1, 5):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			input1_textures.append(child)

	for i in range(7, 11):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			input2_textures.append(child)

	for i in range(13, 17):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			desired_sum_textures.append(child)

	for i in range(19, 23):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			desired_carry_textures.append(child)

	for i in range(25, 29):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			current_sum_textures.append(child)

	for i in range(31, 35):
		var child = grid_container.get_child(i)
		if child is TextureRect:
			current_carry_textures.append(child)
	
	print("TestResultsPanelHalfAdder: Successfully initialized")

func load_initial_data(inputs_a, inputs_b, expected_sum, expected_carry):
	if not initialized:
		print("TestResultsPanelHalfAdder not initialized yet, waiting...")
		await get_tree().process_frame
	
	print("Loading initial data to Half Adder panel")
	
	if input1_textures.is_empty():
		print("ERROR: Textures arrays are not initialized!")
		return

	for i in range(4):
		if i < input1_textures.size() and input1_textures[i] is TextureRect:
			if inputs_a[i] == 1:
				input1_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				input1_textures[i].texture = preload("res://assets/point.png")

	for i in range(4):
		if i < input2_textures.size() and input2_textures[i] is TextureRect:
			if inputs_b[i] == 1:
				input2_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				input2_textures[i].texture = preload("res://assets/point.png")

	for i in range(4):
		if i < desired_sum_textures.size() and desired_sum_textures[i] is TextureRect:
			if expected_sum[i] == 1:
				desired_sum_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				desired_sum_textures[i].texture = preload("res://assets/point.png")

	for i in range(4):
		if i < desired_carry_textures.size() and desired_carry_textures[i] is TextureRect:
			if expected_carry[i] == 1:
				desired_carry_textures[i].texture = preload("res://assets/pointGreen.png")
			else:
				desired_carry_textures[i].texture = preload("res://assets/point.png")

	for i in range(4):
		if i < current_sum_textures.size() and current_sum_textures[i] is TextureRect:
			current_sum_textures[i].texture = preload("res://assets/point.png")
		if i < current_carry_textures.size() and current_carry_textures[i] is TextureRect:
			current_carry_textures[i].texture = preload("res://assets/point.png")
	
	print("TestResultsPanelHalfAdder: Initial data loaded")

func update_current_outputs(sum_outputs, carry_outputs):
	print("Updating current outputs in Half Adder panel")
	print("Sum outputs: ", sum_outputs)
	print("Carry outputs: ", carry_outputs)
	
	if current_sum_textures.is_empty() or current_carry_textures.is_empty():
		print("ERROR: Current textures arrays are not initialized!")
		return

	if sum_outputs.size() < 4:
		print("ERROR: sum_outputs has only ", sum_outputs.size(), " elements, expected 4")
		return
	if carry_outputs.size() < 4:
		print("ERROR: carry_outputs has only ", carry_outputs.size(), " elements, expected 4")
		return

	for i in range(4):

		if i < current_sum_textures.size() and current_sum_textures[i] is TextureRect:
			if sum_outputs[i] == 1:
				current_sum_textures[i].texture = preload("res://assets/pointGreen.png")
				print("Set current_sum[", i, "] to green")
			else:
				current_sum_textures[i].texture = preload("res://assets/point.png")
				print("Set current_sum[", i, "] to red")
		else:
			print("WARNING: current_sum_textures[", i, "] is invalid")

		if i < current_carry_textures.size() and current_carry_textures[i] is TextureRect:
			if carry_outputs[i] == 1:
				current_carry_textures[i].texture = preload("res://assets/pointGreen.png")
				print("Set current_carry[", i, "] to green")
			else:
				current_carry_textures[i].texture = preload("res://assets/point.png")
				print("Set current_carry[", i, "] to red")
		else:
			print("WARNING: current_carry_textures[", i, "] is invalid")
	
	print("TestResultsPanelHalfAdder: Current outputs updated")
