# LevelALU.gd
extends "res://scripts/levels/LevelBase.gd"

var input_block_ab
var output_block
var opcode_block = null

func _ready():
	if not level_data:
		push_error("LevelALU: level_data is null!")
		return
	
	wires = []
	movable_objects = []
	all_logic_objects = []
	
	if has_node("TopPanel") and $TopPanel.has_method("set_level_name"):
		$TopPanel.set_level_name(level_data.level_name)
		$TopPanel.set_theory_text(level_data.theory_text)

	setup_alu_level()
	
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
	
	var level_number = get_level_number()
	if level_number > 0:
		var save_system = get_node_or_null("/root/SaveSystem")
		if save_system and save_system.has_method("record_level_start"):
			save_system.record_level_start(level_number)
		if save_system:
			failed_attempts_count = save_system.get_failed_attempts(level_number)
			hints_enabled = (failed_attempts_count >= 10)
			print("Failed attempts for level ", level_number, ": ", failed_attempts_count, ", hints enabled: ", hints_enabled)
	
	print("ALU level ready completed successfully")

func setup_alu_level():
	print("Setting up ALU level with AB inputs, dynamic OpCode input, and one output")
	movable_objects = []

	input_block_ab = get_node_or_null("InputBlockAB")
	if input_block_ab:
		input_block_ab.values_A = level_data.input_values_a.duplicate()
		input_block_ab.values_B = level_data.input_values_b.duplicate()
		input_block_ab.z_index = 1 
		# Устанавливаем метки для подсветки
		input_block_ab.input_labels = ["Input A", "Input B"]
		
		movable_objects.append(input_block_ab)
		print("ALU input block AB initialized")
	else:
		push_error("InputBlockAB not found in ALU level!")

	output_block = get_node_or_null("OutputBlock")
	if output_block:
		output_block.expected = level_data.expected_result.duplicate()
		output_block.z_index = 1
		# Исправляем тип выхода для подсветки (меняем RESULT на EXPECTED)
		output_block.output_type = "EXPECTED"
		
		movable_objects.append(output_block)
		print("ALU output block initialized")
	else:
		push_error("Output block not found in ALU level!")

	test_results_panel = get_node_or_null("TestResultsPanelAlu")
	if test_results_panel:
		print("ALU test panel found")
		
		# Устанавливаем test_results_panel для всех блоков
		if input_block_ab:
			input_block_ab.test_results_panel = test_results_panel
		if output_block:
			output_block.test_results_panel = test_results_panel

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
	var level_number = get_level_number()
	if level_number > 0:
		var save_system = get_node_or_null("/root/SaveSystem")
		if save_system and save_system.has_method("record_level_attempt"):
			save_system.record_level_attempt(level_number)
	
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
		handle_test_success()
		print("Level completed successfully!")
	else:
		if output_block:
			output_block.set_default_style()
		level_completed_this_session = false
		handle_test_failure() 
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
		gates_data.append({
			"type": "INPUT_BLOCK_AB", 
			"position": [input_block_ab.position.x, input_block_ab.position.y],
			"z_index": input_block_ab.z_index  # Добавьте эту строку
		})
		print("Saving INPUT_BLOCK_AB at ", input_block_ab.position, " z_index: ", input_block_ab.z_index)
	
	if output_block:
		gates_data.append({
			"type": "OUTPUT_BLOCK", 
			"position": [output_block.position.x, output_block.position.y],
			"z_index": output_block.z_index  # И эту
		})
		print("Saving OUTPUT_BLOCK at ", output_block.position, " z_index: ", output_block.z_index)
	
	for obj in movable_objects:
		var skip = obj == input_block_ab or obj == output_block
		if skip:
			continue
			
		var gate_type = get_object_type(obj)
		var gate_data = {
			"type": gate_type,
			"position": [obj.position.x, obj.position.y],
			"z_index": obj.z_index  # И эту
		}
		gates_data.append(gate_data)
		print("Saving gate: ", gate_type, " at ", obj.position, " z_index: ", obj.z_index)
	
	print("Total gates to save: ", gates_data.size())
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
	var z_index = gate_data.get("z_index", 1)  # Добавьте эту строку
	
	if gate_type == "INPUT_BLOCK_AB" and input_block_ab:
		input_block_ab.position = position
		input_block_ab.z_index = z_index  # И эту
		return
	elif gate_type == "OUTPUT_BLOCK" and output_block:
		output_block.position = position
		output_block.z_index = z_index  # И эту
		return
		
	var gate_scene = null
	match gate_type:
		"AND": gate_scene = load("res://scenes/gates/base_logic_el/ANDGate.tscn")
		"OR": gate_scene = load("res://scenes/gates/base_logic_el/ORGate.tscn")
		"XOR": gate_scene = load("res://scenes/gates/base_logic_el/XORGate.tscn")
		"MUX4to1": gate_scene = load("res://scenes/gates/MUX4to1.tscn")
		"OpCode": gate_scene = load("res://scenes/gates/OpCodeBlock.tscn")
		
	if gate_scene:
		var gate = gate_scene.instantiate()
		gate.position = position
		gate.z_index = z_index  # И эту
		add_child(gate)
		movable_objects.append(gate)
		print("Restored gate: ", gate_type, " at ", position, " with z_index ", z_index)
		
		if gate.has_method("reset_inputs"):
			gate.reset_inputs()

func find_port_by_name(parent_name, port_name, parent_type = ""):
	print("Searching for port: ", parent_name, ".", port_name, " (Type: ", parent_type, ")")
	
	var parent = null
	
	# Сначала проверяем основные блоки ALU по точному имени
	if parent_name == "InputBlockAB" and input_block_ab:
		parent = input_block_ab
	elif parent_name == "OutputBlock" and output_block:
		parent = output_block
	
	# Если не нашли по точному имени, ищем среди movable_objects по имени и типу
	if not parent:
		for obj in movable_objects:
			if not obj or not is_instance_valid(obj):
				continue
				
			# Если указан тип, проверяем его
			if parent_type != "" and get_object_type(obj) != parent_type:
				continue
				
			# Сравниваем имена с учетом возможных суффиксов
			if obj.name == parent_name or obj.name.begins_with(parent_name):
				parent = obj
				break
	
	# Если все еще не нашли, попробуем найти по типу (если тип указан)
	if not parent and parent_type != "":
		for obj in movable_objects:
			if get_object_type(obj) == parent_type:
				parent = obj
				break
	
	if not parent:
		print("Parent not found for: ", parent_name, " (Type: ", parent_type, ")")
		return null
	
	# Теперь ищем порт на найденном родителе
	var port = find_port_on_parent(parent, port_name)
	
	if port:
		print("Found port: ", parent.name, ".", port.name)
	else:
		print("Port not found: ", parent_name, ".", port_name, " on ", parent.name)
	
	return port
func find_port_on_parent(parent, port_name):
	if not parent or not is_instance_valid(parent):
		return null
	
	var port = null
	var parent_type = get_object_type(parent)
	
	# Для InputBlockAB
	if parent == input_block_ab:
		match port_name:
			"OutputA": port = parent.get_node_or_null("OutputA")
			"OutputB": port = parent.get_node_or_null("OutputB")
	
	# Для OutputBlock
	elif parent == output_block:
		if port_name == "InputPort":
			port = parent.get_node_or_null("InputPort")
	
	# Для MUX4to1
	elif parent_type == "MUX4to1":
		match port_name:
			"Input0": port = parent.get_node_or_null("Input0")
			"Input1": port = parent.get_node_or_null("Input1")
			"Input2": port = parent.get_node_or_null("Input2")
			"Input3": port = parent.get_node_or_null("Input3")
			"Sel0": port = parent.get_node_or_null("Sel0")
			"Sel1": port = parent.get_node_or_null("Sel1")
			"Output": port = parent.get_node_or_null("Output")
	
	# Для OpCodeBlock
	elif parent_type == "OpCode":
		match port_name:
			"Op0": port = parent.get_node_or_null("Op0")
			"Op1": port = parent.get_node_or_null("Op1")
	
	# Для XOR гейтов (особая обработка)
	elif parent_type == "XOR":
		match port_name:
			"Input1": port = parent.get_node_or_null("Input1")
			"Input2": port = parent.get_node_or_null("Input2")
			"Output": port = parent.get_node_or_null("Output")
	
	# Для обычных гейтов (AND, OR)
	else:
		match port_name:
			"Input1": port = parent.get_node_or_null("Input1")
			"Input2": port = parent.get_node_or_null("Input2")
			"Output": port = parent.get_node_or_null("Output")
	
	return port

func create_wire_from_data(wire_data):
	var start_parent_name = wire_data.get("start_parent_name", "")
	var start_port_name = wire_data.get("start_port_name", "")
	var start_parent_type = wire_data.get("start_parent_type", "")
	var end_parent_name = wire_data.get("end_parent_name", "")
	var end_port_name = wire_data.get("end_port_name", "")
	var end_parent_type = wire_data.get("end_parent_type", "")
	
	print("Attempting to restore wire: ", start_parent_name, ".", start_port_name, " (", start_parent_type, ") -> ", end_parent_name, ".", end_port_name, " (", end_parent_type, ")")

	var start_port = find_port_by_name(start_parent_name, start_port_name, start_parent_type)
	var end_port = find_port_by_name(end_parent_name, end_port_name, end_parent_type)
	
	if start_port and end_port and start_port != end_port:
		var wire = load("res://scenes/components/Wire.tscn").instantiate()
		wire.connect_ports(start_port, end_port)
		wire.z_index = 0
		add_child(wire)
		wires.append(wire)
		print("SUCCESS: Restored wire: ", start_parent_name, ".", start_port_name, " -> ", end_parent_name, ".", end_port_name)
		return true
	else:
		print("FAILED to restore wire: ", start_parent_name, ".", start_port_name, " -> ", end_parent_name, ".", end_port_name)
		if not start_port: 
			print("  - Start port not found: ", start_parent_name, ".", start_port_name)
		if not end_port: 
			print("  - End port not found: ", end_parent_name, ".", end_port_name)
		if start_port == end_port:
			print("  - Start and end ports are the same")
		return false

func get_wires_data():
	var wires_data = []
	
	for wire in wires:
		if not is_wire_valid(wire):
			continue
			
		var start_parent = wire.start_port.get_parent()
		var end_parent = wire.end_port.get_parent()
		
		var start_parent_name = start_parent.name
		var end_parent_name = end_parent.name
		
		# Сохраняем тип объектов для лучшего восстановления
		var start_parent_type = get_object_type(start_parent)
		var end_parent_type = get_object_type(end_parent)
		
		var wire_data = {
			"start_parent_name": start_parent_name,
			"start_port_name": wire.start_port.name,
			"start_parent_type": start_parent_type,
			"end_parent_name": end_parent_name,
			"end_port_name": wire.end_port.name,
			"end_parent_type": end_parent_type
		}
		wires_data.append(wire_data)
		
		print("Saving wire: ", start_parent_name, ".", wire.start_port.name, " -> ", end_parent_name, ".", wire.end_port.name, " (Types: ", start_parent_type, " -> ", end_parent_type, ")")
	
	print("Saved ", wires_data.size(), " wires")
	return wires_data

func get_object_type(obj):
	if obj == null:
		return "UNKNOWN"
	
	if obj is OpCodeBlock:
		return "OpCode"
	
	var scene_file = obj.scene_file_path
	
	# Более надежная проверка типов гейтов
	if "ANDGate" in scene_file:
		return "AND"
	elif "XORGate" in scene_file:
		return "XOR"
	elif "ORGate" in scene_file:
		return "OR" 
	elif "NANDGate" in scene_file:
		return "NAND"
	elif "NORGate" in scene_file:
		return "NOR"
	elif "XNORGate" in scene_file:
		return "XNOR"
	elif "ImplicationGate" in scene_file:
		return "IMPLICATION"
	elif "MUX4to1" in scene_file:
		return "MUX4to1"
	elif "OpCodeBlock" in scene_file:
		return "OpCode"
	
	# Дополнительные проверки по имени (исправленные)
	if "AND" in obj.name and "GATE" in obj.name.to_upper(): 
		return "AND"
	elif "OR" in obj.name and "GATE" in obj.name.to_upper(): 
		return "OR"  
	elif "XOR" in obj.name and "GATE" in obj.name.to_upper(): 
		return "XOR"
	elif "MUX" in obj.name: 
		return "MUX4to1"
	elif "OPCODE" in obj.name.to_upper(): 
		return "OpCode"
	
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
					sprite.texture = load("res://assets/point.png")
	if output_block:
		var port = output_block.get_node_or_null("InputPort")
		if port:
			var sprite = port.get_node_or_null("Sprite2D")
			if sprite:
				sprite.texture = load("res://assets/point.png")
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
				sprite.texture = load("res://assets/point.png")
	print("ALU level: Reset all port sprites")

# Методы добавления компонентов (без ограничений в базовом классе)
func _on_add_and_button_pressed():
	var gate = load("res://scenes/gates/base_logic_el/ANDGate.tscn").instantiate()
	gate.position = Vector2(600, 400)
	add_child(gate)
	movable_objects.append(gate)
	update_all_logic_objects()
	mark_level_state_dirty()

func _on_add_or_button_pressed():
	var gate = load("res://scenes/gates/base_logic_el/ORGate.tscn").instantiate()
	gate.position = Vector2(600, 500)
	add_child(gate)
	movable_objects.append(gate)
	update_all_logic_objects()
	mark_level_state_dirty()

func _on_add_xor_button_pressed():
	var gate = load("res://scenes/gates/base_logic_el/XORGate.tscn").instantiate()
	gate.position = Vector2(600, 600)
	add_child(gate)
	movable_objects.append(gate)
	update_all_logic_objects()
	mark_level_state_dirty()

func _on_add_mux4to1_button_pressed():
	var gate = load("res://scenes/gates/MUX4to1.tscn").instantiate()
	gate.position = Vector2(600, 700)
	gate.z_index = 1  # Добавьте эту строку
	add_child(gate)
	movable_objects.append(gate)
	update_all_logic_objects()
	mark_level_state_dirty()

func _on_add_opcode_button_pressed():
	var gate = load("res://scenes/gates/OpCodeBlock.tscn").instantiate()
	gate.position = Vector2(600, 800)
	gate.z_index = 1  # Добавьте эту строку
	add_child(gate)
	movable_objects.append(gate)
	update_all_logic_objects()
	mark_level_state_dirty()

# Методы для удаления гейтов (пустые в базовом классе)
func remove_and_gate():
	pass
	
func remove_or_gate():
	pass
	
func remove_xor_gate():
	pass

func remove_mux4to1():
	pass

func remove_opcode_block():
	pass

# Методы для других типов гейтов (для совместимости)
func remove_not_gate():
	pass

func remove_xnor_gate():
	pass

func remove_nand_gate():
	pass

func remove_nor_gate():
	pass

func remove_sel0_gate():
	pass

func remove_sel1_gate():
	pass
	
func get_port_under_mouse():
	var mouse_pos = get_global_mouse_position()
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = mouse_pos
	query.collide_with_areas = true
	query.collision_mask = 1  # Используем только слой 1 для портов
	var intersects = space_state.intersect_point(query, 1)
	if intersects.size() > 0:
		var collider = intersects[0].collider
		if collider is Area2D and is_instance_valid(collider):
			# Проверяем, что это не Area2D для подсветки (не на слое 2)
			if collider.collision_layer != 2:
				return collider
	return null

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
					wire.z_index = 0
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
					# Определяем тип компонента и вызываем соответствующий метод удаления
					var scene_file = obj.scene_file_path
					print("Removing object with scene file: ", scene_file)
					
					if scene_file.find("ANDGate") != -1:
						if has_method("remove_and_gate"):
							remove_and_gate()
					elif scene_file.find("XORGate") != -1:
						if has_method("remove_xor_gate"):
							remove_xor_gate()
					elif scene_file.find("ORGate") != -1:
						if has_method("remove_or_gate"):
							remove_or_gate()
					elif scene_file.find("MUX4to1") != -1:
						if has_method("remove_mux4to1"):
							remove_mux4to1()
					elif scene_file.find("OpCodeBlock") != -1:
						if has_method("remove_opcode_block"):
							remove_opcode_block()
					else:
						print("Unknown component type: ", scene_file)
					
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
