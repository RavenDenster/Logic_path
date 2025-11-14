# LevelDecoder8.gd
extends "res://scripts/levels/LevelBase.gd"

var input_block_a
var input_block_b
var input_block_c
var output_blocks = []

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

	setup_decoder8_level()
	
	temp_line = Line2D.new()
	add_child(temp_line)
	temp_line.default_color = Color("#e39e45")
	temp_line.width = 8
	temp_line.points = []
	
	_setup_top_panel_buttons()
	
	await get_tree().process_frame

	if test_results_panel and test_results_panel.has_method("load_initial_data"):
		test_results_panel.load_initial_data(
			level_data.input_values_a,
			level_data.input_values_b,
			level_data.input_values_c,
			level_data.expected_y0,
			level_data.expected_y1,
			level_data.expected_y2,
			level_data.expected_y3,
			level_data.expected_y4,
			level_data.expected_y5,
			level_data.expected_y6,
			level_data.expected_y7
		)

	load_level_state()

	auto_save_timer = Timer.new()
	auto_save_timer.wait_time = 2.0
	auto_save_timer.one_shot = true
	auto_save_timer.timeout.connect(_on_auto_save_timeout)
	add_child(auto_save_timer)
	
	print("3→8 Decoder level ready completed successfully")

func setup_decoder8_level():
	print("Setting up 3→8 Decoder level with three inputs and eight outputs")
	
	movable_objects = []

	input_block_a = get_node_or_null("InputBlockA")
	input_block_b = get_node_or_null("InputBlockB")
	input_block_c = get_node_or_null("InputBlockC")
	
	if input_block_a and input_block_b and input_block_c:
		input_block_a.values = level_data.input_values_a.duplicate()
		input_block_b.values = level_data.input_values_b.duplicate()
		input_block_c.values = level_data.input_values_c.duplicate()
		movable_objects.append(input_block_a)
		movable_objects.append(input_block_b)
		movable_objects.append(input_block_c)
		print("3→8 Decoder input blocks initialized")
	else:
		push_error("Input blocks not found in 3→8 Decoder level!")

	for i in range(8):
		var output_block = get_node_or_null("OutputBlockY" + str(i))
		if output_block:
			var expected_array_name = "expected_y" + str(i)
			if level_data.has_method("get") or level_data.has(expected_array_name):
				output_block.expected = level_data.get(expected_array_name).duplicate()
			output_blocks.append(output_block)
			movable_objects.append(output_block)
	
	print("3→8 Decoder output blocks initialized: ", output_blocks.size())

	test_results_panel = get_node_or_null("TestResultsPanelDecoder8")
	if test_results_panel:
		print("3→8 Decoder test panel found")

	update_all_logic_objects()
	print("Movable objects: ", movable_objects.size())
	print("All logic objects: ", all_logic_objects.size())

func _on_test_pressed():
	print("=== Testing 3→8 Decoder level ===")
	reset_all_port_sprites()

	for output in output_blocks:
		if output:
			output.set_default_style()
	
	var player_outputs = [[], [], [], [], [], [], [], []]
	
	for i in range(8):
		print("--- Test case ", i, " ---")
		input_block_a.current_test_index = i
		input_block_b.current_test_index = i
		input_block_c.current_test_index = i
		print("Inputs: A=", input_block_a.values[i], " B=", input_block_b.values[i], " C=", input_block_c.values[i])

		for obj in all_logic_objects:
			if obj and obj.has_method("reset_inputs"):
				obj.reset_inputs()

		for output in output_blocks:
			if output:
				output.received_value = 0
			
		propagate_signals()
		
		for j in range(8):
			if j < output_blocks.size() and output_blocks[j]:
				player_outputs[j].append(int(output_blocks[j].received_value))
				print("Y", j, " output: ", output_blocks[j].received_value)
			else:
				player_outputs[j].append(0)
	
	print("=== Test results ===")
	for i in range(8):
		print("Player Y", i, ": ", player_outputs[i])
		print("Expected Y", i, ": ", level_data.get("expected_y" + str(i)))

	if test_results_panel and test_results_panel.has_method("update_current_outputs"):
		test_results_panel.update_current_outputs(
			player_outputs[0], player_outputs[1], player_outputs[2], player_outputs[3],
			player_outputs[4], player_outputs[5], player_outputs[6], player_outputs[7]
		)
		print("Test panel updated")

	var all_correct = true
	for i in range(8):
		var expected = level_data.get("expected_y" + str(i))
		all_correct = all_correct and (player_outputs[i] == expected)
	
	print("All outputs correct: ", all_correct)
	
	if all_correct:
		for output in output_blocks:
			if output:
				output.set_correct_style()
		if not level_completed_this_session:
			save_level_progress()
			level_completed_this_session = true
		print("Level completed successfully!")
	else:
		for output in output_blocks:
			if output:
				output.set_default_style()
		level_completed_this_session = false
		print("Level not completed - outputs don't match")
	
	update_all_port_colors()

func propagate_signals():
	print("=== Starting signal propagation for 3→8 Decoder ===")

	for obj in all_logic_objects:
		if obj and obj.has_method("reset_inputs"):
			obj.reset_inputs()

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

	for current in processed_order:
		if not current or not is_instance_valid(current):
			continue
			
		if current in [input_block_a, input_block_b, input_block_c]:
			var output_value = int(current.get_output("Output"))
			
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
						elif end_port_name == "Input3":
							port_num = 3
						elif end_port_name == "InputPort":
							port_num = 1
						elif end_port_name == "Input":
							port_num = 1
						
						end_gate.set_input(port_num, output_value)

		elif current.has_method("get_output") and current not in output_blocks:
			var output_value = int(current.get_output("Output"))
			
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
						elif end_port_name == "Input3":
							port_num = 3
						elif end_port_name == "InputPort":
							port_num = 1
						elif end_port_name == "Input":
							port_num = 1
						
						end_gate.set_input(port_num, output_value)
	
	print("=== Signal propagation complete ===")

func get_gates_data():
	var gates_data = []

	if input_block_a:
		var input_block_a_data = {
			"type": "INPUT_BLOCK_A",
			"position": [input_block_a.position.x, input_block_a.position.y]
		}
		gates_data.append(input_block_a_data)
	
	if input_block_b:
		var input_block_b_data = {
			"type": "INPUT_BLOCK_B",
			"position": [input_block_b.position.x, input_block_b.position.y]
		}
		gates_data.append(input_block_b_data)

	if input_block_c:
		var input_block_c_data = {
			"type": "INPUT_BLOCK_C",
			"position": [input_block_c.position.x, input_block_c.position.y]
		}
		gates_data.append(input_block_c_data)
	
	for i in range(output_blocks.size()):
		var output_block = output_blocks[i]
		if output_block:
			var output_block_data = {
				"type": "OUTPUT_BLOCK_Y" + str(i),
				"position": [output_block.position.x, output_block.position.y]
			}
			gates_data.append(output_block_data)

	for obj in movable_objects:
		var skip = false

		if obj == input_block_a or obj == input_block_b or obj == input_block_c:
			skip = true
		if obj in output_blocks:
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
		if obj == input_block_a or obj == input_block_b or obj == input_block_c:
			skip = true
		if obj in output_blocks:
			skip = true

		if skip:
			continue
			
		if is_instance_valid(obj):
			obj.queue_free()
		movable_objects.remove_at(i)
	
	update_all_logic_objects()
	reset_all_port_sprites()
	
	print("3→8 Decoder level cleared - kept Input/Output blocks, removed gates and wires")
	
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
	elif gate_type == "INPUT_BLOCK_C" and input_block_c:
		input_block_c.position = position
		print("Restored InputBlockC position: ", position)
		return
	elif gate_type.begins_with("OUTPUT_BLOCK_Y") and output_blocks:
		var index_str = gate_type.replace("OUTPUT_BLOCK_Y", "")
		var index = index_str.to_int()
		if index >= 0 and index < output_blocks.size() and output_blocks[index]:
			output_blocks[index].position = position
			print("Restored OutputBlockY", index, " position: ", position)
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
	
	if parent_name == "InputBlockA" and input_block_a:
		parent = input_block_a
	elif parent_name == "InputBlockB" and input_block_b:
		parent = input_block_b
	elif parent_name == "InputBlockC" and input_block_c:
		parent = input_block_c
	elif parent_name.begins_with("OutputBlockY") and output_blocks:
		var index_str = parent_name.replace("OutputBlockY", "")
		var index = index_str.to_int()
		if index >= 0 and index < output_blocks.size() and output_blocks[index]:
			parent = output_blocks[index]

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

	if obj == input_block_a:
		return "INPUT_BLOCK_A"
	elif obj == input_block_b:
		return "INPUT_BLOCK_B"
	elif obj == input_block_c:
		return "INPUT_BLOCK_C"
	elif obj in output_blocks:
		var index = output_blocks.find(obj)
		if index != -1:
			return "OUTPUT_BLOCK_Y" + str(index)
	
	return "UNKNOWN"

func find_port_near_position(position, max_distance = 50.0):
	var closest_port = null
	var closest_distance = max_distance
	
	for obj in movable_objects:
		if not obj or not is_instance_valid(obj):
			continue
			
		var ports = []

		if obj == input_block_a or obj == input_block_b or obj == input_block_c:
			var output = obj.get_node_or_null("Output")
			if output: ports.append(output)
		elif obj in output_blocks:
			var input_port = obj.get_node_or_null("InputPort")
			if input_port: ports.append(input_port)
		else:
			var input1 = obj.get_node_or_null("Input1")
			var input2 = obj.get_node_or_null("Input2")
			var input3 = obj.get_node_or_null("Input3")
			var input_port = obj.get_node_or_null("InputPort")
			var output = obj.get_node_or_null("Output")
			
			if input1: ports.append(input1)
			if input2: ports.append(input2)
			if input3: ports.append(input3)
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
	if input_block_a:
		var output_port = input_block_a.get_node_or_null("Output")
		if output_port and is_instance_valid(output_port):
			var sprite = output_port.get_node_or_null("Sprite2D")
			if sprite and is_instance_valid(sprite):
				sprite.texture = preload("res://assets/point.png")

	if input_block_b:
		var output_port = input_block_b.get_node_or_null("Output")
		if output_port and is_instance_valid(output_port):
			var sprite = output_port.get_node_or_null("Sprite2D")
			if sprite and is_instance_valid(sprite):
				sprite.texture = preload("res://assets/point.png")

	if input_block_c:
		var output_port = input_block_c.get_node_or_null("Output")
		if output_port and is_instance_valid(output_port):
			var sprite = output_port.get_node_or_null("Sprite2D")
			if sprite and is_instance_valid(sprite):
				sprite.texture = preload("res://assets/point.png")

	for output in output_blocks:
		if output:
			var input_port = output.get_node_or_null("InputPort")
			if input_port and is_instance_valid(input_port):
				var sprite = input_port.get_node_or_null("Sprite2D")
				if sprite and is_instance_valid(sprite):
					sprite.texture = preload("res://assets/point.png")

	for obj in movable_objects:
		if not obj or not is_instance_valid(obj):
			continue

		if obj == input_block_a or obj == input_block_b or obj == input_block_c:
			continue
		if obj in output_blocks:
			continue

		var ports = []
		var possible_port_names = ["Input1", "Input2", "Input3", "InputPort", "Output"]
		
		for port_name in possible_port_names:
			var port = obj.get_node_or_null(port_name)
			if port and is_instance_valid(port):
				ports.append(port)

		for port in ports:
			var sprite = port.get_node_or_null("Sprite2D")
			if sprite and is_instance_valid(sprite):
				sprite.texture = preload("res://assets/point.png")
	
	print("3→8 Decoder level: Reset all port sprites")

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

			if obj == input_block_a or obj == input_block_b or obj == input_block_c:
				skip = true
			if obj in output_blocks:
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
