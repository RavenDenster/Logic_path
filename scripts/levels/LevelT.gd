# LevelT.gd
extends "res://scripts/levels/LevelBase.gd"

var input_block_clk
var output_block_q
var clock_signal_gate = null  # Для постоянной единицы в T-триггере
var current_test_case = 0

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

	setup_trigger_level()
	
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
			level_data.expected_q
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
			hints_enabled = (failed_attempts_count >= 5)

func setup_trigger_level():
	movable_objects = []
	
	input_block_clk = get_node_or_null("InputBlockCLK")
	
	if input_block_clk:
		input_block_clk.values = level_data.input_values_clk.duplicate()
		input_block_clk.input_label = "CLK"
		movable_objects.append(input_block_clk)
	else:
		push_error("CLK input block not found in Trigger level!")

	output_block_q = get_node_or_null("OutputBlockQ")
	
	if output_block_q:
		output_block_q.expected = level_data.expected_q.duplicate()
		output_block_q.output_label = "Current Q"
		movable_objects.append(output_block_q)
	else:
		push_error("Q output block not found in Trigger level!")

	test_results_panel = get_node_or_null("TestResultsPanelTTrigger")
	if test_results_panel:
		if input_block_clk:
			input_block_clk.test_results_panel = test_results_panel
		if output_block_q:
			output_block_q.test_results_panel = test_results_panel

	update_all_logic_objects()

func _on_test_pressed():
	var level_number = get_level_number()
	if level_number > 0:
		var save_system = get_node_or_null("/root/SaveSystem")
		if save_system and save_system.has_method("record_level_attempt"):
			save_system.record_level_attempt(level_number)
	
	reset_all_port_sprites()

	if output_block_q:
		output_block_q.set_default_style()
	
	var player_q_outputs = []
	
	for obj in all_logic_objects:
		if obj and obj.has_method("reset_state"):
			obj.reset_state()
	
	for obj in all_logic_objects:
		if obj and obj.has_method("reset_inputs"):
			obj.reset_inputs()
	
	for i in range(8):
		current_test_case = i
		input_block_clk.current_test_index = i

		var clk_value = input_block_clk.values[i]
		
		propagate_signals_with_feedback(clk_value)
		
		if output_block_q:
			player_q_outputs.append(int(output_block_q.received_value))
		else:
			player_q_outputs.append(0)
	
	if test_results_panel and test_results_panel.has_method("update_current_outputs"):
		test_results_panel.update_current_outputs(player_q_outputs)

	var q_correct = player_q_outputs == level_data.expected_q
	
	if q_correct:
		if output_block_q:
			output_block_q.set_correct_style()
		if not level_completed_this_session:
			save_level_progress()
			level_completed_this_session = true
		handle_test_success()
	else:
		if output_block_q:
			output_block_q.set_default_style()
		level_completed_this_session = false
		handle_test_failure()
	
	update_all_port_colors()

func propagate_signals_with_feedback(clk_value):
	for obj in all_logic_objects:
		if not obj or not is_instance_valid(obj):
			continue
			
		if obj == input_block_clk:
			obj.current_test_index = current_test_case
			
			for wire in wires:
				if not wire or not is_instance_valid(wire):
					continue
				if not wire.start_port or not is_instance_valid(wire.start_port):
					continue
					
				if wire.start_port.get_parent() == obj:
					var end_gate = wire.end_port.get_parent()
					if not end_gate or not is_instance_valid(end_gate):
						continue
						
					var end_port_name = wire.end_port.name
					
					if end_gate.has_method("set_input"):
						var port_num = 1
						if end_port_name == "Input2":
							port_num = 2
						elif end_port_name == "InputCLK":
							port_num = 2
						elif end_port_name == "InputD":
							port_num = 1
						elif end_port_name == "Input":
							port_num = 1
						elif end_port_name == "InputPort":
							port_num = 1
						
						end_gate.set_input(port_num, clk_value)
	
	var max_iterations = 10
	for iteration in range(max_iterations):
		var changed = false
		
		for obj in all_logic_objects:
			if not obj or not is_instance_valid(obj):
				continue
				
			if obj.is_in_group("ConstantOne"):
				var const_value = int(obj.get_output("Output"))
				
				for wire in wires:
					if not wire or not is_instance_valid(wire):
						continue
					if not wire.start_port or not is_instance_valid(wire.start_port):
						continue
						
					if wire.start_port.get_parent() == obj:
						var end_gate = wire.end_port.get_parent()
						if not end_gate or not is_instance_valid(end_gate):
							continue
							
						var end_port_name = wire.end_port.name
						
						if end_gate.has_method("set_input"):
							var port_num = 1
							if end_port_name == "Input2":
								port_num = 2
							elif end_port_name == "InputCLK":
								port_num = 2
							elif end_port_name == "InputD":
								port_num = 1
							elif end_port_name == "Input":
								port_num = 1
							elif end_port_name == "InputPort":
								port_num = 1
							
							end_gate.set_input(port_num, const_value)
							changed = true
			
			elif obj.is_in_group("XORGate"):
				if obj.has_method("update_output"):
					obj.update_output()
				
				var xor_output = int(obj.get_output("Output"))
				
				for wire in wires:
					if not wire or not is_instance_valid(wire):
						continue
					if not wire.start_port or not is_instance_valid(wire.start_port):
						continue
						
					if wire.start_port.get_parent() == obj:
						var end_gate = wire.end_port.get_parent()
						if not end_gate or not is_instance_valid(end_gate):
							continue
							
						var end_port_name = wire.end_port.name
						
						if end_gate.has_method("set_input"):
							var port_num = 1
							if end_port_name == "Input2":
								port_num = 2
							elif end_port_name == "InputCLK":
								port_num = 2
							elif end_port_name == "InputD":
								port_num = 1
							elif end_port_name == "Input":
								port_num = 1
							elif end_port_name == "InputPort":
								port_num = 1
							
							end_gate.set_input(port_num, xor_output)
							changed = true
			
			elif obj.is_in_group("DTrigger"):
				if obj.has_method("update_outputs"):
					obj.update_outputs()
				
				var q_value = int(obj.get_output("OutputQ"))
				
				for wire in wires:
					if not wire or not is_instance_valid(wire):
						continue
					if not wire.start_port or not is_instance_valid(wire.start_port):
						continue
						
					if wire.start_port.get_parent() == obj:
						var end_gate = wire.end_port.get_parent()
						if not end_gate or not is_instance_valid(end_gate):
							continue
							
						var end_port_name = wire.end_port.name
						
						if end_gate.has_method("set_input"):
							var port_num = 1
							if end_port_name == "Input2":
								port_num = 2
							elif end_port_name == "InputCLK":
								port_num = 2
							elif end_port_name == "InputD":
								port_num = 1
							elif end_port_name == "Input":
								port_num = 1
							elif end_port_name == "InputPort":
								port_num = 1
							
							end_gate.set_input(port_num, q_value)
							changed = true
		
		if not changed:
			break
	
	for obj in all_logic_objects:
		if not obj or not is_instance_valid(obj):
			continue
			
		if obj == output_block_q:
			for wire in wires:
				if not wire or not is_instance_valid(wire):
					continue
				if not wire.end_port or not is_instance_valid(wire.end_port):
					continue
					
				if wire.end_port.get_parent() == obj:
					var start_gate = wire.start_port.get_parent()
					if not start_gate or not is_instance_valid(start_gate):
						continue
						
					if start_gate.has_method("get_output"):
						var output_value = int(start_gate.get_output("Output"))
						obj.set_input(1, output_value)
						break

func _topological_sort(node, dependencies, visited, result):
	visited[node] = true
	
	for neighbor in dependencies.get(node, []):
		if not visited.has(neighbor):
			_topological_sort(neighbor, dependencies, visited, result)
	
	result.append(node)

func get_gates_data():
	var gates_data = []

	if input_block_clk:
		var input_block_clk_data = {
			"type": "INPUT_BLOCK_CLK",
			"position": [input_block_clk.position.x, input_block_clk.position.y]
		}
		gates_data.append(input_block_clk_data)
	
	if output_block_q:
		var output_block_q_data = {
			"type": "OUTPUT_BLOCK_Q", 
			"position": [output_block_q.position.x, output_block_q.position.y]
		}
		gates_data.append(output_block_q_data)

	if clock_signal_gate:
		var clock_signal_data = {
			"type": "CLOCK_SIGNAL",
			"position": [clock_signal_gate.position.x, clock_signal_gate.position.y]
		}
		gates_data.append(clock_signal_data)

	for obj in movable_objects:
		var skip = false

		if obj == input_block_clk or obj == output_block_q or obj == clock_signal_gate:
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
		elif "DTrigger" in scene_file:
			gate_type = "DTRIGGER"
		elif "ConstantOne" in scene_file:
			gate_type = "CONSTANT_ONE"
		
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
		if obj == input_block_clk or obj == output_block_q:
			skip = true

		if skip:
			continue
			
		if is_instance_valid(obj):
			obj.queue_free()
		movable_objects.remove_at(i)
	
	update_all_logic_objects()
	reset_all_port_sprites()
	
func create_gate_from_data(gate_data):
	var gate_type = gate_data.get("type", "")
	var position_array = gate_data.get("position", [0, 0])
	var position = Vector2(position_array[0], position_array[1])
	
	if gate_type == "INPUT_BLOCK_CLK" and input_block_clk:
		input_block_clk.position = position
		return
	elif gate_type == "OUTPUT_BLOCK_Q" and output_block_q:
		output_block_q.position = position
		return
	elif gate_type == "CLOCK_SIGNAL":
		return

	var gate_scene = null
	
	match gate_type:
		"AND":
			gate_scene = load("res://scenes/gates/base_logic_el/ANDGate.tscn")
		"OR":
			gate_scene = load("res://scenes/gates/base_logic_el/ORGate.tscn")
		"NOT":
			gate_scene = load("res://scenes/gates/base_logic_el/NOTGate.tscn")
		"XOR":
			gate_scene = load("res://scenes/gates/base_logic_el/XORGate.tscn")
		"DTRIGGER":
			gate_scene = load("res://scenes/gates/DTrigger.tscn")
		"CONSTANT_ONE":
			gate_scene = load("res://scenes/gates/ConstantOne.tscn")
	
	if gate_scene:
		var gate = gate_scene.instantiate()
		gate.position = position
		add_child(gate)
		movable_objects.append(gate)

func find_port_by_name(parent_name, port_name):
	var parent = null
	
	if parent_name == "InputBlockCLK" and input_block_clk:
		parent = input_block_clk
	elif parent_name == "OutputBlockQ" and output_block_q:
		parent = output_block_q
	elif parent_name == "ClockSignal" and clock_signal_gate:
		parent = clock_signal_gate

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
	elif "DTrigger" in scene_file:
		return "DTRIGGER"
	elif "ConstantOne" in scene_file:
		return "CONSTANT_ONE"

	if obj == input_block_clk:
		return "INPUT_BLOCK_CLK"
	elif obj == output_block_q:
		return "OUTPUT_BLOCK_Q"
	elif obj == clock_signal_gate:
		return "CLOCK_SIGNAL"
	
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
		elif obj == output_block_q:
			var input_port = obj.get_node_or_null("InputPort")
			if input_port: ports.append(input_port)
		elif obj == clock_signal_gate:
			var output = obj.get_node_or_null("Output")
			if output: ports.append(output)
		else:
			var input1 = obj.get_node_or_null("Input1")
			var input2 = obj.get_node_or_null("Input2")
			var input_port = obj.get_node_or_null("InputPort")
			var input_d = obj.get_node_or_null("InputD")
			var input_clk = obj.get_node_or_null("InputCLK")
			var output = obj.get_node_or_null("Output")
			var output_q = obj.get_node_or_null("OutputQ")
			var output_q_not = obj.get_node_or_null("OutputQNot")
			
			if input1: ports.append(input1)
			if input2: ports.append(input2)
			if input_port: ports.append(input_port)
			if input_d: ports.append(input_d)
			if input_clk: ports.append(input_clk)
			if output: ports.append(output)
			if output_q: ports.append(output_q)
			if output_q_not: ports.append(output_q_not)
		
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

	if output_block_q:
		var input_port = output_block_q.get_node_or_null("InputPort")
		if input_port and is_instance_valid(input_port):
			var sprite = input_port.get_node_or_null("Sprite2D")
			if sprite and is_instance_valid(sprite):
				sprite.texture = load("res://assets/point.png")

	if clock_signal_gate:
		var output_port = clock_signal_gate.get_node_or_null("Output")
		if output_port and is_instance_valid(output_port):
			var sprite = output_port.get_node_or_null("Sprite2D")
			if sprite and is_instance_valid(sprite):
				sprite.texture = load("res://assets/point.png")

	for obj in movable_objects:
		if not obj or not is_instance_valid(obj):
			continue

		if obj == input_block_clk or obj == output_block_q or obj == clock_signal_gate:
			continue

		var ports = []
		var possible_port_names = ["Input1", "Input2", "InputPort", "InputD", "InputCLK", "Output", "OutputQ", "OutputQNot"]
		
		for port_name in possible_port_names:
			var port = obj.get_node_or_null(port_name)
			if port and is_instance_valid(port):
				ports.append(port)

		for port in ports:
			var sprite = port.get_node_or_null("Sprite2D")
			if sprite and is_instance_valid(sprite):
				sprite.texture = load("res://assets/point.png")

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

			if obj == input_block_clk or obj == output_block_q:
				skip = true

			if skip:
				continue
				
			var sprite = obj.get_node_or_null("Sprite2D")
			if sprite and is_instance_valid(sprite):
				var local_mouse = sprite.to_local(mouse_pos)
				var sprite_rect = sprite.get_rect()
				if sprite_rect.has_point(local_mouse):
					var scene_file = obj.scene_file_path
					
					if scene_file.find("XORGate") != -1:
						if has_method("remove_xor_gate"):
							remove_xor_gate()
					elif scene_file.find("DTrigger") != -1:
						if has_method("remove_dtrigger_gate"):
							remove_dtrigger_gate()
					elif scene_file.find("ConstantOne") != -1:
						if has_method("remove_constant_one_gate"):
							remove_constant_one_gate()
					elif scene_file.find("ANDGate") != -1:
						if has_method("remove_and_gate"):
							remove_and_gate()
					elif scene_file.find("ORGate") != -1:
						if has_method("remove_or_gate"):
							remove_or_gate()
					elif scene_file.find("NOTGate") != -1:
						if has_method("remove_not_gate"):
							remove_not_gate()
					
					remove_wires_connected_to_gate(obj)
					obj.queue_free()
					movable_objects.remove_at(i)
					update_all_logic_objects()
					object_removed = true
					mark_level_state_dirty()
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
						break

func remove_xor_gate():
	pass
	
func remove_and_gate():
	pass
	
func remove_or_gate():
	pass
	
func remove_not_gate():
	pass
	
func remove_dtrigger_gate():
	pass
	
func remove_constant_one_gate():
	pass
	
func get_port_under_mouse():
	var mouse_pos = get_global_mouse_position()
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = mouse_pos
	query.collide_with_areas = true
	query.collision_mask = 1
	var intersects = space_state.intersect_point(query, 1)
	if intersects.size() > 0:
		var collider = intersects[0].collider
		if collider is Area2D and is_instance_valid(collider):
			if collider.collision_layer != 2:
				return collider
	return null

func handle_test_failure():
	var level_number = get_level_number()
	if level_number > 0:
		var save_system = get_node_or_null("/root/SaveSystem")
		if save_system:
			var current_failed_attempts = save_system.get_failed_attempts(level_number)
			
			save_system.increment_failed_attempts(level_number)
			
			failed_attempts_count = save_system.get_failed_attempts(level_number)
			
			hints_enabled = (failed_attempts_count >= 5)
			
			if hints_enabled:
				_update_theory_with_hint()
	else:
		super.handle_test_failure()

func _update_theory_with_hint():
	var level_number = get_level_number()
	var hint_text = _get_hint_for_level(level_number)
	
	if hint_text != "" and has_node("TopPanel"):
		var original_text = level_data.theory_text
		
		var theory_with_hint = original_text + "\n\n" + hint_text
		$TopPanel.set_theory_text(theory_with_hint)
