
extends "res://scripts/levels/LevelBase.gd"

func setup_three_input_level():
	print("Setting up three-input level")

	if has_node("InputBlock"):
		$InputBlock.hide()

	input_blocks = []

	var input_block_a = get_node_or_null("InputBlockA")
	var input_block_b = get_node_or_null("InputBlockB") 
	var input_block_c = get_node_or_null("InputBlockC")

	if input_block_a and input_block_b and input_block_c:
		print("Using existing InputBlocks")
		input_blocks = [input_block_a, input_block_b, input_block_c]

		if input_block_a.values.is_empty():
			input_block_a.values = level_data.input_values_a.duplicate()
			print("Set values for InputBlockA")
		if input_block_b.values.is_empty():
			input_block_b.values = level_data.input_values_b.duplicate()
			print("Set values for InputBlockB")
		if input_block_c.values.is_empty():
			input_block_c.values = level_data.input_values_c.duplicate()
			print("Set values for InputBlockC")
	else:
		print("Creating InputBlocks programmatically")
		var input_block_scene = preload("res://scenes/components/SingleInputBlock.tscn")

		input_block_a = input_block_scene.instantiate()
		input_block_a.name = "InputBlockA"
		input_block_a.position = Vector2(200, 300)
		input_block_a.values = level_data.input_values_a.duplicate()
		add_child(input_block_a)
 
		input_block_b = input_block_scene.instantiate()
		input_block_b.name = "InputBlockB"
		input_block_b.position = Vector2(200, 500)
		input_block_b.values = level_data.input_values_b.duplicate()
		add_child(input_block_b)

		input_block_c = input_block_scene.instantiate()
		input_block_c.name = "InputBlockC"
		input_block_c.position = Vector2(200, 700)
		input_block_c.values = level_data.input_values_c.duplicate()
		add_child(input_block_c)
		
		input_blocks = [input_block_a, input_block_b, input_block_c]

	for input_block in input_blocks:
		if not input_block in movable_objects:
			movable_objects.append(input_block)
			print("Added to movable_objects: ", input_block.name)
	
	if not $OutputBlock in movable_objects:
		movable_objects.append($OutputBlock)
		print("Added OutputBlock to movable_objects")

	test_results_panel = get_node_or_null("TestResultsPanel3Inputs")
	
	if not test_results_panel:
		print("Creating TestResultsPanel3Inputs programmatically")
		var new_panel_scene = preload("res://scenes/ui/TestResultsPanel3Inputs.tscn")
		if ResourceLoader.exists(new_panel_scene.resource_path):
			var new_panel = new_panel_scene.instantiate()

			new_panel.position = Vector2(1200, 200)
			add_child(new_panel)

			test_results_panel = new_panel
			print("Created TestResultsPanel3Inputs")
		else:
			push_error("TestResultsPanel3Inputs scene not found")
	else:
		print("Using existing TestResultsPanel3Inputs")
	
	print("Three-input level setup completed with ", input_blocks.size(), " input blocks")

func propagate_signals_three_inputs():
	for obj in all_logic_objects:
		if obj.has_method("reset_inputs") and not (obj in input_blocks):
			obj.reset_inputs()
	
	print("=== Starting signal propagation for three inputs ===")

	var dependencies = {}
	var dependents = {}
	
	for obj in all_logic_objects:
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
		
		if start_gate != end_gate:
			if not dependencies[end_gate].has(start_gate):
				dependencies[end_gate].append(start_gate)
			if not dependents[start_gate].has(end_gate):
				dependents[start_gate].append(end_gate)

	var queue = []
	var in_degree = {}
	
	for obj in all_logic_objects:
		in_degree[obj] = dependencies[obj].size()
		if in_degree[obj] == 0:
			queue.append(obj)
	
	var processed_order = []
	
	while queue.size() > 0:
		var current = queue.pop_front()
		processed_order.append(current)
		
		for dependent in dependents[current]:
			in_degree[dependent] -= 1
			if in_degree[dependent] == 0:
				queue.append(dependent)
	
	print("Processing order for three inputs: ", processed_order)

	for current in processed_order:
		if not current or not is_instance_valid(current):
			continue
			
		print("Processing: ", current.name)

		if current in input_blocks and current.has_method("get_output"):
			var output_value = int(current.get_output("Output"))
			print(current.name, " output value: ", output_value)

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
						if end_port_name == "Input2":
							port_num = 2
						elif end_port_name == "InputPort":
							port_num = 1
						elif end_port_name == "Input":
							port_num = 1
						
						print("Setting input for ", end_gate.name, " port ", port_num, " to ", output_value)
						end_gate.set_input(port_num, output_value)

		elif current.has_method("get_output") and current != $OutputBlock:
			var output_value = int(current.get_output("Output"))
			print(current.name, " output value: ", output_value)

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
						if end_port_name == "Input2":
							port_num = 2
						elif end_port_name == "InputPort":
							port_num = 1
						elif end_port_name == "Input":
							port_num = 1
						
						print("Setting input for ", end_gate.name, " port ", port_num, " to ", output_value)
						end_gate.set_input(port_num, output_value)
	
	if has_node("OutputBlock"):
		print("Final OutputBlock value: ", $OutputBlock.received_value)
	print("=== Signal propagation for three inputs complete ===")

func _on_test_pressed():
	reset_all_port_sprites()
	if has_node("OutputBlock"):
		$OutputBlock.set_default_style()
	
	var player_outputs = []

	for i in range(8):
	
		for input_block in input_blocks:
			input_block.current_test_index = i
		
		propagate_signals_three_inputs()
		if has_node("OutputBlock"):
			player_outputs.append(int($OutputBlock.received_value))
	
	print("Test results - Actual: ", player_outputs)

	if test_results_panel and test_results_panel.has_method("update_current_outputs"):
		test_results_panel.update_current_outputs(player_outputs)

	if has_node("OutputBlock"):
		var expected = $OutputBlock.expected
		if player_outputs == expected:
			$OutputBlock.set_correct_style()
			if not level_completed_this_session:
				save_level_progress()
				level_completed_this_session = true
		else:
			$OutputBlock.set_default_style()
			level_completed_this_session = false
	
	update_all_port_colors()

func get_gates_data():
	var gates_data = []

	for input_block in input_blocks:
		if input_block and is_instance_valid(input_block):
			var input_block_data = {
				"type": "INPUT_BLOCK_SINGLE",
				"name": input_block.name,
				"position": [input_block.position.x, input_block.position.y]
			}
			gates_data.append(input_block_data)
	
	if has_node("OutputBlock"):
		var output_block_data = {
			"type": "OUTPUT_BLOCK",
			"position": [$OutputBlock.position.x, $OutputBlock.position.y]
		}
		gates_data.append(output_block_data)

	for obj in movable_objects:
		var skip = false

		if obj in input_blocks:
			skip = true
		if has_node("OutputBlock") and obj == $OutputBlock:
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
		if obj in input_blocks:
			skip = true
		if has_node("OutputBlock") and obj == $OutputBlock:
			skip = true

		if skip:
			continue
			
		if is_instance_valid(obj):
			obj.queue_free()
		movable_objects.remove_at(i)
	
	update_all_logic_objects()
	reset_all_port_sprites()
	
	print("Three-input level cleared - kept Input/Output blocks, removed gates and wires")
	
func create_gate_from_data(gate_data):
	var gate_type = gate_data.get("type", "")
	var position_array = gate_data.get("position", [0, 0])
	var position = Vector2(position_array[0], position_array[1])
	
	if gate_type == "INPUT_BLOCK_SINGLE":
		var block_name = gate_data.get("name", "")
		var found_block = null
		for obj in get_children():
			if obj.name == block_name:
				found_block = obj
				break
		
		if found_block and is_instance_valid(found_block):
			found_block.position = position
			print("Restored InputBlockSingle position: ", block_name, " at ", position)
			if not found_block in input_blocks:
				input_blocks.append(found_block)
			if not found_block in movable_objects:
				movable_objects.append(found_block)
		else:
			print("WARNING: InputBlockSingle not found: ", block_name)
		return
	elif gate_type == "OUTPUT_BLOCK" and has_node("OutputBlock"):
		$OutputBlock.position = position
		print("Restored OutputBlock position: ", position)
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
	
	if gate_scene:
		var gate = gate_scene.instantiate()
		gate.position = position
		add_child(gate)
		movable_objects.append(gate)
		print("Restored gate: ", gate_type, " at ", position)

func find_port_by_name(parent_name, port_name):
	var parent = null
	
	if parent_name == "OutputBlock" and has_node("OutputBlock"):
		parent = $OutputBlock

	for input_block in input_blocks:
		if input_block and input_block.name == parent_name:
			parent = input_block
			break

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

	for i in range(input_blocks.size()):
		if obj == input_blocks[i]:
			return "INPUT_BLOCK_" + str(i)
	
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

	if has_node("OutputBlock") and obj == $OutputBlock:
		return "OUTPUT_BLOCK"
	
	return "UNKNOWN"

func find_port_near_position(position, max_distance = 50.0):
	var closest_port = null
	var closest_distance = max_distance
	
	for obj in movable_objects:
		if not obj or not is_instance_valid(obj):
			continue
			
		var ports = []

		if obj in input_blocks:
			var output = obj.get_node_or_null("Output")
			if output: ports.append(output)

		elif has_node("OutputBlock") and obj == $OutputBlock:
			var input_port = obj.get_node_or_null("InputPort")
			if input_port: ports.append(input_port)

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

	for input_block in input_blocks:
		if input_block and is_instance_valid(input_block):
			var output_port = input_block.get_node_or_null("Output")
			if output_port and is_instance_valid(output_port):
				var sprite = output_port.get_node_or_null("Sprite2D")
				if sprite and is_instance_valid(sprite):
					sprite.texture = preload("res://assets/point.png")

	if has_node("OutputBlock"):
		var output_block = $OutputBlock
		var input_port = output_block.get_node_or_null("InputPort")
		if input_port and is_instance_valid(input_port):
			var sprite = input_port.get_node_or_null("Sprite2D")
			if sprite and is_instance_valid(sprite):
				sprite.texture = preload("res://assets/point.png")

	for obj in movable_objects:
		if not obj or not is_instance_valid(obj):
			continue

		var skip = false
		if obj in input_blocks:
			skip = true
		if has_node("OutputBlock") and obj == $OutputBlock:
			skip = true

		if skip:
			continue

		var ports = []
		var possible_port_names = ["Input1", "Input2", "InputPort", "Output"]
		
		for port_name in possible_port_names:
			var port = obj.get_node_or_null(port_name)
			if port and is_instance_valid(port):
				ports.append(port)

		for port in ports:
			var sprite = port.get_node_or_null("Sprite2D")
			if sprite and is_instance_valid(sprite):
				sprite.texture = preload("res://assets/point.png")
	
	print("Three-input level: Reset all port sprites")

func _ready():
	if not level_data:
		push_error("Level data not set!")
		return
	
	wires = []
	movable_objects = []
	all_logic_objects = []
	input_blocks = []
	test_results_panel = null
	
	is_three_input_level = true
	
	if has_node("TopPanel") and $TopPanel.has_method("set_level_name"):
		$TopPanel.set_level_name(level_data.level_name)
		$TopPanel.set_theory_text(level_data.theory_text)

	if has_node("OutputBlock"):
		$OutputBlock.expected = level_data.expected_output.duplicate()
	
	setup_three_input_level()
	
	temp_line = Line2D.new()
	add_child(temp_line)
	temp_line.default_color = Color("#e39e45")
	temp_line.width = 8
	temp_line.points = []
	
	_setup_top_panel_buttons()
	
	await get_tree().process_frame

	if test_results_panel and test_results_panel.has_method("load_initial_data"):
		test_results_panel.load_initial_data(level_data.input_values_a, level_data.input_values_b, level_data.input_values_c, level_data.expected_output)

	load_level_state()

	auto_save_timer = Timer.new()
	auto_save_timer.wait_time = 2.0
	auto_save_timer.one_shot = true
	auto_save_timer.timeout.connect(_on_auto_save_timeout)
	add_child(auto_save_timer)
	
	print("Three-input level ready completed successfully")

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

			if obj in input_blocks:
				skip = true
			if has_node("OutputBlock") and obj == $OutputBlock:
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
						wire.queue_free()
						wires.remove_at(i)
						mark_level_state_dirty()
						print("Wire removed")
						break
