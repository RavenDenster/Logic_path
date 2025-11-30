extends "res://scripts/levels/LevelBase.gd"

var input_block_clk
var output_block_q0
var output_block_q1

func _ready():
	if not level_data:
		push_error("Level data not set!")
		return
	
	wires = []
	movable_objects = []
	all_logic_objects = []
	
	if has_node("TopPanel") and $TopPanel.has_method("set_level_name"):
		$TopPanel.set_level_name(level_data.level_name)
		$TopPanel.set_theory_text(level_data.theory_text)

	setup_bit_counter_level()
	
	temp_line = Line2D.new()
	add_child(temp_line)
	temp_line.default_color = Color("#e39e45")
	temp_line.width = 8
	temp_line.points = []
	
	_setup_top_panel_buttons()
	
	await get_tree().process_frame

	if test_results_panel and test_results_panel.has_method("load_initial_data"):
		test_results_panel.load_initial_data(
			level_data.input_values_clk,
			level_data.expected_q0,
			level_data.expected_q1
		)

	load_level_state()

	auto_save_timer = Timer.new()
	auto_save_timer.wait_time = 2.0
	auto_save_timer.one_shot = true
	auto_save_timer.timeout.connect(_on_auto_save_timeout)
	add_child(auto_save_timer)
	
	print("2-bit Counter level ready completed successfully")

func setup_bit_counter_level():
	print("Setting up 2-bit Counter level with one clock input and two outputs")
	
	movable_objects = []
	
	# Get input block using simple get_node
	input_block_clk = get_node_or_null("InputBlockCLK")
	
	if input_block_clk:
		input_block_clk.values = level_data.input_values_clk.duplicate()
		movable_objects.append(input_block_clk)
		print("Clock input block initialized")
	else:
		push_error("Clock input block not found in 2-bit Counter level!")

	# Get output blocks using simple get_node
	output_block_q0 = get_node_or_null("OutputBlockQ0")
	output_block_q1 = get_node_or_null("OutputBlockQ1")
	
	if output_block_q0 and output_block_q1:
		output_block_q0.expected = level_data.expected_q0.duplicate()
		output_block_q1.expected = level_data.expected_q1.duplicate()
		movable_objects.append(output_block_q0)
		movable_objects.append(output_block_q1)
		print("2-bit Counter output blocks initialized")
	else:
		push_error("Output blocks not found in 2-bit Counter level!")

	test_results_panel = get_node_or_null("TestResultsPanelBitCounter")
	if test_results_panel:
		print("2-bit Counter test panel found")

	update_all_logic_objects()
	print("Movable objects: ", movable_objects.size())
	print("All logic objects: ", all_logic_objects.size())

func _on_test_pressed():
	print("=== Testing 2-bit Counter level ===")
	print("=== EXPECTED: Q0=", level_data.expected_q0, " Q1=", level_data.expected_q1, " ===")
	reset_all_port_sprites()

	if output_block_q0:
		output_block_q0.set_default_style()
	if output_block_q1:
		output_block_q1.set_default_style()
	
	var player_q0_outputs = []
	var player_q1_outputs = []
	
	# COMPLETE RESET before test
	print("=== RESETTING ALL COMPONENTS ===")
	for obj in all_logic_objects:
		if obj and obj.has_method("reset_inputs"):
			print("Resetting: ", obj.name)
			obj.reset_inputs()
	
	# Force T=1 for all T-flip-flops
	print("=== SETTING T=1 FOR ALL T-FLIPFLOPS ===")
	for obj in all_logic_objects:
		if obj and obj.has_method("set_input"):
			var obj_type = get_object_type(obj)
			if obj_type == "TFLIPFLOP":
				print("Setting T=1 for: ", obj.name)
				obj.set_input(2, 1)  # Set T=1
	
	# Debug: print all T-flip-flops and their edge types
	print("=== T-FLIPFLOP CONFIGURATION ===")
	var tff_count = 0
	for obj in all_logic_objects:
		if get_object_type(obj) == "TFLIPFLOP":
			tff_count += 1
			if obj.has_method("set_edge_type"):
				var edge_type = "UNKNOWN"
				# We can't directly read is_falling_edge, so we'll infer from behavior
				print("TFF ", tff_count, ": ", obj.name)
	print("Total TFF count: ", tff_count)
	
	# Test each clock cycle sequentially using REAL circuit
	for i in range(6):
		print("\n--- Clock cycle ", i, " ---")
		input_block_clk.current_test_index = i
		var clk_value = input_block_clk.values[i]
		print("CLK input: ", clk_value)
		
		# Reset output blocks for new measurement
		if output_block_q0:
			output_block_q0.received_value = 0
		if output_block_q1:
			output_block_q1.received_value = 0
			
		# Propagate signals for this clock cycle
		propagate_signals()
		
		# Read outputs from the actual circuit
		var q0_value = 0
		var q1_value = 0
		
		if output_block_q0:
			q0_value = int(output_block_q0.received_value)
		if output_block_q1:
			q1_value = int(output_block_q1.received_value)
		
		player_q0_outputs.append(q0_value)
		player_q1_outputs.append(q1_value)
		
		print("=== CLOCK CYCLE ", i, " RESULTS: Q0=", q0_value, " Q1=", q1_value, " ===")
	
	print("\n=== FINAL TEST RESULTS ===")
	print("Player Q0: ", player_q0_outputs)
	print("Expected Q0: ", level_data.expected_q0)
	print("Player Q1: ", player_q1_outputs)
	print("Expected Q1: ", level_data.expected_q1)

	if test_results_panel and test_results_panel.has_method("update_current_outputs"):
		test_results_panel.update_current_outputs(player_q0_outputs, player_q1_outputs)
		print("Test panel updated")

	var q0_correct = player_q0_outputs == level_data.expected_q0
	var q1_correct = player_q1_outputs == level_data.expected_q1
	
	print("Q0 correct: ", q0_correct, " Q1 correct: ", q1_correct)
	
	if q0_correct and q1_correct:
		if output_block_q0:
			output_block_q0.set_correct_style()
		if output_block_q1:
			output_block_q1.set_correct_style()
		if not level_completed_this_session:
			save_level_progress()
			level_completed_this_session = true
		print("=== LEVEL COMPLETED SUCCESSFULLY! ===")
	else:
		if output_block_q0:
			output_block_q0.set_default_style()
		if output_block_q1:
			output_block_q1.set_default_style()
		level_completed_this_session = false
		print("=== LEVEL NOT COMPLETED - OUTPUTS DON'T MATCH ===")
	
	update_all_port_colors()

func propagate_signals():
	print("=== STARTING SIGNAL PROPAGATION ===")

	# Create dependency graph
	var dependencies = {}
	var dependents = {}

	print("Building dependency graph...")
	for obj in all_logic_objects:
		if not obj or not is_instance_valid(obj):
			continue
		dependencies[obj] = []
		dependents[obj] = []
		print("  Object: ", obj.name)

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
			print("  Wire: ", start_gate.name, " -> ", end_gate.name)

	var queue = []
	var in_degree = {}
	
	print("Calculating topological order...")
	for obj in all_logic_objects:
		if not obj or not is_instance_valid(obj):
			continue
		in_degree[obj] = dependencies[obj].size() if dependencies.has(obj) else 0
		if in_degree[obj] == 0:
			queue.append(obj)
			print("  Root node: ", obj.name, " (dependencies: ", in_degree[obj], ")")
	
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

	# Now traverse in topological order and propagate signals
	for current in processed_order:
		if not current or not is_instance_valid(current):
			continue
			
		print("Processing: ", current.name)
			
		if current == input_block_clk:
			var output_value = int(current.get_output("Output"))
			print("  InputBlockCLK output: ", output_value)
			
			for wire in wires:
				if not wire or not is_instance_valid(wire):
					continue
				if not wire.start_port or not is_instance_valid(wire.start_port):
					continue
					
				if wire.start_port.get_parent() == current:
					var end_gate = wire.end_port.get_parent()
					if not end_gate or not is_instance_valid(end_gate):
						continue
						
					var end_port_name = wire.end_port.name
					
					if end_gate.has_method("set_input"):
						var port_num = 1
						if end_port_name == "CLK":
							port_num = 1
						elif end_port_name == "T":
							port_num = 2
						
						print("  Sending value ", output_value, " to ", end_gate.name, " port ", port_num)
						end_gate.set_input(port_num, output_value)

		elif current.has_method("get_output") and current != output_block_q0 and current != output_block_q1:
			var output_value = int(current.get_output("Q"))
			print("  ", current.name, " output: ", output_value)
			
			for wire in wires:
				if not wire or not is_instance_valid(wire):
					continue
				if not wire.start_port or not is_instance_valid(wire.start_port):
					continue
					
				if wire.start_port.get_parent() == current:
					var end_gate = wire.end_port.get_parent()
					if not end_gate or not is_instance_valid(end_gate):
						continue
						
					var end_port_name = wire.end_port.name
					
					if end_gate.has_method("set_input"):
						var port_num = 1
						if end_port_name == "CLK":
							port_num = 1
						elif end_port_name == "T":
							port_num = 2
						
						print("  Sending value ", output_value, " to ", end_gate.name, " port ", port_num)
						end_gate.set_input(port_num, output_value)
	
	# Set values on output blocks
	print("Setting output block values...")
	for wire in wires:
		if not wire or not is_instance_valid(wire):
			continue
		if not wire.start_port or not is_instance_valid(wire.start_port):
			continue
		if not wire.end_port or not is_instance_valid(wire.end_port):
			continue
			
		var start_gate = wire.start_port.get_parent()
		var end_gate = wire.end_port.get_parent()
		
		if end_gate == output_block_q0 or end_gate == output_block_q1:
			var output_value = 0
			if start_gate.has_method("get_output"):
				output_value = int(start_gate.get_output("Q"))
			elif start_gate == input_block_clk:
				output_value = int(start_gate.get_output("Output"))
			
			if end_gate.has_method("set_input"):
				print("  Output ", output_value, " from ", start_gate.name, " to ", end_gate.name)
				end_gate.set_input(1, output_value)
	
	print("=== SIGNAL PROPAGATION COMPLETE ===")

func get_gates_data():
	var gates_data = []

	if input_block_clk:
		var input_block_clk_data = {
			"type": "INPUT_BLOCK_CLK",
			"position": [input_block_clk.position.x, input_block_clk.position.y]
		}
		gates_data.append(input_block_clk_data)
	
	if output_block_q0:
		var output_block_q0_data = {
			"type": "OUTPUT_BLOCK_Q0", 
			"position": [output_block_q0.position.x, output_block_q0.position.y]
		}
		gates_data.append(output_block_q0_data)
	
	if output_block_q1:
		var output_block_q1_data = {
			"type": "OUTPUT_BLOCK_Q1", 
			"position": [output_block_q1.position.x, output_block_q1.position.y]
		}
		gates_data.append(output_block_q1_data)

	for obj in movable_objects:
		var skip = false

		if obj == input_block_clk or obj == output_block_q0 or obj == output_block_q1:
			skip = true

		if skip:
			continue
			
		var scene_file = obj.scene_file_path
		var gate_type = "UNKNOWN"

		if "TFlipFlopGate" in scene_file:
			gate_type = "TFLIPFLOP"

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
		if obj == input_block_clk or obj == output_block_q0 or obj == output_block_q1:
			skip = true

		if skip:
			continue
			
		if is_instance_valid(obj):
			obj.queue_free()
		movable_objects.remove_at(i)
	
	update_all_logic_objects()
	reset_all_port_sprites()
	
	print("2-bit Counter level cleared - kept Input/Output blocks, removed gates and wires")
	
func create_gate_from_data(gate_data):
	var gate_type = gate_data.get("type", "")
	var position_array = gate_data.get("position", [0, 0])
	var position = Vector2(position_array[0], position_array[1])
	
	if gate_type == "INPUT_BLOCK_CLK" and input_block_clk:
		input_block_clk.position = position
		print("Restored InputBlockCLK position: ", position)
		return
	elif gate_type == "OUTPUT_BLOCK_Q0" and output_block_q0:
		output_block_q0.position = position
		print("Restored OutputBlockQ0 position: ", position)
		return
	elif gate_type == "OUTPUT_BLOCK_Q1" and output_block_q1:
		output_block_q1.position = position
		print("Restored OutputBlockQ1 position: ", position)
		return

	var gate_scene = null
	
	match gate_type:
		"TFLIPFLOP":
			gate_scene = load("res://scenes/gates/TFlipFlopGate.tscn")
	
	if gate_scene:
		var gate = gate_scene.instantiate()
		gate.position = position
		
		# При восстановлении определяем, какой это триггер
		var existing_tff_count = 0
		for obj in movable_objects:
			if obj.is_in_group("TFlipFlop"):
				existing_tff_count += 1
				print("Found existing TFF during restore: ", obj.name)
		
		print("Restoring TFF #", existing_tff_count + 1)
		
		# Второй T-триггер должен срабатывать на falling edge
		if existing_tff_count == 1 and gate.has_method("set_edge_type"):
			gate.set_edge_type(true)
			print(">>> Restored second TFlipFlop with FALLING edge")
		else:
			print(">>> Restored TFlipFlop with RISING edge (default)")
		
		add_child(gate)
		movable_objects.append(gate)
		print("Restored gate: ", gate_type, " at ", position)

func find_port_by_name(parent_name, port_name):
	var parent = null
	
	if parent_name == "InputBlockCLK" and input_block_clk:
		parent = input_block_clk
	elif parent_name == "OutputBlockQ0" and output_block_q0:
		parent = output_block_q0
	elif parent_name == "OutputBlockQ1" and output_block_q1:
		parent = output_block_q1

	if not parent:
		for obj in movable_objects:
			if obj and obj.name == parent_name:
				parent = obj
				break
	
	if not parent:
		print("Parent not found: ", parent_name)
		return null

	var port = parent.get_node_or_null(str(port_name))
	
	if not port:
		print("Port not found: ", parent_name, "/", port_name)
	
	return port

func get_object_type(obj):
	if obj == null:
		return "UNKNOWN"
	
	if obj.is_in_group("TFlipFlop"):
		return "TFLIPFLOP"
	
	var scene_file = obj.scene_file_path
	if "TFlipFlopGate" in scene_file:
		return "TFLIPFLOP"

	if obj == input_block_clk:
		return "INPUT_BLOCK_CLK"
	elif obj == output_block_q0:
		return "OUTPUT_BLOCK_Q0"
	elif obj == output_block_q1:
		return "OUTPUT_BLOCK_Q1"
	
	return "UNKNOWN"

func find_port_near_position(position, max_distance = 50.0):
	var closest_port = null
	var closest_distance = max_distance
	
	for obj in movable_objects:
		if not obj or not is_instance_valid(obj):
			continue
			
		var ports = []

		if obj == input_block_clk:
			var output = obj.get_node_or_null("Output")
			if output: ports.append(output)
		elif obj == output_block_q0 or obj == output_block_q1:
			var input_port = obj.get_node_or_null("InputPort")
			if input_port: ports.append(input_port)
		else:
			var clk = obj.get_node_or_null("CLK")
			var t = obj.get_node_or_null("T")
			var q = obj.get_node_or_null("Q")
			
			if clk: ports.append(clk)
			if t: ports.append(t)
			if q: ports.append(q)
		
		for port in ports:
			if port and is_instance_valid(port):
				var port_pos = port.global_position
				var distance = port_pos.distance_to(position)
				if distance < closest_distance:
					closest_distance = distance
					closest_port = port
	
	return closest_port

func reset_all_port_sprites():
	if input_block_clk:
		var output_port = input_block_clk.get_node_or_null("Output")
		if output_port and is_instance_valid(output_port):
			var sprite = output_port.get_node_or_null("Sprite2D")
			if sprite and is_instance_valid(sprite):
				sprite.texture = load("res://assets/point.png")

	if output_block_q0:
		var input_port = output_block_q0.get_node_or_null("InputPort")
		if input_port and is_instance_valid(input_port):
			var sprite = input_port.get_node_or_null("Sprite2D")
			if sprite and is_instance_valid(sprite):
				sprite.texture = load("res://assets/point.png")

	if output_block_q1:
		var input_port = output_block_q1.get_node_or_null("InputPort")
		if input_port and is_instance_valid(input_port):
			var sprite = input_port.get_node_or_null("Sprite2D")
			if sprite and is_instance_valid(sprite):
				sprite.texture = load("res://assets/point.png")

	for obj in movable_objects:
		if not obj or not is_instance_valid(obj):
			continue

		if obj == input_block_clk or obj == output_block_q0 or obj == output_block_q1:
			continue

		var ports = []
		var possible_port_names = ["CLK", "T", "Q"]
		
		for port_name in possible_port_names:
			var port = obj.get_node_or_null(port_name)
			if port and is_instance_valid(port):
				ports.append(port)

		for port in ports:
			var sprite = port.get_node_or_null("Sprite2D")
			if sprite and is_instance_valid(sprite):
				sprite.texture = load("res://assets/point.png")
	
	print("2-bit Counter level: Reset all port sprites")

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
					var wire = load("res://scenes/components/Wire.tscn").instantiate()
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

			if obj == input_block_clk or obj == output_block_q0 or obj == output_block_q1:
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

func _on_add_tflipflop_button_pressed():
	print("=== ADDING T-FLIPFLOP ===")
	var gate_scene = load("res://scenes/gates/TFlipFlopGate.tscn")
	var gate = gate_scene.instantiate()
	
	var viewport_size = get_viewport_rect().size
	gate.position = Vector2(viewport_size.x / 2, viewport_size.y / 2)
	
	# Определяем, какой это по счету T-триггер
	var tff_count = 0
	for obj in movable_objects:
		if obj.is_in_group("TFlipFlop"):
			tff_count += 1
			print("Found existing TFF: ", obj.name)
	
	print("Current TFF count before adding: ", tff_count)
	
	# Первый T-триггер срабатывает на rising edge, второй - на falling edge
	if tff_count == 1:  # Это второй T-триггер
		if gate.has_method("set_edge_type"):
			gate.set_edge_type(true)  # Falling edge
			print(">>> Setting second TFlipFlop to FALLING edge mode")
		else:
			print(">>> ERROR: TFlipFlop doesn't have set_edge_type method!")
	else:
		print(">>> Setting TFlipFlop to RISING edge mode (default)")
	
	add_child(gate)
	movable_objects.append(gate)
	update_all_logic_objects()
	mark_level_state_dirty()
	
	print("T-FlipFlop gate added at position: ", gate.position, ". Total TFFs now: ", tff_count + 1)

func _setup_top_panel_buttons():
	var menu_button = $TopPanel/HBoxContainer/MenuButton
	var hint_button = $TopPanel/HBoxContainer/TheoryButton
	var map_button = $TopPanel/HBoxContainer/MapButton
	var run_button = $TopPanel/HBoxContainer/RunButton
	
	menu_button.connect("pressed", _on_menu_button_pressed)
	map_button.connect("pressed", _on_map_button_pressed)
	run_button.connect("pressed", _on_test_pressed)

	var gate_buttons_container = $TopPanel/MainContainer/RightSection/GateButtonsContainer

	for child in gate_buttons_container.get_children():
		child.hide()

	for gate_type in level_data.available_gates:
		var button = gate_buttons_container.get_node_or_null(gate_type)
		if button:
			button.show()

			match gate_type:
				"NOT":
					button.connect("pressed", _on_add_not_button_pressed)
				"AND":
					button.connect("pressed", _on_add_and_button_pressed)
				"OR":
					button.connect("pressed", _on_add_or_button_pressed)
				"XOR":
					button.connect("pressed", _on_add_xor_button_pressed)
				"NOR":
					button.connect("pressed", _on_add_nor_button_pressed)
				"NAND":
					button.connect("pressed", _on_add_nand_button_pressed)
				"XNOR":
					button.connect("pressed", _on_add_nxor_button_pressed)
				"Implication":
					button.connect("pressed", _on_add_implication_button_pressed)
				"SEL0":
					button.connect("pressed", _on_add_sel0_button_pressed)
				"SEL1":
					button.connect("pressed", _on_add_sel1_button_pressed)
				"HalfAdder":
					button.connect("pressed", _on_add_half_adder_button_pressed)
				"FullAdder":
					button.connect("pressed", _on_add_full_adder_button_pressed)
				"Cout0":
					button.connect("pressed", _on_add_cout0_button_pressed)
				"MUX4to1":
					button.connect("pressed", _on_add_mux4to1_button_pressed)
				"OpCode":
					button.connect("pressed", _on_add_opcode_button_pressed)
				"OneBitComparator": 
					button.connect("pressed", _on_add_onebit_comparator_button_pressed)
				"TFlipFlop":
					button.connect("pressed", _on_add_tflipflop_button_pressed)
					
	print("LevelBitCounter: Buttons setup completed for gates: ", level_data.available_gates)

# Empty methods from base class that we need to define
func _on_add_not_button_pressed(): pass
func _on_add_and_button_pressed(): pass
func _on_add_or_button_pressed(): pass
func _on_add_xor_button_pressed(): pass
func _on_add_nor_button_pressed(): pass
func _on_add_nand_button_pressed(): pass
func _on_add_nxor_button_pressed(): pass
func _on_add_implication_button_pressed(): pass
func _on_add_sel0_button_pressed(): pass
func _on_add_sel1_button_pressed(): pass
func _on_add_half_adder_button_pressed(): pass
func _on_add_full_adder_button_pressed(): pass
func _on_add_cout0_button_pressed(): pass
func _on_add_mux4to1_button_pressed(): pass
func _on_add_opcode_button_pressed(): pass
func _on_add_onebit_comparator_button_pressed(): pass
