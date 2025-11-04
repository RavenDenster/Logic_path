extends "res://scripts/levels/LevelBase.gd"

var input_block_a  # InputBlock2 для A1 и A0
var input_block_b  # InputBlock2 для B1 и B0
var output_s1      # OutputBlock для S1
var output_s0      # OutputBlock для S0  
var output_cout    # OutputBlock для Cout

func setup_two_bit_adder_level():
	print("Setting up 2-Bit Adder level with simplified structure")

	movable_objects = []

	input_block_a = get_node_or_null("InputBlockA")
	input_block_b = get_node_or_null("InputBlockB")
	
	if input_block_a and input_block_b:
		print("Both InputBlock2 found")

		input_block_a.values_A = level_data.input_values_a1.duplicate()
		input_block_a.values_B = level_data.input_values_a0.duplicate()
		input_block_b.values_A = level_data.input_values_b1.duplicate()
		input_block_b.values_B = level_data.input_values_b0.duplicate()
		
		movable_objects.append(input_block_a)
		movable_objects.append(input_block_b)
		print("InputBlockA: A1=", input_block_a.values_A, " A0=", input_block_a.values_B)
		print("InputBlockB: B1=", input_block_b.values_A, " B0=", input_block_b.values_B)
	else:
		push_error("InputBlock2 not found in 2-Bit Adder level!")

	output_s1 = get_node_or_null("OutputS1")
	output_s0 = get_node_or_null("OutputS0") 
	output_cout = get_node_or_null("OutputCout")
	
	if output_s1 and output_s0 and output_cout:
		output_s1.expected = level_data.expected_s1.duplicate()
		output_s0.expected = level_data.expected_s0.duplicate()
		output_cout.expected = level_data.expected_cout.duplicate()
		
		movable_objects.append(output_s1)
		movable_objects.append(output_s0)
		movable_objects.append(output_cout)
		print("2-Bit Adder output blocks initialized")
	else:
		push_error("Output blocks not found in 2-Bit Adder level!")

	test_results_panel = get_node_or_null("TestResultsPanel2BitAdder")
	if test_results_panel:
		print("2-Bit Adder test panel found")
		
		await get_tree().process_frame
		if test_results_panel.has_method("load_initial_data"):
			test_results_panel.load_initial_data(
				level_data.input_values_a1,
				level_data.input_values_a0,
				level_data.input_values_b1,
				level_data.input_values_b0,
				level_data.expected_s1,
				level_data.expected_s0,
				level_data.expected_cout
			)
			print("2-Bit Adder test panel initialized")
	else:
		print("WARNING: TestResultsPanel2BitAdder not found")

	update_all_logic_objects()
	print("Movable objects: ", movable_objects.size())

func _on_test_pressed():
	print("=== Testing 2-Bit Adder level ===")
	reset_all_port_sprites()

	if output_s1:
		output_s1.set_default_style()
	if output_s0:
		output_s0.set_default_style()
	if output_cout:
		output_cout.set_default_style()
	
	var player_s1_outputs = []
	var player_s0_outputs = []
	var player_cout_outputs = []
	
	if not input_block_a or not input_block_b:
		push_error("Input blocks not found!")
		return

	for i in range(16):
		print("--- Test case ", i, " ---")
		input_block_a.current_test_index = i
		input_block_b.current_test_index = i
		
		print("Input values: A1=", input_block_a.values_A[i], " A0=", input_block_a.values_B[i], 
			  " B1=", input_block_b.values_A[i], " B0=", input_block_b.values_B[i])

		for obj in all_logic_objects:
			if obj and obj.has_method("reset_inputs"):
				obj.reset_inputs()

		if output_s1:
			output_s1.received_value = 0
		if output_s0:
			output_s0.received_value = 0
		if output_cout:
			output_cout.received_value = 0
			
		propagate_signals()
		
		if output_s1:
			player_s1_outputs.append(int(output_s1.received_value))
			print("S1 output: ", output_s1.received_value)
		else:
			player_s1_outputs.append(0)
		
		if output_s0:
			player_s0_outputs.append(int(output_s0.received_value))
			print("S0 output: ", output_s0.received_value)
		else:
			player_s0_outputs.append(0)
		
		if output_cout:
			player_cout_outputs.append(int(output_cout.received_value))
			print("Cout output: ", output_cout.received_value)
		else:
			player_cout_outputs.append(0)
	
	print("=== Test results ===")
	print("Player S1: ", player_s1_outputs)
	print("Expected S1: ", level_data.expected_s1)
	print("Player S0: ", player_s0_outputs)
	print("Expected S0: ", level_data.expected_s0)
	print("Player Cout: ", player_cout_outputs)
	print("Expected Cout: ", level_data.expected_cout)

	if test_results_panel and test_results_panel.has_method("update_current_outputs"):
		test_results_panel.update_current_outputs(player_s1_outputs, player_s0_outputs, player_cout_outputs)
		print("Test panel updated")

	var s1_correct = true
	var s0_correct = true
	var cout_correct = true

	for i in range(16):
		if player_s1_outputs[i] != level_data.expected_s1[i]:
			s1_correct = false
		if player_s0_outputs[i] != level_data.expected_s0[i]:
			s0_correct = false
		if player_cout_outputs[i] != level_data.expected_cout[i]:
			cout_correct = false
	
	print("S1 correct: ", s1_correct, " S0 correct: ", s0_correct, " Cout correct: ", cout_correct)
	
	if s1_correct and s0_correct and cout_correct:
		if output_s1:
			output_s1.set_correct_style()
		if output_s0:
			output_s0.set_correct_style()
		if output_cout:
			output_cout.set_correct_style()
		if not level_completed_this_session:
			save_level_progress()
			level_completed_this_session = true
		print("Level completed successfully!")
	else:
		if output_s1:
			output_s1.set_default_style()
		if output_s0:
			output_s0.set_default_style()
		if output_cout:
			output_cout.set_default_style()
		level_completed_this_session = false
		print("Level not completed - outputs don't match")
	
	update_all_port_colors()

func propagate_signals():
	print("=== Starting signal propagation for 2-Bit Adder ===")

	for obj in all_logic_objects:
		if obj and obj.has_method("reset_inputs"):
			obj.reset_inputs()
			print("Reset inputs for: ", obj.name)

	var dependencies = {}
	var dependents = {}

	for obj in all_logic_objects:
		if not obj or not is_instance_valid(obj):
			continue
		dependencies[obj] = []
		dependents[obj] = []

	for wire in wires:
		if not wire or not is_instance_valid(wire):
			continue
		if not wire.start_port or not is_instance_valid(wire.start_port):
			continue
		if not wire.end_port or not is_instance_valid(wire.end_port):
			continue
			
		var start_gate = wire.start_port.get_parent()
		var end_gate = wire.end_port.get_parent()
		
		if not start_gate or not is_instance_valid(start_gate) or not end_gate or not is_instance_valid(end_gate):
			continue
		
		if start_gate != end_gate:
			if dependencies.has(end_gate) and not dependencies[end_gate].has(start_gate):
				dependencies[end_gate].append(start_gate)
			if dependents.has(start_gate) and not dependents[start_gate].has(end_gate):
				dependents[start_gate].append(end_gate)
			print("Wire: ", start_gate.name, " -> ", end_gate.name)

	var queue = []
	var in_degree = {}
	
	for obj in all_logic_objects:
		if not obj or not is_instance_valid(obj):
			continue
		in_degree[obj] = dependencies[obj].size() if dependencies.has(obj) else 0
		if in_degree[obj] == 0:
			queue.append(obj)
	
	var processed_order = []
	
	while queue.size() > 0:
		var current = queue.pop_front()
		if not current or not is_instance_valid(current):
			continue
		processed_order.append(current)
		
		if dependents.has(current):
			for dependent in dependents[current]:
				if not dependent or not is_instance_valid(dependent):
					continue
				if in_degree.has(dependent):
					in_degree[dependent] -= 1
					if in_degree[dependent] == 0:
						queue.append(dependent)

	print("Processing order: ", processed_order.size(), " objects")
	for obj in processed_order:
		print("  - ", obj.name)

	for current in processed_order:
		if not current or not is_instance_valid(current):
			continue
			
		print("Processing: ", current.name)

		if current in [input_block_a, input_block_b]:
			for port_name in ["OutputA", "OutputB"]:
				var port = current.get_node_or_null(port_name)
				if port and is_instance_valid(port):
					for wire in wires:
						if not wire or not is_instance_valid(wire):
							continue
						if wire.start_port == port:
							var end_gate = wire.end_port.get_parent()
							var end_port_name = wire.end_port.name
							var val = int(current.get_output(port_name))
							
							print("  Sending value ", val, " from ", current.name, ".", port_name, " to ", end_gate.name, ".", end_port_name)
							
							if end_gate and end_gate.has_method("set_input"):
								var port_num = 1
								if end_port_name == "Input2":
									port_num = 2
								elif end_port_name == "Input3":
									port_num = 3
								elif end_port_name == "InputPort":
									port_num = 1
								elif end_port_name == "Input":
									port_num = 1
								
								print("  Setting input for ", end_gate.name, " port ", port_num, " to ", val)
								end_gate.set_input(port_num, val)

		elif current.has_method("get_output"):

			for wire in wires:
				if not wire or not is_instance_valid(wire):
					continue
				if not wire.start_port or not is_instance_valid(wire.start_port):
					continue
					
				if wire.start_port.get_parent() == current:
					var start_port_name = wire.start_port.name
					var output_value = int(current.get_output(start_port_name))
					
					var end_gate = wire.end_port.get_parent()
					if not end_gate or not is_instance_valid(end_gate):
						continue
						
					var end_port_name = wire.end_port.name
					
					print("  Sending value ", output_value, " from ", current.name, ".", start_port_name, " to ", end_gate.name, ".", end_port_name)
					
					if end_gate.has_method("set_input"):
						var port_num = 1
						if end_port_name == "Input2":
							port_num = 2
						elif end_port_name == "Input3":
							port_num = 3
						elif end_port_name == "InputPort":
							port_num = 1
						elif end_port_name == "Input":
							port_num = 1
						
						print("  Setting input for ", end_gate.name, " port ", port_num, " to ", output_value)
						end_gate.set_input(port_num, output_value)
	
	print("Final OutputS1 value: ", output_s1.received_value if output_s1 else "N/A")
	print("Final OutputS0 value: ", output_s0.received_value if output_s0 else "N/A")
	print("Final OutputCout value: ", output_cout.received_value if output_cout else "N/A")
	print("=== Signal propagation complete ===")

func get_gates_data():
	var gates_data = []

	if input_block_a and is_instance_valid(input_block_a):
		var input_block_data = {
			"type": "INPUT_BLOCK_A",
			"position": [input_block_a.position.x, input_block_a.position.y]
		}
		gates_data.append(input_block_data)
	
	if input_block_b and is_instance_valid(input_block_b):
		var input_block_data = {
			"type": "INPUT_BLOCK_B", 
			"position": [input_block_b.position.x, input_block_b.position.y]
		}
		gates_data.append(input_block_data)

	if output_s1 and is_instance_valid(output_s1):
		var output_block_data = {
			"type": "OUTPUT_S1",
			"position": [output_s1.position.x, output_s1.position.y]
		}
		gates_data.append(output_block_data)
	
	if output_s0 and is_instance_valid(output_s0):
		var output_block_data = {
			"type": "OUTPUT_S0",
			"position": [output_s0.position.x, output_s0.position.y]
		}
		gates_data.append(output_block_data)
	
	if output_cout and is_instance_valid(output_cout):
		var output_block_data = {
			"type": "OUTPUT_COUT",
			"position": [output_cout.position.x, output_cout.position.y]
		}
		gates_data.append(output_block_data)

	for obj in movable_objects:
		var skip = false

		if obj in [input_block_a, input_block_b, output_s1, output_s0, output_cout]:
			skip = true

		if skip:
			continue
			
		var scene_file = obj.scene_file_path
		var gate_type = "UNKNOWN"

		if "XNORGate" in scene_file:
			gate_type = "XNOR"
		elif "XORGate" in scene_file:
			gate_type = "XOR"
		elif "NANDGate" in scene_file:
			gate_type = "NAND"
		elif "NORGate" in scene_file:
			gate_type = "NOR"
		elif "ANDGate" in scene_file:
			gate_type = "AND"
		elif "ORGate" in scene_file:
			gate_type = "OR"
		elif "NOTGate" in scene_file:
			gate_type = "NOT"
		elif "ImplicationGate" in scene_file:
			gate_type = "IMPLICATION"
		elif "Sel0" in scene_file:
			gate_type = "SEL0"
		elif "Sel1" in scene_file:
			gate_type = "SEL1"
		elif "HalfAdder" in scene_file:
			gate_type = "HALF_ADDER"
		elif "FullAdder" in scene_file:
			gate_type = "FULL_ADDER"
		elif "Cout0" in scene_file:
			gate_type = "COUT0"
		
		var gate_data = {
			"type": gate_type,
			"position": [obj.position.x, obj.position.y]
		}
		gates_data.append(gate_data)
	
	return gates_data

func clear_level():
	for wire in wires:
		if is_instance_valid(wire):
			wire.queue_free()
	wires.clear()

	for i in range(movable_objects.size() - 1, -1, -1):
		var obj = movable_objects[i]

		var skip = false
		if obj in [input_block_a, input_block_b, output_s1, output_s0, output_cout]:
			skip = true

		if skip:
			continue
			
		if is_instance_valid(obj):
			obj.queue_free()
		movable_objects.remove_at(i)
	
	update_all_logic_objects()
	reset_all_port_sprites()
	
	print("2-Bit Adder level cleared - kept Input/Output blocks, removed gates and wires")
	
func create_gate_from_data(gate_data):
	var gate_type = gate_data.get("type", "")
	var position_array = gate_data.get("position", [0, 0])
	var position = Vector2(position_array[0], position_array[1])

	if gate_type == "INPUT_BLOCK_A" and input_block_a:
		input_block_a.position = position
		print("Restored InputBlockA position: ", position)
		return
	elif gate_type == "INPUT_BLOCK_B" and input_block_b:
		input_block_b.position = position
		print("Restored InputBlockB position: ", position)
		return

	elif gate_type == "OUTPUT_S1" and output_s1:
		output_s1.position = position
		print("Restored OutputS1 position: ", position)
		return
	elif gate_type == "OUTPUT_S0" and output_s0:
		output_s0.position = position
		print("Restored OutputS0 position: ", position)
		return
	elif gate_type == "OUTPUT_COUT" and output_cout:
		output_cout.position = position
		print("Restored OutputCout position: ", position)
		return

	var gate_scene = null
	
	match gate_type:
		"AND":
			gate_scene = preload("res://scenes/gates/ANDGate.tscn")
		"OR":
			gate_scene = preload("res://scenes/gates/ORGate.tscn")
		"NOT":
			gate_scene = preload("res://scenes/gates/NOTGate.tscn")
		"XOR":
			gate_scene = preload("res://scenes/gates/XORGate.tscn")
		"NAND":
			gate_scene = preload("res://scenes/gates/NANDGate.tscn")
		"NOR":
			gate_scene = preload("res://scenes/gates/NORGate.tscn")
		"XNOR":
			gate_scene = preload("res://scenes/gates/XNORGate.tscn")
		"IMPLICATION":
			gate_scene = preload("res://scenes/gates/ImplicationGate.tscn")
		"SEL0":
			gate_scene = preload("res://scenes/gates/Sel0.tscn")
		"SEL1":
			gate_scene = preload("res://scenes/gates/Sel1.tscn")
		"HALF_ADDER":
			gate_scene = preload("res://scenes/gates/HalfAdder.tscn")
		"FULL_ADDER":
			gate_scene = preload("res://scenes/gates/FullAdder.tscn")
		"COUT0":
			gate_scene = preload("res://scenes/gates/Cout0.tscn")
	
	if gate_scene:
		var gate = gate_scene.instantiate()
		gate.position = position
		add_child(gate)
		movable_objects.append(gate)
		print("Restored gate: ", gate_type, " at ", position)

func find_port_by_name(parent_name, port_name):
	var parent = null

	if parent_name == "InputBlockA" and input_block_a:
		parent = input_block_a
	elif parent_name == "InputBlockB" and input_block_b:
		parent = input_block_b
	
	elif parent_name == "OutputS1" and output_s1:
		parent = output_s1
	elif parent_name == "OutputS0" and output_s0:
		parent = output_s0
	elif parent_name == "OutputCout" and output_cout:
		parent = output_cout

	if not parent:
		for obj in movable_objects:
			if obj and obj.name == parent_name:
				parent = obj
				break
	
	if not parent:
		print("Parent not found: ", parent_name)
		return null

	var port = null
	if port_name is String or port_name is NodePath:
		port = parent.get_node_or_null(port_name)
	else:
		port = parent.get_node_or_null(str(port_name))
	
	if not port:
		print("Port not found: ", parent_name, "/", port_name)
		print("Available children in ", parent_name, ":")
		for child in parent.get_children():
			print("  - ", child.name, " (Type: ", child.get_class(), ")")
	
	return port

func get_object_type(obj):
	if obj == null:
		return "UNKNOWN"
	
	if obj.is_in_group("Sel0"):
		return "SEL0"
	if obj.is_in_group("Sel1"):
		return "SEL1"
	if obj.is_in_group("HalfAdder"):
		return "HALF_ADDER"
	if obj.is_in_group("FullAdder"):
		return "FULL_ADDER"
	if obj.is_in_group("Cout0"):
		return "COUT0"
	
	var scene_file = obj.scene_file_path
	if "ANDGate" in scene_file:
		return "AND"
	elif "ORGate" in scene_file:
		return "OR" 
	elif "NOTGate" in scene_file:
		return "NOT"
	elif "XORGate" in scene_file:
		return "XOR"
	elif "NANDGate" in scene_file:
		return "NAND"
	elif "NORGate" in scene_file:
		return "NOR"
	elif "XNORGate" in scene_file:
		return "XNOR"
	elif "ImplicationGate" in scene_file:
		return "IMPLICATION"
	elif "HalfAdder" in scene_file:
		return "HALF_ADDER"
	elif "FullAdder" in scene_file:
		return "FULL_ADDER"
	elif "Cout0" in scene_file:
		return "COUT0"

	if obj == input_block_a:
		return "INPUT_BLOCK_A"
	elif obj == input_block_b:
		return "INPUT_BLOCK_B"
	elif obj == output_s1:
		return "OUTPUT_S1"
	elif obj == output_s0:
		return "OUTPUT_S0"
	elif obj == output_cout:
		return "OUTPUT_COUT"
	
	return "UNKNOWN"

func find_port_near_position(position, max_distance = 50.0):
	var closest_port = null
	var closest_distance = max_distance
	
	for obj in movable_objects:
		if not obj or not is_instance_valid(obj):
			continue
			
		var ports = []

		if obj in [input_block_a, input_block_b]:
			var output_a = obj.get_node_or_null("OutputA")
			var output_b = obj.get_node_or_null("OutputB")
			if output_a: ports.append(output_a)
			if output_b: ports.append(output_b)

		elif obj in [output_s1, output_s0, output_cout]:
			var input_port = obj.get_node_or_null("InputPort")
			if input_port: ports.append(input_port)

		elif obj.is_in_group("HalfAdder") or obj.is_in_group("FullAdder") or obj.is_in_group("Cout0"):
			var input1 = obj.get_node_or_null("Input1")
			var input2 = obj.get_node_or_null("Input2")
			var input3 = obj.get_node_or_null("Input3")
			var output_sum = obj.get_node_or_null("OutputSum")
			var output_carry = obj.get_node_or_null("OutputCarry")
			var output = obj.get_node_or_null("Output")
			
			if input1: ports.append(input1)
			if input2: ports.append(input2)
			if input3: ports.append(input3)
			if output_sum: ports.append(output_sum)
			if output_carry: ports.append(output_carry)
			if output: ports.append(output)

		else:
			var input1 = obj.get_node_or_null("Input1")
			var input2 = obj.get_node_or_null("Input2")
			var input_port = obj.get_node_or_null("InputPort")
			var output = obj.get_node_or_null("Output")
			
			if input1: ports.append(input1)
			if input2: ports.append(input2)
			if input_port: ports.append(input_port)
			if output: ports.append(output)
		
		for port in ports:
			if port and is_instance_valid(port):
				var port_pos = port.global_position
				var distance = port_pos.distance_to(position)
				if distance < closest_distance:
					closest_distance = distance
					closest_port = port
	
	return closest_port

func reset_all_port_sprites():

	for input_block in [input_block_a, input_block_b]:
		if input_block and is_instance_valid(input_block):
			for port_name in ["OutputA", "OutputB"]:
				var port = input_block.get_node_or_null(port_name)
				if port and is_instance_valid(port):
					var sprite = port.get_node_or_null("Sprite2D")
					if sprite and is_instance_valid(sprite):
						sprite.texture = preload("res://assets/point.png")

	for output_block in [output_s1, output_s0, output_cout]:
		if output_block and is_instance_valid(output_block):
			var input_port = output_block.get_node_or_null("InputPort")
			if input_port and is_instance_valid(input_port):
				var sprite = input_port.get_node_or_null("Sprite2D")
				if sprite and is_instance_valid(sprite):
					sprite.texture = preload("res://assets/point.png")

	for obj in movable_objects:
		if not obj or not is_instance_valid(obj):
			continue

		var skip = false
		if obj in [input_block_a, input_block_b, output_s1, output_s0, output_cout]:
			skip = true

		if skip:
			continue

		var ports = []

		if obj.is_in_group("HalfAdder") or obj.is_in_group("FullAdder") or obj.is_in_group("Cout0"):
			var input1 = obj.get_node_or_null("Input1")
			var input2 = obj.get_node_or_null("Input2")
			var input3 = obj.get_node_or_null("Input3")
			var output_sum = obj.get_node_or_null("OutputSum")
			var output_carry = obj.get_node_or_null("OutputCarry")
			var output = obj.get_node_or_null("Output")
			
			if input1: ports.append(input1)
			if input2: ports.append(input2)
			if input3: ports.append(input3)
			if output_sum: ports.append(output_sum)
			if output_carry: ports.append(output_carry)
			if output: ports.append(output)

		else:
			var possible_port_names = ["Input1", "Input2", "InputPort", "Output"]
			
			for port_name in possible_port_names:
				var port = obj.get_node_or_null(port_name)
				if port and is_instance_valid(port):
					ports.append(port)

		for port in ports:
			var sprite = port.get_node_or_null("Sprite2D")
			if sprite and is_instance_valid(sprite):
				sprite.texture = preload("res://assets/point.png")
	
	print("2-Bit Adder level: Reset all port sprites")

func _ready():
	if not level_data:
		push_error("Level data not set!")
		return
	
	wires = []
	movable_objects = []
	all_logic_objects = []
	test_results_panel = null
	
	is_three_input_level = false
	
	if has_node("TopPanel") and $TopPanel.has_method("set_level_name"):
		$TopPanel.set_level_name(level_data.level_name)
		$TopPanel.set_theory_text(level_data.theory_text)

	setup_two_bit_adder_level()
	
	temp_line = Line2D.new()
	add_child(temp_line)
	temp_line.default_color = Color("#e39e45")
	temp_line.width = 8
	temp_line.points = []
	
	_setup_top_panel_buttons()
	
	await get_tree().process_frame

	if test_results_panel and test_results_panel.has_method("load_initial_data"):
		test_results_panel.load_initial_data(
			level_data.input_values_a1,
			level_data.input_values_a0,
			level_data.input_values_b1,
			level_data.input_values_b0,
			level_data.expected_s1,
			level_data.expected_s0,
			level_data.expected_cout
		)

	load_level_state()

	auto_save_timer = Timer.new()
	auto_save_timer.wait_time = 2.0
	auto_save_timer.one_shot = true
	auto_save_timer.timeout.connect(_on_auto_save_timeout)
	add_child(auto_save_timer)
	
	print("2-Bit Adder level ready completed successfully")
	
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var port = get_port_under_mouse()
			if port and is_instance_valid(port):
				drawing_wire = true
				start_port = port
			else:
				for obj in movable_objects:
					if not is_instance_valid(obj):
						continue
					var sprite = obj.get_node_or_null("Sprite2D")
					if sprite and is_instance_valid(sprite):
						var local_mouse = sprite.to_local(get_global_mouse_position())
						var sprite_rect = sprite.get_rect()
						if sprite_rect.has_point(local_mouse):
							dragging_object = obj
							drag_offset = obj.global_position - get_global_mouse_position()
							break
		else:
			if drawing_wire and start_port and is_instance_valid(start_port):
				var end_port = get_port_under_mouse()
				if end_port and is_instance_valid(end_port) and end_port != start_port:
					var wire = preload("res://scenes/components/Wire.tscn").instantiate()
					wire.connect_ports(start_port, end_port)
					add_child(wire)
					wires.append(wire)
					update_all_port_colors()
					mark_level_state_dirty()
					print("Created new wire")
				drawing_wire = false
				temp_line.points = []
			dragging_object = null
			drag_offset = Vector2.ZERO
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		var mouse_pos = get_global_mouse_position()
		var object_removed = false

		for i in range(movable_objects.size() - 1, -1, -1):
			var obj = movable_objects[i]
			var skip = false

			if obj in [input_block_a, input_block_b, output_s1, output_s0, output_cout]:
				skip = true

			if skip:
				continue
				
			var sprite = obj.get_node_or_null("Sprite2D")
			if sprite and is_instance_valid(sprite):
				var local_mouse = sprite.to_local(mouse_pos)
				var sprite_rect = sprite.get_rect()
				if sprite_rect.has_point(local_mouse):
					remove_wires_connected_to_gate(obj)
					obj.queue_free()
					movable_objects.remove_at(i)
					update_all_logic_objects()
					object_removed = true
					mark_level_state_dirty()
					print("Object removed: ", obj.name)
					break

		if not object_removed:
			for i in range(wires.size() - 1, -1, -1):
				var wire = wires[i]
				if not wire or not is_instance_valid(wire):
					wires.remove_at(i)
					continue
					
				var wire_points = wire.get_points()
				if wire_points.size() >= 2:
					var closest_point = get_closest_point_on_line(wire_points, mouse_pos)
					if closest_point.distance_to(mouse_pos) < 15:
						remove_wire(wire)
						mark_level_state_dirty()
						print("Wire removed")
						break
