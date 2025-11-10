extends "res://scripts/levels/LevelBase.gd"

var input_block_ab
var output_block
var opcode_block = null

func _ready():
	level_data = preload("res://data/level_18_data.tres")
	if not level_data:
		push_error("LevelALU: level_data is null!")
		return
	print("LevelALU data loaded:")
	print(" Input A: ", level_data.input_values_a)
	print(" Input B: ", level_data.input_values_b)
	print(" Input Op0: ", level_data.input_values_op0)
	print(" Input Op1: ", level_data.input_values_op1)
	print(" Expected Result: ", level_data.expected_result)
	wires = []
	movable_objects = []
	all_logic_objects = []
	if has_node("TopPanel") and $TopPanel.has_method("set_level_name"):
		$TopPanel.set_level_name(level_data.level_name)
		$TopPanel.set_theory_text(level_data.theory_text)
	temp_line = Line2D.new()
	add_child(temp_line)
	temp_line.default_color = Color("#e39e45")
	temp_line.width = 8
	temp_line.points = []
	_setup_top_panel_buttons()
	await get_tree().process_frame
	setup_alu_level()
	if test_results_panel and test_results_panel.has_method("load_initial_data"):
		test_results_panel.load_initial_data(
			level_data.input_values_a,
			level_data.input_values_b,
			level_data.input_values_op0,
			level_data.input_values_op1,
			level_data.expected_result
		)
	load_level_state()
	auto_save_timer = Timer.new()
	auto_save_timer.wait_time = 2.0
	auto_save_timer.one_shot = true
	auto_save_timer.timeout.connect(_on_auto_save_timeout)
	add_child(auto_save_timer)
	print("ALU level ready completed successfully")

func setup_alu_level():
	print("Setting up ALU level with AB inputs, dynamic OpCode input, and one output")
	movable_objects = []
	input_block_ab = get_node_or_null("InputBlockAB")
	if input_block_ab:
		input_block_ab.values_A = level_data.input_values_a.duplicate()
		input_block_ab.values_B = level_data.input_values_b.duplicate()
		movable_objects.append(input_block_ab)
		print("ALU input block AB initialized")
	else:
		push_error("InputBlockAB not found in ALU level!")
	output_block = get_node_or_null("OutputBlock")
	if output_block:
		output_block.expected = level_data.expected_result.duplicate()
		movable_objects.append(output_block)
		print("ALU output block initialized")
	else:
		push_error("Output block not found in ALU level!")
	test_results_panel = get_node_or_null("TestResultsPanelAlu")
	if test_results_panel:
		print("ALU test panel found")
	update_all_logic_objects()
	print("Movable objects: ", movable_objects.size())
	print("All logic objects: ", all_logic_objects.size())

func find_opcode_block():
	var opcode_blocks = get_tree().get_nodes_in_group("OpCodeBlocks")
	if opcode_blocks.size() > 0:
		print("Found OpCodeBlock via group: ", opcode_blocks[0])
		return opcode_blocks[0]
	
	for obj in movable_objects:
		if obj is OpCodeBlock:
			print("Found OpCodeBlock via class check")
			return obj
	
	for obj in movable_objects:
		if obj and ("OpCode" in obj.name or "opcode" in obj.name.to_lower()):
			print("Found OpCodeBlock by name: ", obj.name)
			return obj
	
	print("OpCodeBlock not found")
	return null

func _on_test_pressed():
	print("=== Testing ALU level ===")
	reset_all_port_sprites()
	if output_block:
		output_block.set_default_style()
	
	opcode_block = find_opcode_block()
	if opcode_block:
		print("OpCodeBlock found, setting values")
		opcode_block.values_op0 = level_data.input_values_op0.duplicate()
		opcode_block.values_op1 = level_data.input_values_op1.duplicate()
	else:
		print("WARNING: OpCodeBlock not found! Add it via the top panel button.")
	
	var player_outputs = []
	
	for i in range(12):
		print("--- Test case ", i, " ---")
		input_block_ab.current_test_index = i
		if opcode_block:
			opcode_block.current_test_index = i
			print("Inputs: A=", input_block_ab.values_A[i], " B=", input_block_ab.values_B[i], 
				  " Op0=", opcode_block.values_op0[i], " Op1=", opcode_block.values_op1[i])
		else:
			print("Inputs: A=", input_block_ab.values_A[i], " B=", input_block_ab.values_B[i], 
				  " Op0=0 (missing), Op1=0 (missing)")

		for obj in all_logic_objects:
			if obj and obj.has_method("reset_inputs"):
				obj.reset_inputs()

		if output_block:
			output_block.received_value = 0
			
		propagate_signals()
		
		if output_block:
			player_outputs.append(int(output_block.received_value))
			print("Result output: ", output_block.received_value)
		else:
			player_outputs.append(0)
	
	print("=== Test results ===")
	print("Player Result: ", player_outputs)
	print("Expected Result: ", level_data.expected_result)

	if test_results_panel and test_results_panel.has_method("update_current_outputs"):
		test_results_panel.update_current_outputs(player_outputs)
		print("Test panel updated")

	var correct = player_outputs == level_data.expected_result
	
	print("Result correct: ", correct)
	
	if correct:
		if output_block:
			output_block.set_correct_style()
		if not level_completed_this_session:
			save_level_progress()
			level_completed_this_session = true
		print("Level completed successfully!")
	else:
		if output_block:
			output_block.set_default_style()
		level_completed_this_session = false
		print("Level not completed - outputs don't match")
	
	update_all_port_colors()

func is_wire_valid(wire):
	return (wire and is_instance_valid(wire) and 
			wire.start_port and is_instance_valid(wire.start_port) and
			wire.end_port and is_instance_valid(wire.end_port))

func propagate_signals():
	opcode_block = find_opcode_block()
	
	for obj in all_logic_objects:
		if obj and obj.has_method("reset_inputs"):
			obj.reset_inputs()

	if input_block_ab:
		var a_value = int(input_block_ab.get_output("OutputA"))
		var b_value = int(input_block_ab.get_output("OutputB"))
		print("   A = ", a_value, " B = ", b_value)
		
		for wire in wires:
			if not is_wire_valid(wire): continue
			
			if wire.start_port.get_parent() == input_block_ab:
				var end_gate = wire.end_port.get_parent()
				if end_gate and end_gate.has_method("set_input"):
					var gate_type = get_object_type(end_gate)
					var port_num = get_gate_port_number(wire.end_port.name, gate_type)
					var value = a_value if wire.start_port.name == "OutputA" else b_value
					var operation = "A" if wire.start_port.name == "OutputA" else "B"
					end_gate.set_input(port_num, value)

	if opcode_block:
		var op0_value = int(opcode_block.get_output("Op0"))
		var op1_value = int(opcode_block.get_output("Op1"))
		
		for wire in wires:
			if not is_wire_valid(wire): continue
			
			if wire.start_port.get_parent() == opcode_block:
				var end_gate = wire.end_port.get_parent()
				if end_gate and end_gate.has_method("set_input"):
					var gate_type = get_object_type(end_gate)
					var port_num = get_gate_port_number(wire.end_port.name, gate_type)
					var value = op0_value if wire.start_port.name == "Op0" else op1_value
					var op_name = "Op0" if wire.start_port.name == "Op0" else "Op1"
					end_gate.set_input(port_num, value)

	for obj in all_logic_objects:
		if not obj or obj == input_block_ab or obj == opcode_block or obj == output_block:
			continue
			
		if obj.has_method("get_output"):
			var output_value = int(obj.get_output("Output"))
			print("   ", obj.name, " output = ", output_value)
			
			for wire in wires:
				if not is_wire_valid(wire): continue
				
				if wire.start_port.get_parent() == obj:
					var end_gate = wire.end_port.get_parent()
					if end_gate and end_gate.has_method("set_input"):
						var gate_type = get_object_type(end_gate)
						var port_num = get_gate_port_number(wire.end_port.name, gate_type)
						end_gate.set_input(port_num, output_value)

	
func get_operation_name(op1: int, op0: int) -> String:
	match [op1, op0]:
		[0, 0]: return "AND (Input0)"
		[0, 1]: return "OR (Input1)"
		[1, 0]: return "XOR (Input2)"
		[1, 1]: return "NOT USED (Input3)"
		_: return "UNKNOWN"

func get_gate_port_number(port_name: String, gate_type: String) -> int:

	if gate_type == "MUX4to1":
		match port_name:
			"Input0": return 1
			"Input1": return 2
			"Input2": return 3
			"Input3": return 4
			"Sel0": return 5
			"Sel1": return 6
			_: return 1
	
	if gate_type in ["AND", "OR", "XOR"]:
		match port_name:
			"Input1": return 1
			"Input2": return 2
			"Output": return 1
			_: return 1

	if gate_type == "OpCode":
		match port_name:
			"Op0": return 5  
			"Op1": return 6 
			_: return 1

	return 1

func get_gates_data():
	var gates_data = []
	if input_block_ab:
		gates_data.append({"type": "INPUT_BLOCK_AB", "position": [input_block_ab.position.x, input_block_ab.position.y]})
	if output_block:
		gates_data.append({"type": "OUTPUT_BLOCK", "position": [output_block.position.x, output_block.position.y]})
	for obj in movable_objects:
		var skip = obj == input_block_ab or obj == output_block
		if skip:
			continue
		var gate_type = get_object_type(obj)
		gates_data.append({"type": gate_type, "position": [obj.position.x, obj.position.y]})
	return gates_data

func clear_level():
	for wire in wires:
		if is_instance_valid(wire):
			wire.queue_free()
	wires.clear()
	for i in range(movable_objects.size() - 1, -1, -1):
		var obj = movable_objects[i]
		var skip = obj == input_block_ab or obj == output_block
		if skip:
			continue
		if is_instance_valid(obj):
			obj.queue_free()
		movable_objects.remove_at(i)
	update_all_logic_objects()
	reset_all_port_sprites()
	print("ALU level cleared - kept Input/Output blocks, removed gates and wires (including OpCodeBlock)")

func create_gate_from_data(gate_data):
	var gate_type = gate_data.get("type", "")
	var position = Vector2(gate_data.get("position", [0, 0])[0], gate_data.get("position", [0, 0])[1])
	if gate_type == "INPUT_BLOCK_AB" and input_block_ab:
		input_block_ab.position = position
		return
	elif gate_type == "OUTPUT_BLOCK" and output_block:
		output_block.position = position
		return
	var gate_scene = null
	match gate_type:
		"AND": gate_scene = preload("res://scenes/gates/ANDGate.tscn")
		"OR": gate_scene = preload("res://scenes/gates/ORGate.tscn")
		"XOR": gate_scene = preload("res://scenes/gates/XORGate.tscn")
		"MUX4to1": gate_scene = preload("res://scenes/gates/MUX4to1.tscn")
		"OpCode": gate_scene = preload("res://scenes/gates/OpCodeBlock.tscn")
	if gate_scene:
		var gate = gate_scene.instantiate()
		gate.position = position
		add_child(gate)
		movable_objects.append(gate)
		print("Restored gate: ", gate_type, " at ", position)
		
		if gate.has_method("reset_inputs"):
			gate.reset_inputs()

func find_port_by_name(parent_name, port_name):
	var parent = null
	if parent_name == "InputBlockAB" and input_block_ab:
		parent = input_block_ab
	elif parent_name == "OutputBlock" and output_block:
		parent = output_block
	if not parent:
		for obj in movable_objects:
			if obj and obj.name == parent_name:
				parent = obj
				break
	if not parent:
		return null
	var port = parent.get_node_or_null(str(port_name))
	return port

func get_object_type(obj):
	if obj == null:
		return "UNKNOWN"
	
	if obj is OpCodeBlock:
		return "OpCode"
	
	var scene_file = obj.scene_file_path
	if scene_file == "res://scenes/gates/ANDGate.tscn": 
		return "AND"
	elif scene_file == "res://scenes/gates/ORGate.tscn": 
		return "OR"
	elif scene_file == "res://scenes/gates/XORGate.tscn": 
		return "XOR"
	elif scene_file == "res://scenes/gates/MUX4to1.tscn": 
		return "MUX4to1"
	elif scene_file == "res://scenes/gates/OpCodeBlock.tscn": 
		return "OpCode"
	
	if "AND" in obj.name: return "AND"
	elif "OR" in obj.name: return "OR"  
	elif "XOR" in obj.name: return "XOR"
	elif "MUX" in obj.name: return "MUX4to1"
	elif "OpCode" in obj.name: return "OpCode"
	
	if obj == input_block_ab: 
		return "INPUT_BLOCK_AB"
	elif obj == output_block: 
		return "OUTPUT_BLOCK"
	
	return "UNKNOWN"

func find_port_near_position(position, max_distance = 50.0):
	var closest_port = null
	var closest_distance = max_distance
	
	for obj in movable_objects:
		if not obj or not is_instance_valid(obj):
			continue
			
		var ports = []
		
		if obj == input_block_ab:
			ports.append(obj.get_node_or_null("OutputA"))
			ports.append(obj.get_node_or_null("OutputB"))
		elif obj == output_block:
			ports.append(obj.get_node_or_null("InputPort"))
		elif "OpCode" in obj.name or obj is OpCodeBlock:
			ports.append(obj.get_node_or_null("Op0"))
			ports.append(obj.get_node_or_null("Op1"))
		elif "MUX" in obj.name:
			ports.append(obj.get_node_or_null("Input0"))
			ports.append(obj.get_node_or_null("Input1"))
			ports.append(obj.get_node_or_null("Input2"))
			ports.append(obj.get_node_or_null("Input3"))
			ports.append(obj.get_node_or_null("Sel0"))
			ports.append(obj.get_node_or_null("Sel1"))
			ports.append(obj.get_node_or_null("Output"))
		else:
			ports.append(obj.get_node_or_null("Input1"))
			ports.append(obj.get_node_or_null("Input2"))
			ports.append(obj.get_node_or_null("Output"))
		
		for port in ports:
			if port and is_instance_valid(port):
				var port_pos = port.global_position
				var distance = port_pos.distance_to(position)
				if distance < closest_distance:
					closest_distance = distance
					closest_port = port
	
	return closest_port

func reset_all_port_sprites():
	if input_block_ab:
		for port_name in ["OutputA", "OutputB"]:
			var port = input_block_ab.get_node_or_null(port_name)
			if port:
				var sprite = port.get_node_or_null("Sprite2D")
				if sprite:
					sprite.texture = preload("res://assets/point.png")
	if output_block:
		var port = output_block.get_node_or_null("InputPort")
		if port:
			var sprite = port.get_node_or_null("Sprite2D")
			if sprite:
				sprite.texture = preload("res://assets/point.png")
	for obj in movable_objects:
		if not obj or not is_instance_valid(obj):
			continue
		if obj == input_block_ab or obj == output_block:
			continue
		var ports = []
		var port_names = ["Input0", "Input1", "Input2", "Input3", "Sel0", "Sel1", "Output", "Input1", "Input2", "Output", "Op0", "Op1"]
		for name in port_names:
			var port = obj.get_node_or_null(name)
			if port: ports.append(port)
		for port in ports:
			var sprite = port.get_node_or_null("Sprite2D")
			if sprite:
				sprite.texture = preload("res://assets/point.png")
	print("ALU level: Reset all port sprites")

func _on_add_and_button_pressed():
	var gate = preload("res://scenes/gates/ANDGate.tscn").instantiate()
	gate.position = Vector2(600, 400)
	add_child(gate)
	movable_objects.append(gate)
	update_all_logic_objects()
	mark_level_state_dirty()

func _on_add_or_button_pressed():
	var gate = preload("res://scenes/gates/ORGate.tscn").instantiate()
	gate.position = Vector2(600, 500)
	add_child(gate)
	movable_objects.append(gate)
	update_all_logic_objects()
	mark_level_state_dirty()

func _on_add_xor_button_pressed():
	var gate = preload("res://scenes/gates/XORGate.tscn").instantiate()
	gate.position = Vector2(600, 600)
	add_child(gate)
	movable_objects.append(gate)
	update_all_logic_objects()
	mark_level_state_dirty()

func _on_add_mux4to1_button_pressed():
	var gate = preload("res://scenes/gates/MUX4to1.tscn").instantiate()
	gate.position = Vector2(600, 700)
	add_child(gate)
	movable_objects.append(gate)
	update_all_logic_objects()
	mark_level_state_dirty()

func _on_add_opcode_button_pressed():
	var gate = preload("res://scenes/gates/OpCodeBlock.tscn").instantiate()
	gate.position = Vector2(600, 800)
	add_child(gate)
	movable_objects.append(gate)
	update_all_logic_objects()
	mark_level_state_dirty()

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
			var skip = obj == input_block_ab or obj == output_block
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
