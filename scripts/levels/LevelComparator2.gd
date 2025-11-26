extends "res://scripts/levels/LevelBase.gd"

var input_block_a
var input_block_b  
var output_block_agtb
var output_block_altb
var output_block_aeqb

var one_bit_comparator_counter = 0

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

	setup_comparator2_level()
	
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
			level_data.expected_agtb,
			level_data.expected_altb,
			level_data.expected_aeqb
		)

	load_level_state()

	auto_save_timer = Timer.new()
	auto_save_timer.wait_time = 2.0
	auto_save_timer.one_shot = true
	auto_save_timer.timeout.connect(_on_auto_save_timeout)
	add_child(auto_save_timer)
	
	print("2-bit Comparator level ready completed successfully")

func setup_comparator2_level():
	print("Setting up 2-bit Comparator level with two dual-input blocks and three outputs")
	
	movable_objects = []
	
	input_block_a = get_node_or_null("InputBlockA")
	input_block_b = get_node_or_null("InputBlockB")
	
	if input_block_a and input_block_b:
		input_block_a.values_A = level_data.input_values_a1.duplicate()
		input_block_a.values_B = level_data.input_values_a0.duplicate()
		input_block_b.values_A = level_data.input_values_b1.duplicate()
		input_block_b.values_B = level_data.input_values_b0.duplicate()
		
		movable_objects.append(input_block_a)
		movable_objects.append(input_block_b)
		print("2-bit Comparator input blocks initialized")
	else:
		push_error("InputBlockA or InputBlockB not found in 2-bit Comparator level!")

	output_block_agtb = get_node_or_null("OutputBlockAgtb")
	output_block_altb = get_node_or_null("OutputBlockAltb")
	output_block_aeqb = get_node_or_null("OutputBlockAeqb")
	
	if output_block_agtb and output_block_altb and output_block_aeqb:
		output_block_agtb.expected = level_data.expected_agtb.duplicate()
		output_block_altb.expected = level_data.expected_altb.duplicate()
		output_block_aeqb.expected = level_data.expected_aeqb.duplicate()
		movable_objects.append(output_block_agtb)
		movable_objects.append(output_block_altb)
		movable_objects.append(output_block_aeqb)
		print("2-bit Comparator output blocks initialized")
	else:
		push_error("Output blocks not found in 2-bit Comparator level!")

	test_results_panel = get_node_or_null("TestResultsPanel2BitComparator")
	if test_results_panel:
		print("2-bit Comparator test panel found")

	update_all_logic_objects()
	print("Movable objects: ", movable_objects.size())
	print("All logic objects: ", all_logic_objects.size())

func _on_add_onebit_comparator_button_pressed():
	print("LevelComparator2: Adding OneBitComparator gate (base method)")
	var gate_scene = preload("res://scenes/gates/OneBitComparatorGate.tscn")
	var gate = gate_scene.instantiate()

	one_bit_comparator_counter += 1
	gate.name = "OneBitComparatorGate_" + str(one_bit_comparator_counter)
	
	var viewport_size = get_viewport_rect().size
	gate.position = Vector2(viewport_size.x / 2, viewport_size.y / 2)
	
	add_child(gate)
	movable_objects.append(gate)
	update_all_logic_objects()
	mark_level_state_dirty()
	
	print("OneBitComparator gate added at position: ", gate.position, " with name: ", gate.name)

func _on_add_and_button_pressed():
	print("LevelComparator2: Adding AND gate (base method)")
	var gate_scene = preload("res://scenes/gates/base_logic_el/ANDGate.tscn")
	var gate = gate_scene.instantiate()
	
	var viewport_size = get_viewport_rect().size
	gate.position = Vector2(viewport_size.x / 2, viewport_size.y / 2)
	
	add_child(gate)
	movable_objects.append(gate)
	update_all_logic_objects()
	mark_level_state_dirty()

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
			"end_parent_type": end_parent_type,
			"start_position": [wire.start_port.global_position.x, wire.start_port.global_position.y],
			"end_position": [wire.end_port.global_position.x, wire.end_port.global_position.y]
		}
		wires_data.append(wire_data)
		
		print("Saving wire: ", start_parent_name, ".", wire.start_port.name, " -> ", end_parent_name, ".", wire.end_port.name, " (Types: ", start_parent_type, " -> ", end_parent_type, ")")
	
	print("Saved ", wires_data.size(), " wires")
	return wires_data

func _on_add_or_button_pressed():
	print("LevelComparator2: Adding OR gate (base method)")
	var gate_scene = preload("res://scenes/gates/base_logic_el/ORGate.tscn")
	var gate = gate_scene.instantiate()
	
	var viewport_size = get_viewport_rect().size
	gate.position = Vector2(viewport_size.x / 2, viewport_size.y / 2)
	
	add_child(gate)
	movable_objects.append(gate)
	update_all_logic_objects()
	mark_level_state_dirty()

func _on_test_pressed():
	print("=== Testing 2-bit Comparator level ===")
	reset_all_port_sprites()

	if output_block_agtb:
		output_block_agtb.set_default_style()
	if output_block_altb:
		output_block_altb.set_default_style()
	if output_block_aeqb:
		output_block_aeqb.set_default_style()
	
	var player_agtb_outputs = []
	var player_altb_outputs = []
	var player_aeqb_outputs = []
	
	for i in range(16):
		print("--- Test case ", i, " ---")
		input_block_a.current_test_index = i
		input_block_b.current_test_index = i
		print("Inputs: A1=", input_block_a.values_A[i], " A0=", input_block_a.values_B[i], 
			  " B1=", input_block_b.values_A[i], " B0=", input_block_b.values_B[i])

		for obj in all_logic_objects:
			if obj and obj.has_method("reset_inputs"):
				obj.reset_inputs()

		if output_block_agtb:
			output_block_agtb.received_value = 0
		if output_block_altb:
			output_block_altb.received_value = 0
		if output_block_aeqb:
			output_block_aeqb.received_value = 0
			
		propagate_signals()
		
		if output_block_agtb:
			player_agtb_outputs.append(int(output_block_agtb.received_value))
			print("A>B output: ", output_block_agtb.received_value)
		else:
			player_agtb_outputs.append(0)
		
		if output_block_altb:
			player_altb_outputs.append(int(output_block_altb.received_value))
			print("A<B output: ", output_block_altb.received_value)
		else:
			player_altb_outputs.append(0)
			
		if output_block_aeqb:
			player_aeqb_outputs.append(int(output_block_aeqb.received_value))
			print("A==B output: ", output_block_aeqb.received_value)
		else:
			player_aeqb_outputs.append(0)
	
	print("=== Test results ===")
	print("Player A>B: ", player_agtb_outputs)
	print("Expected A>B: ", level_data.expected_agtb)
	print("Player A<B: ", player_altb_outputs)
	print("Expected A<B: ", level_data.expected_altb)
	print("Player A==B: ", player_aeqb_outputs)
	print("Expected A==B: ", level_data.expected_aeqb)

	if test_results_panel and test_results_panel.has_method("update_current_outputs"):
		test_results_panel.update_current_outputs(player_agtb_outputs, player_altb_outputs, player_aeqb_outputs)
		print("Test panel updated")

	var agtb_correct = player_agtb_outputs == level_data.expected_agtb
	var altb_correct = player_altb_outputs == level_data.expected_altb
	var aeqb_correct = player_aeqb_outputs == level_data.expected_aeqb
	
	print("A>B correct: ", agtb_correct, " A<B correct: ", altb_correct, " A==B correct: ", aeqb_correct)
	
	if agtb_correct and altb_correct and aeqb_correct:
		if output_block_agtb:
			output_block_agtb.set_correct_style()
		if output_block_altb:
			output_block_altb.set_correct_style()
		if output_block_aeqb:
			output_block_aeqb.set_correct_style()
		if not level_completed_this_session:
			save_level_progress()
			level_completed_this_session = true
		print("Level completed successfully!")
	else:
		if output_block_agtb:
			output_block_agtb.set_default_style()
		if output_block_altb:
			output_block_altb.set_default_style()
		if output_block_aeqb:
			output_block_aeqb.set_default_style()
		level_completed_this_session = false
		print("Level not completed - outputs don't match")
	
	update_all_port_colors()

func propagate_signals():
	print("=== Starting signal propagation for 2-bit Comparator ===")

	for obj in all_logic_objects:
		if obj and obj.has_method("reset_inputs"):
			obj.reset_inputs()

	if input_block_a and input_block_b:
		var a1_value = int(input_block_a.get_output("OutputA"))
		var a0_value = int(input_block_a.get_output("OutputB"))
		var b1_value = int(input_block_b.get_output("OutputA"))
		var b0_value = int(input_block_b.get_output("OutputB"))
		print("   Inputs - A1=", a1_value, " A0=", a0_value, " B1=", b1_value, " B0=", b0_value)
		
		for wire in wires:
			if not is_wire_valid(wire): continue
			
			if wire.start_port.get_parent() in [input_block_a, input_block_b]:
				var end_gate = wire.end_port.get_parent()
				if end_gate and end_gate.has_method("set_input"):
					var gate_type = get_object_type(end_gate)
					var port_num = get_gate_port_number(wire.end_port.name, gate_type)
					
					var value = 0
					var operation = "unknown"
					
					if wire.start_port.get_parent() == input_block_a:
						if wire.start_port.name == "OutputA":
							value = a1_value
							operation = "A1"
						elif wire.start_port.name == "OutputB":
							value = a0_value
							operation = "A0"
					elif wire.start_port.get_parent() == input_block_b:
						if wire.start_port.name == "OutputA":
							value = b1_value
							operation = "B1"
						elif wire.start_port.name == "OutputB":
							value = b0_value
							operation = "B0"
					
					print("   Setting ", operation, " (", value, ") to ", end_gate.name, " port ", port_num)
					end_gate.set_input(port_num, value)

	for obj in all_logic_objects:
		if not obj or obj in [input_block_a, input_block_b, output_block_agtb, output_block_altb, output_block_aeqb]:
			continue
			
		if obj.has_method("get_output"):
			if get_object_type(obj) == "OneBitComparator":
				var agtb_value = int(obj.get_output("OutputAgtb"))
				var altb_value = int(obj.get_output("OutputAltb"))
				var aeqb_value = int(obj.get_output("OutputAeqb"))
				print("   ", obj.name, " outputs - A>B:", agtb_value, " A<B:", altb_value, " A==B:", aeqb_value)
				
				for wire in wires:
					if not is_wire_valid(wire): continue
					
					if wire.start_port.get_parent() == obj:
						var end_gate = wire.end_port.get_parent()
						if end_gate and end_gate.has_method("set_input"):
							var gate_type = get_object_type(end_gate)
							var port_num = get_gate_port_number(wire.end_port.name, gate_type)
							var value = 0
							if wire.start_port.name == "OutputAgtb":
								value = agtb_value
							elif wire.start_port.name == "OutputAltb":
								value = altb_value
							elif wire.start_port.name == "OutputAeqb":
								value = aeqb_value
							
							print("   Connecting ", obj.name, " ", wire.start_port.name, " to ", end_gate.name, " port ", port_num)
							end_gate.set_input(port_num, value)
			else:
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

	print("=== Signal propagation complete ===")

func is_wire_valid(wire):
	return (wire and is_instance_valid(wire) and 
			wire.start_port and is_instance_valid(wire.start_port) and
			wire.end_port and is_instance_valid(wire.end_port))

func get_gates_data():
	var gates_data = []

	if input_block_a:
		gates_data.append({
			"type": "INPUT_BLOCK_A", 
			"position": [input_block_a.position.x, input_block_a.position.y],
			"name": input_block_a.name
		})
	if input_block_b:
		gates_data.append({
			"type": "INPUT_BLOCK_B", 
			"position": [input_block_b.position.x, input_block_b.position.y],
			"name": input_block_b.name
		})
	
	if output_block_agtb:
		gates_data.append({
			"type": "OUTPUT_BLOCK_AGTB", 
			"position": [output_block_agtb.position.x, output_block_agtb.position.y],
			"name": output_block_agtb.name
		})
	if output_block_altb:
		gates_data.append({
			"type": "OUTPUT_BLOCK_ALTB", 
			"position": [output_block_altb.position.x, output_block_altb.position.y],
			"name": output_block_altb.name
		})
	if output_block_aeqb:
		gates_data.append({
			"type": "OUTPUT_BLOCK_AEQB", 
			"position": [output_block_aeqb.position.x, output_block_aeqb.position.y],
			"name": output_block_aeqb.name
		})

	for obj in movable_objects:
		var skip = obj in [input_block_a, input_block_b, output_block_agtb, output_block_altb, output_block_aeqb]
		if skip:
			continue
			
		var gate_type = get_object_type(obj)
		gates_data.append({
			"type": gate_type, 
			"position": [obj.position.x, obj.position.y],
			"name": obj.name  
		})
	
	return gates_data

func clear_level():
	for wire in wires:
		if is_instance_valid(wire):
			wire.queue_free()
	wires.clear()

	for i in range(movable_objects.size() - 1, -1, -1):
		var obj = movable_objects[i]
		var skip = obj in [input_block_a, input_block_b, output_block_agtb, output_block_altb, output_block_aeqb]
		if skip:
			continue
			
		if is_instance_valid(obj):
			obj.queue_free()
		movable_objects.remove_at(i)
	
	update_all_logic_objects()
	reset_all_port_sprites()
	
	print("2-bit Comparator level cleared - kept Input/Output blocks, removed gates and wires")
	
func create_gate_from_data(gate_data):
	var gate_type = gate_data.get("type", "")
	var position_array = gate_data.get("position", [0, 0])
	var position = Vector2(position_array[0], position_array[1])
	var gate_name = gate_data.get("name", "")
	
	print("Attempting to restore gate: ", gate_type, " at position: ", position, " with name: ", gate_name)
	
	match gate_type:
		"INPUT_BLOCK_A":
			if input_block_a: 
				input_block_a.position = position
				if gate_name != "":
					input_block_a.name = gate_name
				print("Restored InputBlockA position: ", position)
		"INPUT_BLOCK_B":
			if input_block_b: 
				input_block_b.position = position
				if gate_name != "":
					input_block_b.name = gate_name
				print("Restored InputBlockB position: ", position)
		"OUTPUT_BLOCK_AGTB":
			if output_block_agtb: 
				output_block_agtb.position = position
				if gate_name != "":
					output_block_agtb.name = gate_name
				print("Restored OutputBlockAgtb position: ", position)
		"OUTPUT_BLOCK_ALTB":
			if output_block_altb: 
				output_block_altb.position = position
				if gate_name != "":
					output_block_altb.name = gate_name
				print("Restored OutputBlockAltb position: ", position)
		"OUTPUT_BLOCK_AEQB":
			if output_block_aeqb: 
				output_block_aeqb.position = position
				if gate_name != "":
					output_block_aeqb.name = gate_name
				print("Restored OutputBlockAeqb position: ", position)
		"OneBitComparator":
			var gate_scene = preload("res://scenes/gates/OneBitComparatorGate.tscn")
			var gate = gate_scene.instantiate()
			gate.position = position
			
			if gate_name != "":
				gate.name = gate_name
				# Обновляем счетчик если нужно
				var name_parts = gate_name.split("_")
				if name_parts.size() > 1:
					var num_str = name_parts[name_parts.size() - 1]
					if num_str.is_valid_int():
						var num = num_str.to_int()
						if num > one_bit_comparator_counter:
							one_bit_comparator_counter = num
			else:
				one_bit_comparator_counter += 1
				gate.name = "OneBitComparatorGate_" + str(one_bit_comparator_counter)
			
			add_child(gate)
			movable_objects.append(gate)
			print("SUCCESS: Restored OneBitComparator gate: ", gate.name, " at ", position)
		"AND":
			var gate_scene = preload("res://scenes/gates/base_logic_el/ANDGate.tscn")
			var gate = gate_scene.instantiate()
			gate.position = position
			if gate_name != "":
				gate.name = gate_name
			add_child(gate)
			movable_objects.append(gate)
			print("Restored AND gate: ", gate.name, " at ", position)
		"OR":
			var gate_scene = preload("res://scenes/gates/base_logic_el/ORGate.tscn")
			var gate = gate_scene.instantiate()
			gate.position = position
			if gate_name != "":
				gate.name = gate_name
			add_child(gate)
			movable_objects.append(gate)
			print("Restored OR gate: ", gate.name, " at ", position)

func restore_level_state(state):
	if not state:
		print("No state to restore")
		return
		
	print("=== Starting level state restoration ===")
	
	# Сначала очищаем уровень
	clear_level()
	
	# Затем восстанавливаем состояние
	if state.has("gates"):
		print("Restoring ", state["gates"].size(), " gates")
		for gate_data in state["gates"]:
			create_gate_from_data(gate_data)
	else:
		print("No gates data found in save state")
	
	# Обновляем логические объекты перед восстановлением проводов
	update_all_logic_objects()
	
	if state.has("wires"):
		print("Restoring ", state["wires"].size(), " wires")
		var restored_wires_count = 0
		var failed_wires_count = 0
		
		for wire_data in state["wires"]:
			if create_wire_from_data(wire_data):
				restored_wires_count += 1
			else:
				failed_wires_count += 1
				
		print("Wire restoration summary:")
		print("  Successfully restored: ", restored_wires_count)
		print("  Failed to restore: ", failed_wires_count)
		print("  Total attempted: ", state["wires"].size())
	else:
		print("No wires data found in save state")
	
	update_all_logic_objects()
	update_all_port_colors()
	
	print("Level state restoration completed")
	print("Movable objects: ", movable_objects.size())
	print("All logic objects: ", all_logic_objects.size())
	print("Wires: ", wires.size())
	
func find_port_by_name(parent_name, port_name, parent_type = ""):
	print("Searching for port: ", parent_name, ".", port_name, " (Type: ", parent_type, ")")
	
	var parent = null
	
	# Сначала проверяем основные блоки компаратора по точному имени
	if parent_name == "InputBlockA" and input_block_a:
		parent = input_block_a
	elif parent_name == "InputBlockB" and input_block_b:
		parent = input_block_b
	elif parent_name == "OutputBlockAgtb" and output_block_agtb:
		parent = output_block_agtb
	elif parent_name == "OutputBlockAltb" and output_block_altb:
		parent = output_block_altb
	elif parent_name == "OutputBlockAeqb" and output_block_aeqb:
		parent = output_block_aeqb
	
	# Если не нашли по точному имени, ищем среди movable_objects
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
		# Для компараторов - ищем по порядку
		if parent_type == "OneBitComparator":
			var comparators = []
			for obj in movable_objects:
				if get_object_type(obj) == "OneBitComparator":
					comparators.append(obj)
			
			# Пытаемся определить порядок по имени
			if "OneBitComparatorGate_1" in parent_name or "1" in parent_name:
				parent = comparators[0] if comparators.size() > 0 else null
			elif "OneBitComparatorGate_2" in parent_name or "2" in parent_name:
				parent = comparators[1] if comparators.size() > 1 else null
			elif "OneBitComparatorGate_3" in parent_name or "3" in parent_name:
				parent = comparators[2] if comparators.size() > 2 else null
			else:
				# Берем первый подходящий по типу
				parent = comparators[0] if comparators.size() > 0 else null
		else:
			# Для других типов берем первый подходящий
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
	
	# Для InputBlockA и InputBlockB
	if parent in [input_block_a, input_block_b]:
		match port_name:
			"OutputA": port = parent.get_node_or_null("OutputA")
			"OutputB": port = parent.get_node_or_null("OutputB")
	
	# Для OutputBlockAgtb, OutputBlockAltb, OutputBlockAeqb
	elif parent in [output_block_agtb, output_block_altb, output_block_aeqb]:
		if port_name == "InputPort":
			port = parent.get_node_or_null("InputPort")
	
	# Для OneBitComparator
	elif parent_type == "OneBitComparator":
		match port_name:
			"InputA": port = parent.get_node_or_null("InputA")
			"InputB": port = parent.get_node_or_null("InputB")
			"OutputAgtb": port = parent.get_node_or_null("OutputAgtb")
			"OutputAltb": port = parent.get_node_or_null("OutputAltb")
			"OutputAeqb": port = parent.get_node_or_null("OutputAeqb")
	
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
		var wire = preload("res://scenes/components/Wire.tscn").instantiate()
		wire.connect_ports(start_port, end_port)
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

func get_object_type(obj):
	if obj == null:
		return "UNKNOWN"
	
	var scene_file = obj.scene_file_path
	if "OneBitComparatorGate" in scene_file:
		return "OneBitComparator"
	elif "ANDGate" in scene_file:
		return "AND"
	elif "ORGate" in scene_file:
		return "OR"

	if obj == input_block_a:
		return "INPUT_BLOCK_A"
	elif obj == input_block_b:
		return "INPUT_BLOCK_B"
	elif obj == output_block_agtb:
		return "OUTPUT_BLOCK_AGTB"
	elif obj == output_block_altb:
		return "OUTPUT_BLOCK_ALTB"
	elif obj == output_block_aeqb:
		return "OUTPUT_BLOCK_AEQB"
	
	return "UNKNOWN"

func find_port_near_position(position, max_distance = 50.0):
	var closest_port = null
	var closest_distance = max_distance
	
	for obj in movable_objects:
		if not obj or not is_instance_valid(obj):
			continue
			
		var ports = []

		if obj in [input_block_a, input_block_b]:
			ports.append(obj.get_node_or_null("OutputA"))
			ports.append(obj.get_node_or_null("OutputB"))
		elif obj in [output_block_agtb, output_block_altb, output_block_aeqb]:
			var input_port = obj.get_node_or_null("InputPort")
			if input_port: ports.append(input_port)
		elif get_object_type(obj) == "OneBitComparator":
			ports.append(obj.get_node_or_null("InputA"))
			ports.append(obj.get_node_or_null("InputB"))
			ports.append(obj.get_node_or_null("OutputAgtb"))
			ports.append(obj.get_node_or_null("OutputAltb"))
			ports.append(obj.get_node_or_null("OutputAeqb"))
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
	for obj in movable_objects:
		if not obj or not is_instance_valid(obj):
			continue

		if obj in [input_block_a, input_block_b]:
			for port_name in ["OutputA", "OutputB"]:
				var port = obj.get_node_or_null(port_name)
				if port:
					var sprite = port.get_node_or_null("Sprite2D")
					if sprite:
						sprite.texture = preload("res://assets/point.png")
		elif obj in [output_block_agtb, output_block_altb, output_block_aeqb]:
			var input_port = obj.get_node_or_null("InputPort")
			if input_port:
				var sprite = input_port.get_node_or_null("Sprite2D")
				if sprite:
					sprite.texture = preload("res://assets/point.png")
		elif get_object_type(obj) == "OneBitComparator":
			for port_name in ["InputA", "InputB", "OutputAgtb", "OutputAltb", "OutputAeqb"]:
				var port = obj.get_node_or_null(port_name)
				if port:
					var sprite = port.get_node_or_null("Sprite2D")
					if sprite:
						sprite.texture = preload("res://assets/point.png")
		else:
			for port_name in ["Input1", "Input2", "InputPort", "Output"]:
				var port = obj.get_node_or_null(port_name)
				if port:
					var sprite = port.get_node_or_null("Sprite2D")
					if sprite:
						sprite.texture = preload("res://assets/point.png")
	
	print("2-bit Comparator level: Reset all port sprites")

func get_gate_port_number(port_name: String, gate_type: String) -> int:
	if gate_type == "OneBitComparator":
		match port_name:
			"InputA": return 1
			"InputB": return 2
			"OutputAgtb", "OutputAltb", "OutputAeqb": return 1
			_: return 1
	
	if gate_type in ["AND", "OR"]:
		match port_name:
			"Input1": return 1
			"Input2": return 2
			"Output": return 1
			_: return 1

	return 1

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
			var skip = obj in [input_block_a, input_block_b, output_block_agtb, output_block_altb, output_block_aeqb]
			if skip:
				continue
				
			var sprite = obj.get_node_or_null("Sprite2D")
			if sprite and is_instance_valid(sprite):
				var local_mouse = sprite.to_local(mouse_pos)
				var sprite_rect = sprite.get_rect()
				if sprite_rect.has_point(local_mouse):
					# Определяем тип гейта и вызываем соответствующий метод удаления
					var scene_file = obj.scene_file_path
					print("Removing object with scene file: ", scene_file)
					
					# Более точная проверка типов гейтов
					if scene_file.find("OneBitComparatorGate") != -1:
						if has_method("remove_comparator_gate"):
							remove_comparator_gate()
						else:
							print("WARNING: remove_comparator_gate method not found")
					elif scene_file.find("XORGate") != -1:
						if has_method("remove_xor_gate"):
							remove_xor_gate()
						else:
							print("WARNING: remove_xor_gate method not found")
					elif scene_file.find("XNORGate") != -1:
						if has_method("remove_xnor_gate"):
							remove_xnor_gate()
						else:
							print("WARNING: remove_xnor_gate method not found")
					elif scene_file.find("NANDGate") != -1:
						if has_method("remove_nand_gate"):
							remove_nand_gate()
						else:
							print("WARNING: remove_nand_gate method not found")
					elif scene_file.find("NORGate") != -1:
						if has_method("remove_nor_gate"):
							remove_nor_gate()
						else:
							print("WARNING: remove_nor_gate method not found")
					elif scene_file.find("Sel0") != -1:
						if has_method("remove_sel0_gate"):
							remove_sel0_gate()
						else:
							print("WARNING: remove_sel0_gate method not found")
					elif scene_file.find("Sel1") != -1:
						if has_method("remove_sel1_gate"):
							remove_sel1_gate()
						else:
							print("WARNING: remove_sel1_gate method not found")
					elif scene_file.find("ORGate") != -1:
						if has_method("remove_or_gate"):
							remove_or_gate()
						else:
							print("WARNING: remove_or_gate method not found")
					elif scene_file.find("ANDGate") != -1:
						if has_method("remove_and_gate"):
							remove_and_gate()
						else:
							print("WARNING: remove_and_gate method not found")
					elif scene_file.find("NOTGate") != -1:
						if has_method("remove_not_gate"):
							remove_not_gate()
						else:
							print("WARNING: remove_not_gate method not found")
					else:
						print("Unknown gate type: ", scene_file)
					
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

# Пустые методы для удаления гейтов (будут переопределены в Level20.gd)
func remove_and_gate():
	pass
	
func remove_or_gate():
	pass
	
func remove_comparator_gate():
	pass
	
func remove_xor_gate():
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

func remove_not_gate():
	pass
