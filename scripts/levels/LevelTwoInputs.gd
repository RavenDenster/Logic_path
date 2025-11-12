
extends "res://scripts/levels/LevelBase.gd"

func setup_two_input_level():
	print("Setting up two-input level")

	if has_node("InputBlock"):
		$InputBlock.values_A = level_data.input_values_a.duplicate()
		$InputBlock.values_B = level_data.input_values_b.duplicate()

		movable_objects.append($InputBlock)
		movable_objects.append($OutputBlock)

		if has_node("TestResultsPanel"):
			test_results_panel = $TestResultsPanel
			print("Two-input level: TestResultsPanel found")
		else:
			print("WARNING: TestResultsPanel not found in two-input level")
	else:
		push_error("InputBlock not found in two-input level!")

func propagate_signals():
	for obj in all_logic_objects:
		if obj.has_method("reset_inputs"):
			obj.reset_inputs()
	
	print("=== Starting signal propagation ===")
	
	var dependencies = {}
	var dependents = {}
	
	for obj in all_logic_objects:
		dependencies[obj] = []
		dependents[obj] = []
	
	for wire in wires:
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
	
	print("Processing order: ", processed_order)
	
	for current in processed_order:
		print("Processing: ", current.name)
		
		if current == $InputBlock:
			for port_name in ["OutputA", "OutputB"]:
				var port = current.get_node_or_null(port_name)
				if port:
					for wire in wires:
						if wire.start_port == port:
							var end_gate = wire.end_port.get_parent()
							var end_port_name = wire.end_port.name
							var val = int(current.get_output(port_name))
							
							if end_gate.has_method("set_input"):
								var port_num = 1
								if end_port_name == "Input2":
									port_num = 2
								elif end_port_name == "InputPort":
									port_num = 1
								elif end_port_name == "Input":
									port_num = 1
								
								print("Setting input for ", end_gate.name, " port ", port_num, " to ", val)
								end_gate.set_input(port_num, val)
		
		elif current.has_method("get_output"):
			var output_value = int(current.get_output("Output"))
			print(current.name, " output value: ", output_value)
			
			for wire in wires:
				if wire.start_port.get_parent() == current:
					var end_gate = wire.end_port.get_parent()
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
	
	print("Final OutputBlock value: ", $OutputBlock.received_value)
	print("=== Signal propagation complete ===")

func _on_test_pressed():
	reset_all_port_sprites()
	if has_node("OutputBlock"):
		$OutputBlock.set_default_style()
	
	var player_outputs = []

	for i in range(4):
		if has_node("InputBlock"):
			$InputBlock.current_test_index = i
		propagate_signals()
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

	if has_node("InputBlock"):
		var input_block_data = {
			"type": "INPUT_BLOCK",
			"position": [$InputBlock.position.x, $InputBlock.position.y]
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

		if has_node("InputBlock") and obj == $InputBlock:
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
		if has_node("InputBlock") and obj == $InputBlock:
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
	
	print("Two-input level cleared - kept Input/Output blocks, removed gates and wires")
	
func create_gate_from_data(gate_data):
	var gate_type = gate_data.get("type", "")
	var position_array = gate_data.get("position", [0, 0])
	var position = Vector2(position_array[0], position_array[1])
	
	if gate_type == "INPUT_BLOCK" and has_node("InputBlock"):
		$InputBlock.position = position
		print("Restored InputBlock position: ", position)
		return
	elif gate_type == "OUTPUT_BLOCK" and has_node("OutputBlock"):
		$OutputBlock.position = position
		print("Restored OutputBlock position: ", position)
		return

	var gate_scene = null
	
	match gate_type:
		"AND":
			gate_scene = preload("res://scenes/gates/ANDGAte.tscn")
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
	elif parent_name == "InputBlock" and has_node("InputBlock"):
		parent = $InputBlock

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

	if has_node("InputBlock") and obj == $InputBlock:
		return "INPUT_BLOCK"
	elif has_node("OutputBlock") and obj == $OutputBlock:
		return "OUTPUT_BLOCK"
	
	return "UNKNOWN"

func find_port_near_position(position, max_distance = 50.0):
	var closest_port = null
	var closest_distance = max_distance
	
	for obj in movable_objects:
		if not obj or not is_instance_valid(obj):
			continue
			
		var ports = []

		if has_node("InputBlock") and obj == $InputBlock and obj.visible:
			ports = [$InputBlock/OutputA, $InputBlock/OutputB]

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

	if has_node("InputBlock"):
		var input_block = $InputBlock
		for port_name in ["OutputA", "OutputB"]:
			var port = input_block.get_node_or_null(port_name)
			if port and is_instance_valid(port):
				var sprite = port.get_node_or_null("Sprite2D")
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
		if has_node("InputBlock") and obj == $InputBlock:
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
	
	print("Two-input level: Reset all port sprites")

func _ready():
	if not level_data:
		push_error("Level data not set!")
		return
	
	wires = []
	movable_objects = []
	all_logic_objects = []
	input_blocks = []
	test_results_panel = null
	
	is_three_input_level = false
	
	if has_node("TopPanel") and $TopPanel.has_method("set_level_name"):
		$TopPanel.set_level_name(level_data.level_name)
		$TopPanel.set_theory_text(level_data.theory_text)

	if has_node("OutputBlock"):
		$OutputBlock.expected = level_data.expected_output.duplicate()
	
	setup_two_input_level()
	
	temp_line = Line2D.new()
	add_child(temp_line)
	temp_line.default_color = Color("#e39e45")
	temp_line.width = 8
	temp_line.points = []
	
	_setup_top_panel_buttons()
	
	await get_tree().process_frame

	if test_results_panel and test_results_panel.has_method("load_initial_data"):
		test_results_panel.load_initial_data(level_data.input_values_a, level_data.input_values_b, level_data.expected_output)

	load_level_state()

	auto_save_timer = Timer.new()
	auto_save_timer.wait_time = 2.0
	auto_save_timer.one_shot = true
	auto_save_timer.timeout.connect(_on_auto_save_timeout)
	add_child(auto_save_timer)
	
	print("Two-input level ready completed successfully")
	
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

			if has_node("InputBlock") and obj == $InputBlock:
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
						remove_wire(wire)
						mark_level_state_dirty()
						print("Wire removed")
						break
