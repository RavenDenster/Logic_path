extends "res://scripts/levels/LevelBase.gd"

var input_block_ab  # Будет использовать InputBlock2.tscn с двумя выходами
var output_block_agtb  # A > B
var output_block_altb  # A < B  
var output_block_aeqb  # A == B

func _ready():
	level_data = preload("res://data/level_19_data.tres")  # ДОБАВЬТЕ ЭТУ СТРОЧКУ!
	
	if not level_data:
		push_error("Level data not set!")
		return
	
	wires = []
	movable_objects = []
	all_logic_objects = []
	
	if has_node("TopPanel") and $TopPanel.has_method("set_level_name"):
		$TopPanel.set_level_name(level_data.level_name)
		$TopPanel.set_theory_text(level_data.theory_text)

	setup_comparator_level()
	
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
	
	print("Comparator level ready completed successfully")

func setup_comparator_level():
	print("Setting up Comparator level with one dual-input block and three outputs")
	
	movable_objects = []
	
	# Используем один InputBlock2 вместо двух отдельных
	input_block_ab = get_node_or_null("InputBlockAB")
	
	if input_block_ab:
		input_block_ab.values_A = level_data.input_values_a.duplicate()
		input_block_ab.values_B = level_data.input_values_b.duplicate()
		movable_objects.append(input_block_ab)
		print("Comparator input block AB initialized")
	else:
		push_error("InputBlockAB not found in Comparator level!")

	output_block_agtb = get_node_or_null("OutputBlock")
	output_block_altb = get_node_or_null("OutputBlock2")
	output_block_aeqb = get_node_or_null("OutputBlock3")
	
	if output_block_agtb and output_block_altb and output_block_aeqb:
		output_block_agtb.expected = level_data.expected_agtb.duplicate()
		output_block_altb.expected = level_data.expected_altb.duplicate()
		output_block_aeqb.expected = level_data.expected_aeqb.duplicate()
		movable_objects.append(output_block_agtb)
		movable_objects.append(output_block_altb)
		movable_objects.append(output_block_aeqb)
		print("Comparator output blocks initialized")
	else:
		push_error("Output blocks not found in Comparator level!")

	test_results_panel = get_node_or_null("TestResultsPanelComparator")
	if test_results_panel:
		print("Comparator test panel found")
	else:
		push_error("TestResultsPanelComparator not found!")

	update_all_logic_objects()
	print("Movable objects: ", movable_objects.size())
	print("All logic objects: ", all_logic_objects.size())

func _on_test_pressed():
	print("=== Testing Comparator level ===")
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
	
	for i in range(4):
		print("--- Test case ", i, " ---")
		input_block_ab.current_test_index = i
		print("Inputs: A=", input_block_ab.values_A[i], " B=", input_block_ab.values_B[i])

		# Сброс всех значений
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
	else:
		print("ERROR: Test panel not found or missing update_current_outputs method!")

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
	print("=== Starting signal propagation for Comparator ===")

	# Сбрасываем все значения
	for obj in all_logic_objects:
		if obj and obj.has_method("reset_inputs"):
			obj.reset_inputs()
			
	# Сбрасываем выходные блоки
	if output_block_agtb:
		output_block_agtb.received_value = 0
	if output_block_altb:
		output_block_altb.received_value = 0
	if output_block_aeqb:
		output_block_aeqb.received_value = 0

	# Создаем карту зависимостей
	var dependencies = {}
	var dependents = {}
	var values = {}

	# Инициализируем все объекты
	for obj in all_logic_objects:
		if not obj or not is_instance_valid(obj):
			continue
		dependencies[obj] = []
		dependents[obj] = []
		values[obj] = 0

	# Строим граф зависимостей
	for wire in wires:
		if not is_wire_valid(wire): 
			continue
			
		var start_gate = wire.start_port.get_parent()
		var end_gate = wire.end_port.get_parent()
		
		if not start_gate or not is_instance_valid(start_gate) or not end_gate or not is_instance_valid(end_gate):
			continue
		
		if start_gate != end_gate:
			if not dependencies[end_gate].has(start_gate):
				dependencies[end_gate].append(start_gate)
			if not dependents[start_gate].has(end_gate):
				dependents[start_gate].append(end_gate)

	# Топологическая сортировка
	var queue = []
	var in_degree = {}
	
	for obj in all_logic_objects:
		if not obj or not is_instance_valid(obj):
			continue
		in_degree[obj] = dependencies[obj].size()
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
				in_degree[dependent] -= 1
				if in_degree[dependent] == 0:
					queue.append(dependent)

	# Обрабатываем объекты в правильном порядке
	for current in processed_order:
		if not current or not is_instance_valid(current):
			continue
			
		# Получаем значение текущего объекта
		var current_value = 0
		if current in [input_block_ab]:
			# Входные блоки - получаем текущее значение
			if current == input_block_ab:
				var port_a_value = int(input_block_ab.get_output("OutputA"))
				var port_b_value = int(input_block_ab.get_output("OutputB"))
				# Для входного блока мы не вычисляем значение, а используем его выходы
				values[current] = 0 # Это значение не используется
				
				# Передаем значения по проводам
				for wire in wires:
					if not is_wire_valid(wire): continue
					if wire.start_port.get_parent() == current:
						var end_gate = wire.end_port.get_parent()
						if end_gate and end_gate.has_method("set_input"):
							var port_num = get_gate_port_number(wire.end_port.name, get_object_type(end_gate))
							var value = port_a_value if wire.start_port.name == "OutputA" else port_b_value
							end_gate.set_input(port_num, value)
			
		elif current.has_method("get_output"):
			# Логические гейты - вычисляем выход
			current_value = int(current.get_output("Output"))
			values[current] = current_value
			
			# Передаем значение по проводам
			for wire in wires:
				if not is_wire_valid(wire): continue
				if wire.start_port.get_parent() == current:
					var end_gate = wire.end_port.get_parent()
					if end_gate and end_gate.has_method("set_input"):
						var port_num = get_gate_port_number(wire.end_port.name, get_object_type(end_gate))
						end_gate.set_input(port_num, current_value)
		
		# Выходные блоки - получаем значение из проводов
		if current in [output_block_agtb, output_block_altb, output_block_aeqb]:
			for wire in wires:
				if not is_wire_valid(wire): continue
				if wire.end_port.get_parent() == current:
					var start_gate = wire.start_port.get_parent()
					if start_gate and start_gate.has_method("get_output"):
						current.received_value = int(start_gate.get_output("Output"))

	print("=== Signal propagation complete ===")

func is_wire_valid(wire):
	return (wire and is_instance_valid(wire) and 
			wire.start_port and is_instance_valid(wire.start_port) and
			wire.end_port and is_instance_valid(wire.end_port))

func get_gates_data():
	var gates_data = []

	if input_block_ab:
		var input_block_ab_data = {
			"type": "INPUT_BLOCK_AB",
			"position": [input_block_ab.position.x, input_block_ab.position.y]
		}
		gates_data.append(input_block_ab_data)
	
	if output_block_agtb:
		var output_block_agtb_data = {
			"type": "OUTPUT_BLOCK_AGTB", 
			"position": [output_block_agtb.position.x, output_block_agtb.position.y]
		}
		gates_data.append(output_block_agtb_data)
	
	if output_block_altb:
		var output_block_altb_data = {
			"type": "OUTPUT_BLOCK_ALTB", 
			"position": [output_block_altb.position.x, output_block_altb.position.y]
		}
		gates_data.append(output_block_altb_data)
		
	if output_block_aeqb:
		var output_block_aeqb_data = {
			"type": "OUTPUT_BLOCK_AEQB", 
			"position": [output_block_aeqb.position.x, output_block_aeqb.position.y]
		}
		gates_data.append(output_block_aeqb_data)

	for obj in movable_objects:
		var skip = false

		if obj == input_block_ab:
			skip = true
		if obj == output_block_agtb or obj == output_block_altb or obj == output_block_aeqb:
			skip = true

		if skip:
			continue
			
		var scene_file = obj.scene_file_path
		var gate_type = "UNKNOWN"

		if "XNORGate" in scene_file:
			gate_type = "XNOR"
		elif "ANDGate" in scene_file:
			gate_type = "AND"
		elif "NOTGate" in scene_file:
			gate_type = "NOT"
		elif "ORGate" in scene_file:
			gate_type = "OR"
		elif "XORGate" in scene_file:
			gate_type = "XOR"
		
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
		if obj == input_block_ab:
			skip = true
		if obj == output_block_agtb or obj == output_block_altb or obj == output_block_aeqb:
			skip = true

		if skip:
			continue
			
		if is_instance_valid(obj):
			obj.queue_free()
		movable_objects.remove_at(i)
	
	update_all_logic_objects()
	reset_all_port_sprites()
	
	print("Comparator level cleared - kept Input/Output blocks, removed gates and wires")
	
func create_gate_from_data(gate_data):
	var gate_type = gate_data.get("type", "")
	var position_array = gate_data.get("position", [0, 0])
	var position = Vector2(position_array[0], position_array[1])
	
	if gate_type == "INPUT_BLOCK_AB" and input_block_ab:
		input_block_ab.position = position
		print("Restored InputBlockAB position: ", position)
		return
	elif gate_type == "OUTPUT_BLOCK_AGTB" and output_block_agtb:
		output_block_agtb.position = position
		print("Restored OutputBlockAgtb position: ", position)
		return
	elif gate_type == "OUTPUT_BLOCK_ALTB" and output_block_altb:
		output_block_altb.position = position
		print("Restored OutputBlockAltb position: ", position)
		return
	elif gate_type == "OUTPUT_BLOCK_AEQB" and output_block_aeqb:
		output_block_aeqb.position = position
		print("Restored OutputBlockAeqb position: ", position)
		return

	var gate_scene = null
	
	match gate_type:
		"AND":
			gate_scene = preload("res://scenes/gates/ANDGate.tscn")
		"NOT":
			gate_scene = preload("res://scenes/gates/NOTGate.tscn")
		"XNOR":
			gate_scene = preload("res://scenes/gates/XNORGate.tscn")
		"OR":
			gate_scene = preload("res://scenes/gates/ORGate.tscn")
		"XOR":
			gate_scene = preload("res://scenes/gates/XORGate.tscn")
	
	if gate_scene:
		var gate = gate_scene.instantiate()
		gate.position = position
		add_child(gate)
		movable_objects.append(gate)
		print("Restored gate: ", gate_type, " at ", position)

func find_port_by_name(parent_name, port_name):
	var parent = null
	
	if parent_name == "InputBlockAB" and input_block_ab:
		parent = input_block_ab
	elif parent_name == "OutputBlockAgtb" and output_block_agtb:
		parent = output_block_agtb
	elif parent_name == "OutputBlockAltb" and output_block_altb:
		parent = output_block_altb
	elif parent_name == "OutputBlockAeqb" and output_block_aeqb:
		parent = output_block_aeqb

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
	if "ANDGate" in scene_file:
		return "AND"
	elif "NOTGate" in scene_file:
		return "NOT"
	elif "XNORGate" in scene_file:
		return "XNOR"
	elif "ORGate" in scene_file:
		return "OR"
	elif "XORGate" in scene_file:
		return "XOR"

	if obj == input_block_ab:
		return "INPUT_BLOCK_AB"
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

		if obj == input_block_ab:
			ports.append(obj.get_node_or_null("OutputA"))
			ports.append(obj.get_node_or_null("OutputB"))
		elif obj == output_block_agtb or obj == output_block_altb or obj == output_block_aeqb:
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
	if input_block_ab:
		for port_name in ["OutputA", "OutputB"]:
			var port = input_block_ab.get_node_or_null(port_name)
			if port:
				var sprite = port.get_node_or_null("Sprite2D")
				if sprite:
					sprite.texture = preload("res://assets/point.png")

	if output_block_agtb:
		var input_port = output_block_agtb.get_node_or_null("InputPort")
		if input_port:
			var sprite = input_port.get_node_or_null("Sprite2D")
			if sprite:
				sprite.texture = preload("res://assets/point.png")

	if output_block_altb:
		var input_port = output_block_altb.get_node_or_null("InputPort")
		if input_port:
			var sprite = input_port.get_node_or_null("Sprite2D")
			if sprite:
				sprite.texture = preload("res://assets/point.png")
				
	if output_block_aeqb:
		var input_port = output_block_aeqb.get_node_or_null("InputPort")
		if input_port:
			var sprite = input_port.get_node_or_null("Sprite2D")
			if sprite:
				sprite.texture = preload("res://assets/point.png")

	for obj in movable_objects:
		if not obj or not is_instance_valid(obj):
			continue

		if obj == input_block_ab:
			continue
		if obj == output_block_agtb or obj == output_block_altb or obj == output_block_aeqb:
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
	
	print("Comparator level: Reset all port sprites")

func get_gate_port_number(port_name: String, gate_type: String) -> int:
	if gate_type in ["AND", "OR", "XOR", "XNOR"]:
		match port_name:
			"Input1": return 1
			"Input2": return 2
			"Output": return 1
			_: return 1
	
	if gate_type == "NOT":
		match port_name:
			"Input1": return 1
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
			var skip = false

			if obj == input_block_ab:
				skip = true
			if obj == output_block_agtb or obj == output_block_altb or obj == output_block_aeqb:
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
