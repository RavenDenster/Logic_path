extends "res://scripts/levels/LevelBase.gd"

var input_block_data
var input_block_clk
var output_block_q0
var output_block_q1  
var output_block_q2
var output_block_q3

# Храним состояние триггеров между тестами
var shift_register_state = [0, 0, 0, 0]

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

	setup_shift_register_level()
	
	temp_line = Line2D.new()
	add_child(temp_line)
	temp_line.default_color = Color("#e39e45")
	temp_line.width = 8
	temp_line.points = []
	
	_setup_top_panel_buttons()
	
	await get_tree().process_frame

	if test_results_panel and test_results_panel.has_method("load_initial_data"):
		test_results_panel.load_initial_data(
			level_data.input_data_values,
			level_data.input_clk_values,
			level_data.expected_q0,
			level_data.expected_q1,
			level_data.expected_q2,
			level_data.expected_q3
		)

	load_level_state()

	auto_save_timer = Timer.new()
	auto_save_timer.wait_time = 2.0
	auto_save_timer.one_shot = true
	auto_save_timer.timeout.connect(_on_auto_save_timeout)
	add_child(auto_save_timer)
	
	print("4-bit Shift Register level ready")

func setup_shift_register_level():
	print("Setting up 4-bit Shift Register level")
	
	movable_objects = []
	
	# Get input blocks
	input_block_data = get_node_or_null("InputBlockData")
	input_block_clk = get_node_or_null("InputBlockCLK")
	
	if input_block_data and input_block_clk:
		input_block_data.values = level_data.input_data_values.duplicate()
		input_block_clk.values = level_data.input_clk_values.duplicate()
		movable_objects.append(input_block_data)
		movable_objects.append(input_block_clk)
		print("Shift Register input blocks initialized")
	else:
		push_error("Input blocks not found in Shift Register level!")

	# Get output blocks
	output_block_q0 = get_node_or_null("OutputBlockQ0")
	output_block_q1 = get_node_or_null("OutputBlockQ1")
	output_block_q2 = get_node_or_null("OutputBlockQ2")
	output_block_q3 = get_node_or_null("OutputBlockQ3")
	
	if output_block_q0 and output_block_q1 and output_block_q2 and output_block_q3:
		output_block_q0.expected = level_data.expected_q0.duplicate()
		output_block_q1.expected = level_data.expected_q1.duplicate()
		output_block_q2.expected = level_data.expected_q2.duplicate()
		output_block_q3.expected = level_data.expected_q3.duplicate()
		movable_objects.append(output_block_q0)
		movable_objects.append(output_block_q1)
		movable_objects.append(output_block_q2)
		movable_objects.append(output_block_q3)
		print("Shift Register output blocks initialized")
	else:
		push_error("Output blocks not found in Shift Register level!")

	test_results_panel = get_node_or_null("TestResultsPanelShiftRegister")
	if test_results_panel:
		print("Shift Register test panel found")

	update_all_logic_objects()
	print("Movable objects: ", movable_objects.size())

func _on_test_pressed():
	print("=== Testing 4-bit Shift Register level ===")
	reset_all_port_sprites()

	if output_block_q0:
		output_block_q0.set_default_style()
	if output_block_q1:
		output_block_q1.set_default_style()
	if output_block_q2:
		output_block_q2.set_default_style()
	if output_block_q3:
		output_block_q3.set_default_style()
	
	# Reset shift register state
	shift_register_state = [0, 0, 0, 0]
	
	var player_q0_outputs = []
	var player_q1_outputs = []
	var player_q2_outputs = []
	var player_q3_outputs = []
	
	# Test each clock cycle sequentially
	for i in range(5):
		print("--- Clock cycle ", i, " ---")
		
		# Get current inputs
		var data_input = input_block_data.values[i]
		var clk_input = input_block_clk.values[i]
		
		print("Inputs: Data=", data_input, " CLK=", clk_input)
		
		# Process clock signal
		if clk_input == 1:  # Rising edge - update shift register
			# Shift data through the register
			shift_register_state[3] = shift_register_state[2]  # Q2 -> Q3
			shift_register_state[2] = shift_register_state[1]  # Q1 -> Q2
			shift_register_state[1] = shift_register_state[0]  # Q0 -> Q1
			shift_register_state[0] = data_input               # New data -> Q0
			print("Shift register updated: ", shift_register_state)
		
		# Set outputs based on current state
		if output_block_q0:
			output_block_q0.received_value = shift_register_state[0]
		if output_block_q1:
			output_block_q1.received_value = shift_register_state[1]
		if output_block_q2:
			output_block_q2.received_value = shift_register_state[2]
		if output_block_q3:
			output_block_q3.received_value = shift_register_state[3]
		
		# Collect results
		player_q0_outputs.append(shift_register_state[0])
		player_q1_outputs.append(shift_register_state[1])
		player_q2_outputs.append(shift_register_state[2])
		player_q3_outputs.append(shift_register_state[3])
		
		print("Q0 output: ", shift_register_state[0])
		print("Q1 output: ", shift_register_state[1])
		print("Q2 output: ", shift_register_state[2])
		print("Q3 output: ", shift_register_state[3])
	
	print("=== Test results ===")
	print("Player Q0: ", player_q0_outputs)
	print("Expected Q0: ", level_data.expected_q0)
	print("Player Q1: ", player_q1_outputs)
	print("Expected Q1: ", level_data.expected_q1)
	print("Player Q2: ", player_q2_outputs)
	print("Expected Q2: ", level_data.expected_q2)
	print("Player Q3: ", player_q3_outputs)
	print("Expected Q3: ", level_data.expected_q3)

	if test_results_panel and test_results_panel.has_method("update_current_outputs"):
		test_results_panel.update_current_outputs(player_q0_outputs, player_q1_outputs, player_q2_outputs, player_q3_outputs)
		print("Test panel updated")

	var q0_correct = player_q0_outputs == level_data.expected_q0
	var q1_correct = player_q1_outputs == level_data.expected_q1
	var q2_correct = player_q2_outputs == level_data.expected_q2
	var q3_correct = player_q3_outputs == level_data.expected_q3
	
	print("Q0 correct: ", q0_correct, " Q1 correct: ", q1_correct, " Q2 correct: ", q2_correct, " Q3 correct: ", q3_correct)
	
	if q0_correct and q1_correct and q2_correct and q3_correct:
		if output_block_q0:
			output_block_q0.set_correct_style()
		if output_block_q1:
			output_block_q1.set_correct_style()
		if output_block_q2:
			output_block_q2.set_correct_style()
		if output_block_q3:
			output_block_q3.set_correct_style()
		if not level_completed_this_session:
			save_level_progress()
			level_completed_this_session = true
		print("Level completed successfully!")
	else:
		if output_block_q0:
			output_block_q0.set_default_style()
		if output_block_q1:
			output_block_q1.set_default_style()
		if output_block_q2:
			output_block_q2.set_default_style()
		if output_block_q3:
			output_block_q3.set_default_style()
		level_completed_this_session = false
		print("Level not completed - outputs don't match")
	
	update_all_port_colors()

# Остальные методы остаются без изменений...
func get_gates_data():
	var gates_data = []

	if input_block_data:
		var input_block_data_data = {
			"type": "INPUT_BLOCK_DATA",
			"position": [input_block_data.position.x, input_block_data.position.y]
		}
		gates_data.append(input_block_data_data)
	
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
	
	if output_block_q2:
		var output_block_q2_data = {
			"type": "OUTPUT_BLOCK_Q2", 
			"position": [output_block_q2.position.x, output_block_q2.position.y]
		}
		gates_data.append(output_block_q2_data)
	
	if output_block_q3:
		var output_block_q3_data = {
			"type": "OUTPUT_BLOCK_Q3", 
			"position": [output_block_q3.position.x, output_block_q3.position.y]
		}
		gates_data.append(output_block_q3_data)

	for obj in movable_objects:
		var skip = false

		if obj == input_block_data or obj == input_block_clk:
			skip = true
		if obj == output_block_q0 or obj == output_block_q1 or obj == output_block_q2 or obj == output_block_q3:
			skip = true

		if skip:
			continue
			
		var scene_file = obj.scene_file_path
		var gate_type = "UNKNOWN"

		if "DFlipFlop" in scene_file:
			gate_type = "DFLIPFLOP"
		elif "CLKGate" in scene_file:
			gate_type = "CLK"
		
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
		if obj == input_block_data or obj == input_block_clk:
			skip = true
		if obj == output_block_q0 or obj == output_block_q1 or obj == output_block_q2 or obj == output_block_q3:
			skip = true

		if skip:
			continue
			
		if is_instance_valid(obj):
			obj.queue_free()
		movable_objects.remove_at(i)
	
	update_all_logic_objects()
	reset_all_port_sprites()
	
	print("Shift Register level cleared - kept Input/Output blocks, removed gates and wires")
	
func create_gate_from_data(gate_data):
	var gate_type = gate_data.get("type", "")
	var position_array = gate_data.get("position", [0, 0])
	var position = Vector2(position_array[0], position_array[1])
	
	if gate_type == "INPUT_BLOCK_DATA" and input_block_data:
		input_block_data.position = position
		print("Restored InputBlockData position: ", position)
		return
	elif gate_type == "INPUT_BLOCK_CLK" and input_block_clk:
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
	elif gate_type == "OUTPUT_BLOCK_Q2" and output_block_q2:
		output_block_q2.position = position
		print("Restored OutputBlockQ2 position: ", position)
		return
	elif gate_type == "OUTPUT_BLOCK_Q3" and output_block_q3:
		output_block_q3.position = position
		print("Restored OutputBlockQ3 position: ", position)
		return

	var gate_scene = null
	
	match gate_type:
		"DFLIPFLOP":
			gate_scene = load("res://scenes/gates/DFlipFlop.tscn")
		"CLK":
			gate_scene = load("res://scenes/gates/CLKGate.tscn")
	
	if gate_scene:
		var gate = gate_scene.instantiate()
		gate.position = position
		add_child(gate)
		movable_objects.append(gate)
		print("Restored gate: ", gate_type, " at ", position)

func find_port_by_name(parent_name, port_name):
	var parent = null
	
	if parent_name == "InputBlockData" and input_block_data:
		parent = input_block_data
	elif parent_name == "InputBlockCLK" and input_block_clk:
		parent = input_block_clk
	elif parent_name == "OutputBlockQ0" and output_block_q0:
		parent = output_block_q0
	elif parent_name == "OutputBlockQ1" and output_block_q1:
		parent = output_block_q1
	elif parent_name == "OutputBlockQ2" and output_block_q2:
		parent = output_block_q2
	elif parent_name == "OutputBlockQ3" and output_block_q3:
		parent = output_block_q3

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
	
	if obj.is_in_group("DFlipFlop"):
		return "DFLIPFLOP"
	if obj.is_in_group("CLKGate"):
		return "CLK"
	
	var scene_file = obj.scene_file_path
	if "DFlipFlop" in scene_file:
		return "DFLIPFLOP"
	elif "CLKGate" in scene_file:
		return "CLK"

	if obj == input_block_data:
		return "INPUT_BLOCK_DATA"
	elif obj == input_block_clk:
		return "INPUT_BLOCK_CLK"
	elif obj == output_block_q0:
		return "OUTPUT_BLOCK_Q0"
	elif obj == output_block_q1:
		return "OUTPUT_BLOCK_Q1"
	elif obj == output_block_q2:
		return "OUTPUT_BLOCK_Q2"
	elif obj == output_block_q3:
		return "OUTPUT_BLOCK_Q3"
	
	return "UNKNOWN"

func find_port_near_position(position, max_distance = 50.0):
	var closest_port = null
	var closest_distance = max_distance
	
	for obj in movable_objects:
		if not obj or not is_instance_valid(obj):
			continue
			
		var ports = []

		if obj == input_block_data or obj == input_block_clk:
			var output = obj.get_node_or_null("Output")
			if output: ports.append(output)
		elif obj == output_block_q0 or obj == output_block_q1 or obj == output_block_q2 or obj == output_block_q3:
			var input_port = obj.get_node_or_null("InputPort")
			if input_port: ports.append(input_port)
		else:
			var input1 = obj.get_node_or_null("Input1")
			var input2 = obj.get_node_or_null("Input2")
			var input_port = obj.get_node_or_null("InputPort")
			var clk_port = obj.get_node_or_null("CLK")
			var output = obj.get_node_or_null("Output")
			
			if input1: ports.append(input1)
			if input2: ports.append(input2)
			if input_port: ports.append(input_port)
			if clk_port: ports.append(clk_port)
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
	if input_block_data:
		var output_port = input_block_data.get_node_or_null("Output")
		if output_port and is_instance_valid(output_port):
			var sprite = output_port.get_node_or_null("Sprite2D")
			if sprite and is_instance_valid(sprite):
				sprite.texture = load("res://assets/point.png")

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

	if output_block_q2:
		var input_port = output_block_q2.get_node_or_null("InputPort")
		if input_port and is_instance_valid(input_port):
			var sprite = input_port.get_node_or_null("Sprite2D")
			if sprite and is_instance_valid(sprite):
				sprite.texture = load("res://assets/point.png")

	if output_block_q3:
		var input_port = output_block_q3.get_node_or_null("InputPort")
		if input_port and is_instance_valid(input_port):
			var sprite = input_port.get_node_or_null("Sprite2D")
			if sprite and is_instance_valid(sprite):
				sprite.texture = load("res://assets/point.png")

	for obj in movable_objects:
		if not obj or not is_instance_valid(obj):
			continue

		if obj == input_block_data or obj == input_block_clk:
			continue
		if obj == output_block_q0 or obj == output_block_q1 or obj == output_block_q2 or obj == output_block_q3:
			continue

		var ports = []
		var possible_port_names = ["Input1", "Input2", "InputPort", "CLK", "Output"]
		
		for port_name in possible_port_names:
			var port = obj.get_node_or_null(port_name)
			if port and is_instance_valid(port):
				ports.append(port)

		for port in ports:
			var sprite = port.get_node_or_null("Sprite2D")
			if sprite and is_instance_valid(sprite):
				sprite.texture = load("res://assets/point.png")
	
	print("Shift Register level: Reset all port sprites")

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

			if obj == input_block_data or obj == input_block_clk:
				skip = true
			if obj == output_block_q0 or obj == output_block_q1 or obj == output_block_q2 or obj == output_block_q3:
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
