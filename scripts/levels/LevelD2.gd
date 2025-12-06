extends "res://scripts/levels/LevelBase.gd"

var input_block_d
var input_block_clk
var output_block_q

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

	setup_d_trigger_level()
	
	temp_line = Line2D.new()
	add_child(temp_line)
	temp_line.default_color = Color("#e39e45")
	temp_line.width = 8
	temp_line.points = []
	
	_setup_top_panel_buttons()
	
	await get_tree().process_frame

	if test_results_panel and test_results_panel.has_method("load_initial_data"):
		test_results_panel.load_initial_data(
			level_data.input_values_d,
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
			hints_enabled = (failed_attempts_count >= 10)
			print("Failed attempts for level ", level_number, ": ", failed_attempts_count, ", hints enabled: ", hints_enabled)
	
	print("D Trigger level ready completed successfully")

func setup_d_trigger_level():
	print("Setting up D Trigger level with D and CLK inputs and Q output")
	
	movable_objects = []
	
	# Get input blocks
	input_block_d = get_node_or_null("InputBlockD")
	input_block_clk = get_node_or_null("InputBlockCLK")
	
	if input_block_d and input_block_clk:
		input_block_d.values = level_data.input_values_d.duplicate()
		input_block_clk.values = level_data.input_values_clk.duplicate()
		
		# Устанавливаем метки для подсветки
		input_block_d.input_label = "Input D"
		input_block_clk.input_label = "Input CLK"
		
		movable_objects.append(input_block_d)
		movable_objects.append(input_block_clk)
		print("D Trigger input blocks initialized")
	else:
		push_error("Input blocks not found in D Trigger level!")

	# Get output block
	output_block_q = get_node_or_null("OutputBlockQ")
	
	if output_block_q:
		output_block_q.expected = level_data.expected_q.duplicate()
		
		# УБИРАЕМ проблемную строку - в OutputBlockQ нет свойства output_type
		# output_block_q.output_type = "Q"
		
		movable_objects.append(output_block_q)
		print("D Trigger output block initialized")
	else:
		push_error("Output block not found in D Trigger level!")

	test_results_panel = get_node_or_null("TestResultsPanelDTrigger")
	if test_results_panel:
		print("D Trigger test panel found")

		# Устанавливаем test_results_panel для всех блоков
		if input_block_d:
			input_block_d.test_results_panel = test_results_panel
		if input_block_clk:
			input_block_clk.test_results_panel = test_results_panel
		if output_block_q:
			output_block_q.test_results_panel = test_results_panel

	update_all_logic_objects()
	print("Movable objects: ", movable_objects.size())
	print("All logic objects: ", all_logic_objects.size())

func get_wires_data():
	var wires_data = []

	for wire in wires:
		if not wire or not is_instance_valid(wire):
			continue
			
		var start_port = wire.start_port
		var end_port = wire.end_port
		
		if not start_port or not is_instance_valid(start_port) or not end_port or not is_instance_valid(end_port):
			continue
			
		var start_parent = start_port.get_parent()
		var end_parent = end_port.get_parent()
		
		if not start_parent or not is_instance_valid(start_parent) or not end_parent or not is_instance_valid(end_parent):
			continue
		
		# Получаем тип и положение родительских объектов
		var start_data = get_port_data(start_parent, start_port)
		var end_data = get_port_data(end_parent, end_port)
		
		if start_data and end_data:
			var wire_data = {
				"start": start_data,
				"end": end_data
			}
			wires_data.append(wire_data)
	
	print("Saving ", wires_data.size(), " wires with new format")
	return wires_data

func get_port_data(parent, port):
	if not parent or not port:
		return null
	
	var parent_type = get_object_type(parent)
	var port_name = port.name
	
	# Для специальных блоков (Input/Output) используем их фиксированные имена
	var parent_name = ""
	if parent == input_block_d:
		parent_name = "InputBlockD"
	elif parent == input_block_clk:
		parent_name = "InputBlockCLK"
	elif parent == output_block_q:
		parent_name = "OutputBlockQ"
	else:
		# Для гейтов генерируем уникальный идентификатор на основе типа и позиции
		parent_name = "%s_%d_%d" % [parent_type, int(parent.position.x), int(parent.position.y)]
	
	return {
		"parent_type": parent_type,
		"parent_name": parent_name,
		"parent_position": [parent.position.x, parent.position.y],
		"port_name": port_name
	}

func create_wire_from_data(wire_data):
	var start_data = wire_data.get("start", {})
	var end_data = wire_data.get("end", {})
	
	if not start_data or not end_data:
		print("WARNING: Invalid wire data")
		return
	
	var start_port = find_port_by_data(start_data)
	var end_port = find_port_by_data(end_data)
	
	if start_port and end_port and is_instance_valid(start_port) and is_instance_valid(end_port):
		var wire = load("res://scenes/components/Wire.tscn").instantiate()
		wire.connect_ports(start_port, end_port)
		add_child(wire)
		wires.append(wire)
		print("Successfully restored wire: ", start_data.get("port_name", ""), " -> ", end_data.get("port_name", ""))
	else:
		print("WARNING: Could not restore wire - ports not found")

func find_port_by_data(port_data):
	var parent_type = port_data.get("parent_type", "")
	var parent_name = port_data.get("parent_name", "")
	var position_array = port_data.get("parent_position", [0, 0])
	var port_name = port_data.get("port_name", "")
	var position = Vector2(position_array[0], position_array[1])
	
	# Сначала пытаемся найти по фиксированным именам
	var parent = null
	
	if parent_name == "InputBlockD" and input_block_d:
		parent = input_block_d
	elif parent_name == "InputBlockCLK" and input_block_clk:
		parent = input_block_clk
	elif parent_name == "OutputBlockQ" and output_block_q:
		parent = output_block_q
	else:
		# Ищем среди всех объектов по типу и позиции
		for obj in movable_objects:
			if not obj or not is_instance_valid(obj):
				continue
				
			var obj_type = get_object_type(obj)
			if obj_type == parent_type and obj.position.distance_to(position) < 10.0:
				parent = obj
				break
	
	if not parent:
		print("Parent not found for type: ", parent_type, " at position: ", position)
		return null
	
	# Ищем порт сначала по сохраненному имени
	var port = null
	
	# Сначала пробуем найти порт по exact имени
	if port_name:
		var port_node_name = str(port_name)
		port = parent.get_node_or_null(port_node_name)
	
	# Если не нашли, пробуем альтернативные имена в зависимости от типа родителя
	if not port:
		if parent_type == "INPUT_BLOCK_D" or parent_type == "INPUT_BLOCK_CLK":
			# Пробуем различные варианты имен для выходных портов входных блоков
			port = parent.get_node_or_null("Output") or parent.get_node_or_null("output") or parent.get_node_or_null("Out")
		elif parent_type == "OUTPUT_BLOCK_Q":
			# Пробуем различные варианты имен для входных портов выходных блоков
			port = parent.get_node_or_null("InputPort") or parent.get_node_or_null("Input") or parent.get_node_or_null("In")
		else:
			# Для гейтов
			if port_name == "Input" or port_name == "Input1" or port_name == "D":
				port = parent.get_node_or_null("D") or parent.get_node_or_null("Input") or parent.get_node_or_null("Input1")
			elif port_name == "Input2" or port_name == "Enable":
				port = parent.get_node_or_null("Enable") or parent.get_node_or_null("Input2")
			elif port_name == "Output":
				port = parent.get_node_or_null("Output")
	
	if not port:
		print("Port not found: ", parent_name, "/", port_name, " for parent type: ", parent_type)
	
	return port

func create_gate_from_data(gate_data):
	var gate_type = gate_data.get("type", "")
	var position_array = gate_data.get("position", [0, 0])
	var position = Vector2(position_array[0], position_array[1])
	
	# Обработка специальных блоков
	if gate_type == "INPUT_BLOCK_D" and input_block_d:
		input_block_d.position = position
		print("Restored InputBlockD position: ", position)
		return
	elif gate_type == "INPUT_BLOCK_CLK" and input_block_clk:
		input_block_clk.position = position
		print("Restored InputBlockCLK position: ", position)
		return
	elif gate_type == "OUTPUT_BLOCK_Q" and output_block_q:
		output_block_q.position = position
		print("Restored OutputBlockQ position: ", position)
		return

	# Обработка обычных гейтов
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
		"NAND":
			gate_scene = load("res://scenes/gates/base_logic_el/NANDGate.tscn")
		"NOR":
			gate_scene = load("res://scenes/gates/base_logic_el/NORGate.tscn")
		"XNOR":
			gate_scene = load("res://scenes/gates/base_logic_el/XNORGate.tscn")
		"IMPLICATION":
			gate_scene = load("res://scenes/gates/base_logic_el/ImplicationGate.tscn")
		"SEL0":
			gate_scene = load("res://scenes/gates/Sel0.tscn")
		"SEL1":
			gate_scene = load("res://scenes/gates/Sel1.tscn")
		"D_LATCH":
			gate_scene = load("res://scenes/gates/DLatchGate.tscn")
	
	if gate_scene:
		var gate = gate_scene.instantiate()
		gate.position = position
		add_child(gate)
		movable_objects.append(gate)
		
		# Устанавливаем имя, которое будет использоваться для восстановления проводов
		gate.set_meta("gate_type", gate_type)
		gate.set_meta("original_position", position)
		
		print("Restored gate: ", gate_type, " at ", position, " with name: ", gate.name)

func _on_test_pressed():
	print("=== Testing D Trigger level ===")
	var level_number = get_level_number()
	if level_number > 0:
		var save_system = get_node_or_null("/root/SaveSystem")
		if save_system and save_system.has_method("record_level_attempt"):
			save_system.record_level_attempt(level_number)
	
	reset_all_port_sprites()

	if output_block_q:
		output_block_q.set_default_style()
	
	var player_q_outputs = []
	
	# Полностью сбрасываем состояние всех DLatchGate перед началом тестирования
	for obj in all_logic_objects:
		if obj and obj.has_method("reset_state"):
			obj.reset_state()
		elif obj and obj.has_method("reset_inputs"):
			obj.reset_inputs()
	
	# Для каждого тестового случая
	for i in range(8):
		print("--- Test case ", i, " ---")
		
		# Устанавливаем текущие значения входов
		input_block_d.current_test_index = i
		input_block_clk.current_test_index = i
		
		print("Inputs: D=", input_block_d.values[i], " CLK=", input_block_clk.values[i])

		# НЕ сбрасываем входы DLatchGate для этого теста
		# Только комбинационные элементы
		for obj in all_logic_objects:
			if obj and obj.has_method("reset_inputs") and not obj.has_method("reset_state"):
				obj.reset_inputs()
		
		if output_block_q:
			output_block_q.received_value = 0
		
		# Пропускаем сигналы через созданную схему
		propagate_signals()
		
		# Получаем значение с выхода схемы
		if output_block_q:
			player_q_outputs.append(int(output_block_q.received_value))
			print("Q output: ", output_block_q.received_value)
		else:
			player_q_outputs.append(0)
	
	print("=== Test results ===")
	print("Player Q: ", player_q_outputs)
	print("Expected Q: ", level_data.expected_q)

	if test_results_panel and test_results_panel.has_method("update_current_outputs"):
		test_results_panel.update_current_outputs(player_q_outputs)
		print("Test panel updated")

	var q_correct = player_q_outputs == level_data.expected_q
	
	print("Q correct: ", q_correct)
	
	if q_correct:
		if output_block_q:
			output_block_q.set_correct_style()
		if not level_completed_this_session:
			save_level_progress()
			level_completed_this_session = true
		handle_test_success()
		print("Level completed successfully!")
	else:
		if output_block_q:
			output_block_q.set_default_style()
		level_completed_this_session = false
		handle_test_failure()
		print("Level not completed - outputs don't match")
	
	update_all_port_colors()
	
func propagate_signals():
	print("=== Starting signal propagation for D Trigger ===")

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
			
		if current in [input_block_d, input_block_clk]:
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
						if end_port_name == "Input2" or end_port_name == "Enable":
							port_num = 2
						elif end_port_name == "Input" or end_port_name == "Input1" or end_port_name == "D":
							port_num = 1
						elif end_port_name == "InputPort":
							port_num = 1
						
						end_gate.set_input(port_num, output_value)

		elif current.has_method("get_output") and current != output_block_q:
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
						if end_port_name == "Input2" or end_port_name == "Enable":
							port_num = 2
						elif end_port_name == "Input" or end_port_name == "Input1" or end_port_name == "D":
							port_num = 1
						elif end_port_name == "InputPort":
							port_num = 1
						
						end_gate.set_input(port_num, output_value)
	
	print("=== Signal propagation complete ===")

func get_gates_data():
	var gates_data = []

	if input_block_d:
		var input_block_d_data = {
			"type": "INPUT_BLOCK_D",
			"position": [input_block_d.position.x, input_block_d.position.y]
		}
		gates_data.append(input_block_d_data)
	
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

	for obj in movable_objects:
		var skip = false

		if obj == input_block_d or obj == input_block_clk:
			skip = true
		if obj == output_block_q:
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
		elif "DLatchGate" in scene_file:
			gate_type = "D_LATCH"
		
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
		if obj == input_block_d or obj == input_block_clk:
			skip = true
		if obj == output_block_q:
			skip = true

		if skip:
			continue
			
		if is_instance_valid(obj):
			obj.queue_free()
		movable_objects.remove_at(i)
	
	update_all_logic_objects()
	reset_all_port_sprites()
	
	print("D Trigger level cleared - kept Input/Output blocks, removed gates and wires")

func find_port_by_name(parent_name, port_name):
	var parent = null
	
	if parent_name == "InputBlockD" and input_block_d:
		parent = input_block_d
	elif parent_name == "InputBlockCLK" and input_block_clk:
		parent = input_block_clk
	elif parent_name == "OutputBlockQ" and output_block_q:
		parent = output_block_q

	if not parent:
		for obj in movable_objects:
			if obj and obj.name == parent_name:
				parent = obj
				break
	
	if not parent:
		print("Parent not found: ", parent_name)
		return null

	# Преобразуем port_name в строку
	var port_node_name = str(port_name)
	var port = parent.get_node_or_null(port_node_name)
	
	if not port:
		print("Port not found: ", parent_name, "/", port_node_name)
	
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
	elif "DLatchGate" in scene_file:
		return "D_LATCH"

	if obj == input_block_d:
		return "INPUT_BLOCK_D"
	elif obj == input_block_clk:
		return "INPUT_BLOCK_CLK"
	elif obj == output_block_q:
		return "OUTPUT_BLOCK_Q"
	
	return "UNKNOWN"

func find_port_near_position(position, max_distance = 50.0):
	var closest_port = null
	var closest_distance = max_distance
	
	for obj in movable_objects:
		if not obj or not is_instance_valid(obj):
			continue
			
		var ports = []

		if obj == input_block_d or obj == input_block_clk:
			var output = obj.get_node_or_null("Output")  # Исправлено с "output" на "Output"
			if output: ports.append(output)
		elif obj == output_block_q:
			var input_port = obj.get_node_or_null("InputPort")
			if input_port: ports.append(input_port)
		else:
			var input1 = obj.get_node_or_null("Input")
			var enable = obj.get_node_or_null("Enable")
			var d_port = obj.get_node_or_null("D")
			var output = obj.get_node_or_null("Output")  # Исправлено с "output" на "Output"
			
			if input1: ports.append(input1)
			if enable: ports.append(enable)
			if d_port: ports.append(d_port)
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
	if input_block_d:
		var output_port = input_block_d.get_node_or_null("output")  # Исправлено с "output" на "Output"
		if output_port and is_instance_valid(output_port):
			var sprite = output_port.get_node_or_null("Sprite2D")
			if sprite and is_instance_valid(sprite):
				sprite.texture = load("res://assets/point.png")

	if input_block_clk:
		var output_port = input_block_clk.get_node_or_null("output")  # Исправлено с "output" на "Output"
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

	for obj in movable_objects:
		if not obj or not is_instance_valid(obj):
			continue

		if obj == input_block_d or obj == input_block_clk:
			continue
		if obj == output_block_q:
			continue

		var ports = []
		var possible_port_names = ["Input", "Enable", "D", "Output"]
		
		for port_name in possible_port_names:
			var port = obj.get_node_or_null(port_name)
			if port and is_instance_valid(port):
				ports.append(port)

		for port in ports:
			var sprite = port.get_node_or_null("Sprite2D")
			if sprite and is_instance_valid(sprite):
				sprite.texture = load("res://assets/point.png")
	
	print("D Trigger level: Reset all port sprites")

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

			if obj == input_block_d or obj == input_block_clk:
				skip = true
			if obj == output_block_q:
				skip = true

			if skip:
				continue
				
			var sprite = obj.get_node_or_null("Sprite2D")
			if sprite and is_instance_valid(sprite):
				var local_mouse = sprite.to_local(mouse_pos)
				var sprite_rect = sprite.get_rect()
				if sprite_rect.has_point(local_mouse):
					var scene_file = obj.scene_file_path
					print("Removing object with scene file: ", scene_file)
					
					if scene_file.find("DLatchGate") != -1:
						if has_method("remove_dlatch_gate"):
							remove_dlatch_gate()
						else:
							print("WARNING: remove_dlatch_gate method not found")
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

func remove_and_gate():
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

func remove_or_gate():
	pass

func remove_not_gate():
	pass
	
func remove_dlatch_gate():
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
			if collider.collision_layer != 2:
				return collider
	return null
