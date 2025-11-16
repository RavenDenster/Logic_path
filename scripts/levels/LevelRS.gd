extends "res://scripts/levels/LevelBase.gd"

var input_block_r
var input_block_s
var output_block_q
var output_block_not_q

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

	setup_rs_level()
	
	temp_line = Line2D.new()
	add_child(temp_line)
	temp_line.default_color = Color("#e39e45")
	temp_line.width = 8
	temp_line.points = []
	
	_setup_top_panel_buttons()
	
	await get_tree().process_frame

	if test_results_panel and test_results_panel.has_method("load_initial_data"):
		test_results_panel.load_initial_data(
			level_data.input_values_r, 
			level_data.input_values_s,
			level_data.expected_q,
			level_data.expected_not_q
		)

	load_level_state()

	auto_save_timer = Timer.new()
	auto_save_timer.wait_time = 2.0
	auto_save_timer.one_shot = true
	auto_save_timer.timeout.connect(_on_auto_save_timeout)
	add_child(auto_save_timer)
	
	print("RS level ready completed successfully")

func setup_rs_level():
	print("Setting up RS level with two inputs and two outputs")
	
	movable_objects = []
	
	# Get input blocks
	input_block_r = get_node_or_null("InputBlockR")
	input_block_s = get_node_or_null("InputBlockS")
	
	if input_block_r and input_block_s:
		input_block_r.values = level_data.input_values_r.duplicate()
		input_block_s.values = level_data.input_values_s.duplicate()
		movable_objects.append(input_block_r)
		movable_objects.append(input_block_s)
		print("RS input blocks initialized")
	else:
		push_error("Input blocks not found in RS level!")

	# Get output blocks
	output_block_q = get_node_or_null("OutputBlockQ")
	output_block_not_q = get_node_or_null("OutputBlockNotQ")
	
	if output_block_q and output_block_not_q:
		output_block_q.expected = level_data.expected_q.duplicate()
		output_block_not_q.expected = level_data.expected_not_q.duplicate()
		movable_objects.append(output_block_q)
		movable_objects.append(output_block_not_q)
		print("RS output blocks initialized")
	else:
		push_error("Output blocks not found in RS level!")

	test_results_panel = get_node_or_null("TestResultsPanelRS")
	if test_results_panel:
		print("RS test panel found")

	update_all_logic_objects()
	print("Movable objects: ", movable_objects.size())
	print("All logic objects: ", all_logic_objects.size())

func _on_test_pressed():
	print("=== Testing RS level ===")
	reset_all_port_sprites()

	if output_block_q:
		output_block_q.set_default_style()
	if output_block_not_q:
		output_block_not_q.set_default_style()
	
	var player_q_outputs = []
	var player_not_q_outputs = []
	
	# Для RS-триггера важно сохранять состояние между тестами
	for obj in all_logic_objects:
		if obj and obj.has_method("reset_inputs"):
			obj.reset_inputs()

	for i in range(8):
		print("--- Test case ", i, " ---")
		input_block_r.current_test_index = i
		input_block_s.current_test_index = i
		print("Inputs: R=", input_block_r.values[i], " S=", input_block_s.values[i])

		propagate_signals()
		
		if output_block_q:
			player_q_outputs.append(int(output_block_q.received_value))
			print("Q output: ", output_block_q.received_value)
		else:
			player_q_outputs.append(0)
		
		if output_block_not_q:
			player_not_q_outputs.append(int(output_block_not_q.received_value))
			print("Not Q output: ", output_block_not_q.received_value)
		else:
			player_not_q_outputs.append(0)
	
	print("=== Test results ===")
	print("Player Q: ", player_q_outputs)
	print("Expected Q: ", level_data.expected_q)
	print("Player Not Q: ", player_not_q_outputs)
	print("Expected Not Q: ", level_data.expected_not_q)

	if test_results_panel and test_results_panel.has_method("update_current_outputs"):
		test_results_panel.update_current_outputs(player_q_outputs, player_not_q_outputs)
		print("Test panel updated")

	var q_correct = player_q_outputs == level_data.expected_q
	var not_q_correct = player_not_q_outputs == level_data.expected_not_q
	
	print("Q correct: ", q_correct, " Not Q correct: ", not_q_correct)
	
	if q_correct and not_q_correct:
		if output_block_q:
			output_block_q.set_correct_style()
		if output_block_not_q:
			output_block_not_q.set_correct_style()
		if not level_completed_this_session:
			save_level_progress()
			level_completed_this_session = true
		print("Level completed successfully!")
	else:
		if output_block_q:
			output_block_q.set_default_style()
		if output_block_not_q:
			output_block_not_q.set_default_style()
		level_completed_this_session = false
		print("Level not completed - outputs don't match")
	
	update_all_port_colors()

func propagate_signals():
	print("=== Starting signal propagation for RS ===")

	# Найдем RS-триггеры
	var rs_flip_flops = []
	for obj in all_logic_objects:
		if obj and is_instance_valid(obj) and obj != input_block_r and obj != input_block_s and obj != output_block_q and obj != output_block_not_q:
			if obj is RSFlipFlop:
				rs_flip_flops.append(obj)
	
	print("Found RS flip-flops: ", rs_flip_flops.size())
	
	if rs_flip_flops.size() > 0:
		# Используем первый найденный RS-триггер
		var rs_flip_flop = rs_flip_flops[0]
		
		# Получаем входные значения
		var r_value = input_block_r.get_output("Output")
		var s_value = input_block_s.get_output("Output")
		
		print("Inputs: R=", r_value, " S=", s_value)
		
		# Устанавливаем входы в RS-триггер
		rs_flip_flop.set_input(1, s_value)  # S input
		rs_flip_flop.set_input(2, r_value)  # R input
		
		# Получаем выходы
		var q_value = rs_flip_flop.get_output("OutputQ")
		var not_q_value = rs_flip_flop.get_output("OutputNotQ")
		
		# Устанавливаем выходные значения
		output_block_q.set_input(1, q_value)
		output_block_not_q.set_input(1, not_q_value)
		
		print("RS outputs: Q=", q_value, " !Q=", not_q_value)
	else:
		# Стандартная логика распространения (для обратной совместимости)
		propagate_signals_standard()
	
	print("=== Signal propagation complete ===")

func propagate_signals_standard():
	print("Using standard propagation for NOR gates")
	
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
			
		if current in [input_block_r, input_block_s]:
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
						elif end_port_name == "InputPort":
							port_num = 1
						elif end_port_name == "Input":
							port_num = 1
						
						end_gate.set_input(port_num, output_value)

		elif current.has_method("get_output") and current != output_block_q and current != output_block_not_q and not (current is RSFlipFlop):
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
						elif end_port_name == "InputPort":
							port_num = 1
						elif end_port_name == "Input":
							port_num = 1
						
						end_gate.set_input(port_num, output_value)

func get_gates_data():
	var gates_data = []

	if input_block_r:
		var input_block_r_data = {
			"type": "INPUT_BLOCK_R",
			"position": [input_block_r.position.x, input_block_r.position.y]
		}
		gates_data.append(input_block_r_data)
	
	if input_block_s:
		var input_block_s_data = {
			"type": "INPUT_BLOCK_S",
			"position": [input_block_s.position.x, input_block_s.position.y]
		}
		gates_data.append(input_block_s_data)

	if output_block_q:
		var output_block_q_data = {
			"type": "OUTPUT_BLOCK_Q", 
			"position": [output_block_q.position.x, output_block_q.position.y]
		}
		gates_data.append(output_block_q_data)
	
	if output_block_not_q:
		var output_block_not_q_data = {
			"type": "OUTPUT_BLOCK_NOT_Q", 
			"position": [output_block_not_q.position.x, output_block_not_q.position.y]
		}
		gates_data.append(output_block_not_q_data)

	for obj in movable_objects:
		var skip = false

		if obj == input_block_r or obj == input_block_s:
			skip = true
		if obj == output_block_q or obj == output_block_not_q:
			skip = true

		if skip:
			continue
			
		var scene_file = obj.scene_file_path
		var gate_type = "UNKNOWN"

		if "RSFlipFlop" in scene_file:
			gate_type = "RSFLIPFLOP"
		elif "NORGate" in scene_file:
			gate_type = "NOR"
		
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
		if obj == input_block_r or obj == input_block_s:
			skip = true
		if obj == output_block_q or obj == output_block_not_q:
			skip = true

		if skip:
			continue
			
		if is_instance_valid(obj):
			obj.queue_free()
		movable_objects.remove_at(i)
	
	update_all_logic_objects()
	reset_all_port_sprites()
	
	print("RS level cleared - kept Input/Output blocks, removed gates and wires")
	
func create_gate_from_data(gate_data):
	var gate_type = gate_data.get("type", "")
	var position_array = gate_data.get("position", [0, 0])
	var position = Vector2(position_array[0], position_array[1])
	
	if gate_type == "INPUT_BLOCK_R" and input_block_r:
		input_block_r.position = position
		print("Restored InputBlockR position: ", position)
		return
	elif gate_type == "INPUT_BLOCK_S" and input_block_s:
		input_block_s.position = position
		print("Restored InputBlockS position: ", position)
		return
	elif gate_type == "OUTPUT_BLOCK_Q" and output_block_q:
		output_block_q.position = position
		print("Restored OutputBlockQ position: ", position)
		return
	elif gate_type == "OUTPUT_BLOCK_NOT_Q" and output_block_not_q:
		output_block_not_q.position = position
		print("Restored OutputBlockNotQ position: ", position)
		return

	var gate_scene = null
	
	match gate_type:
		"NOR":
			gate_scene = preload("res://scenes/gates/NORGate.tscn")
		"RSFLIPFLOP":
			gate_scene = preload("res://scenes/gates/RSFlipFlop.tscn")
	
	if gate_scene:
		var gate = gate_scene.instantiate()
		gate.position = position
		add_child(gate)
		movable_objects.append(gate)
		print("Restored gate: ", gate_type, " at ", position)

func find_port_by_name(parent_name, port_name):
	var parent = null
	
	if parent_name == "InputBlockR" and input_block_r:
		parent = input_block_r
	elif parent_name == "InputBlockS" and input_block_s:
		parent = input_block_s
	elif parent_name == "OutputBlockQ" and output_block_q:
		parent = output_block_q
	elif parent_name == "OutputBlockNotQ" and output_block_not_q:
		parent = output_block_not_q

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
	
	var scene_file = obj.scene_file_path
	if "RSFlipFlop" in scene_file:
		return "RSFLIPFLOP"
	elif "NORGate" in scene_file:
		return "NOR"

	if obj == input_block_r:
		return "INPUT_BLOCK_R"
	elif obj == input_block_s:
		return "INPUT_BLOCK_S"
	elif obj == output_block_q:
		return "OUTPUT_BLOCK_Q"
	elif obj == output_block_not_q:
		return "OUTPUT_BLOCK_NOT_Q"
	
	return "UNKNOWN"

func find_port_near_position(position, max_distance = 50.0):
	var closest_port = null
	var closest_distance = max_distance
	
	for obj in movable_objects:
		if not obj or not is_instance_valid(obj):
			continue
			
		var ports = []

		if obj == input_block_r or obj == input_block_s:
			var output = obj.get_node_or_null("Output")
			if output: ports.append(output)
		elif obj == output_block_q or obj == output_block_not_q:
			var input_port = obj.get_node_or_null("InputPort")
			if input_port: ports.append(input_port)
		elif obj is RSFlipFlop:
			var input_r = obj.get_node_or_null("InputR")
			var input_s = obj.get_node_or_null("InputS")
			var output_q = obj.get_node_or_null("OutputQ")
			var output_not_q = obj.get_node_or_null("OutputNotQ")
			
			if input_r: ports.append(input_r)
			if input_s: ports.append(input_s)
			if output_q: ports.append(output_q)
			if output_not_q: ports.append(output_not_q)
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
	if input_block_r:
		var output_port = input_block_r.get_node_or_null("Output")
		if output_port and is_instance_valid(output_port):
			var sprite = output_port.get_node_or_null("Sprite2D")
			if sprite and is_instance_valid(sprite):
				sprite.texture = preload("res://assets/point.png")

	if input_block_s:
		var output_port = input_block_s.get_node_or_null("Output")
		if output_port and is_instance_valid(output_port):
			var sprite = output_port.get_node_or_null("Sprite2D")
			if sprite and is_instance_valid(sprite):
				sprite.texture = preload("res://assets/point.png")

	if output_block_q:
		var input_port = output_block_q.get_node_or_null("InputPort")
		if input_port and is_instance_valid(input_port):
			var sprite = input_port.get_node_or_null("Sprite2D")
			if sprite and is_instance_valid(sprite):
				sprite.texture = preload("res://assets/point.png")

	if output_block_not_q:
		var input_port = output_block_not_q.get_node_or_null("InputPort")
		if input_port and is_instance_valid(input_port):
			var sprite = input_port.get_node_or_null("Sprite2D")
			if sprite and is_instance_valid(sprite):
				sprite.texture = preload("res://assets/point.png")

	for obj in movable_objects:
		if not obj or not is_instance_valid(obj):
			continue

		if obj == input_block_r or obj == input_block_s:
			continue
		if obj == output_block_q or obj == output_block_not_q:
			continue

		var ports = []
		
		if obj is RSFlipFlop:
			var input_r = obj.get_node_or_null("InputR")
			var input_s = obj.get_node_or_null("InputS")
			var output_q = obj.get_node_or_null("OutputQ")
			var output_not_q = obj.get_node_or_null("OutputNotQ")
			
			if input_r: ports.append(input_r)
			if input_s: ports.append(input_s)
			if output_q: ports.append(output_q)
			if output_not_q: ports.append(output_not_q)
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
	
	print("RS level: Reset all port sprites")

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

			if obj == input_block_r or obj == input_block_s:
				skip = true
			if obj == output_block_q or obj == output_block_not_q:
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
