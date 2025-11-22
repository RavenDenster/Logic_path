# LevelD.gd
extends "res://scripts/levels/LevelBase.gd"

var input_block_d
var input_block_enable
var output_block_q
var latch_state = 0  # Состояние защелки между тестами
var feedback_wire_exists = false

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

	setup_d_latch_level()
	
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
			level_data.input_values_enable,
			level_data.expected_q
		)

	load_level_state()

	auto_save_timer = Timer.new()
	auto_save_timer.wait_time = 2.0
	auto_save_timer.one_shot = true
	auto_save_timer.timeout.connect(_on_auto_save_timeout)
	add_child(auto_save_timer)
	
	print("D Latch level ready completed successfully")

func setup_d_latch_level():
	print("Setting up D Latch level with two inputs and one output")
	
	movable_objects = []
	
	# Get input blocks
	input_block_d = get_node_or_null("InputBlockD")
	input_block_enable = get_node_or_null("InputBlockEnable")
	
	if input_block_d and input_block_enable:
		input_block_d.values = level_data.input_values_d.duplicate()
		input_block_enable.values = level_data.input_values_enable.duplicate()
		movable_objects.append(input_block_d)
		movable_objects.append(input_block_enable)
		print("D Latch input blocks initialized")
	else:
		push_error("Input blocks not found in D Latch level!")

	# Get output block
	output_block_q = get_node_or_null("OutputBlockQ")
	
	if output_block_q:
		output_block_q.expected = level_data.expected_q.duplicate()
		movable_objects.append(output_block_q)
		print("D Latch output block initialized")
	else:
		push_error("Output block not found in D Latch level!")

	test_results_panel = get_node_or_null("TestResultsPanelDLatch")
	if test_results_panel:
		print("D Latch test panel found")

	update_all_logic_objects()
	print("Movable objects: ", movable_objects.size())
	print("All logic objects: ", all_logic_objects.size())

func _on_test_pressed():
	print("=== Testing D Latch level ===")
	reset_all_port_sprites()

	if output_block_q:
		output_block_q.set_default_style()
	
	var player_q_outputs = []
	
	# Сбрасываем состояние защелки перед началом тестирования
	latch_state = 0
	
	# Проверяем наличие обратной связи
	check_feedback_wire()
	print("Feedback wire exists: ", feedback_wire_exists)
	
	for i in range(8):
		print("--- Test case ", i, " ---")
		input_block_d.current_test_index = i
		input_block_enable.current_test_index = i
		print("Inputs: D=", input_block_d.values[i], " Enable=", input_block_enable.values[i])

		# Сбрасываем только обычные вентили
		for obj in all_logic_objects:
			if obj and obj.has_method("reset_inputs") and obj != output_block_q:
				obj.reset_inputs()

		# Устанавливаем начальное состояние для выходного блока
		if output_block_q:
			output_block_q.received_value = latch_state

		# Выполняем несколько проходов для стабилизации схемы с обратной связью
		var stable = false
		var previous_state = latch_state
		var iterations = 0
		
		while not stable and iterations < 20:  # Увеличиваем количество итераций
			propagate_signals_with_feedback()
			if output_block_q:
				var new_state = output_block_q.received_value
				if new_state == previous_state:
					stable = true
					print("Stabilized at iteration ", iterations, " with value: ", new_state)
				else:
					previous_state = new_state
					# Обновляем latch_state для следующей итерации
					latch_state = new_state
					print("Iteration ", iterations, ": state changed to ", new_state)
			iterations += 1
			
			# Если достигли максимального количества итераций, принудительно стабилизируем
			if iterations >= 20:
				print("Reached max iterations, forcing stabilization")
				stable = true
		
		# Получаем новое состояние
		if output_block_q:
			latch_state = output_block_q.received_value
			player_q_outputs.append(int(latch_state))
			print("Final Q output: ", latch_state)
		else:
			player_q_outputs.append(0)
			latch_state = 0
	
	print("=== Test results ===")
	print("Player Q: ", player_q_outputs)
	
	# Используем исправленные ожидаемые значения для D-защелки
	var expected_output = [0, 0, 0, 1, 1, 1, 0, 1]
	print("Expected Q: ", expected_output)

	if test_results_panel and test_results_panel.has_method("update_current_outputs"):
		test_results_panel.update_current_outputs(player_q_outputs)
		print("Test panel updated")

	var q_correct = player_q_outputs == expected_output
	
	print("Q correct: ", q_correct)
	
	if q_correct:
		if output_block_q:
			output_block_q.set_correct_style()
		if not level_completed_this_session:
			save_level_progress()
			level_completed_this_session = true
		print("Level completed successfully!")
	else:
		if output_block_q:
			output_block_q.set_default_style()
		level_completed_this_session = false
		print("Level not completed - outputs don't match")
	
	update_all_port_colors()

func check_feedback_wire():
	# Проверяем наличие обратной связи от OutputBlockQ к любому AND вентилю
	feedback_wire_exists = false
	for wire in wires:
		if not wire or not is_instance_valid(wire):
			continue
		if not wire.start_port or not is_instance_valid(wire.start_port):
			continue
		if not wire.end_port or not is_instance_valid(wire.end_port):
			continue
			
		var start_gate = wire.start_port.get_parent()
		var end_gate = wire.end_port.get_parent()
		
		# Если провод идет от OutputBlockQ к AND вентилю - это обратная связь
		if start_gate == output_block_q and "AND" in str(end_gate):
			feedback_wire_exists = true
			print("Found feedback wire from OutputBlockQ to ", end_gate.name)
			break

func propagate_signals_with_feedback():
	# Специальная версия propagate_signals для обработки обратной связи
	
	# Сначала сбрасываем все вентили (кроме выходного блока)
	for obj in all_logic_objects:
		if obj and obj.has_method("reset_inputs") and obj != output_block_q:
			obj.reset_inputs()

	# Получаем значения входов
	var d_value = 0
	var e_value = 0
	if input_block_d:
		d_value = input_block_d.get_output("Output")
	if input_block_enable:
		e_value = input_block_enable.get_output("Output")

	# Распространяем сигналы по проводам с учетом обратной связи
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
		
		# Если стартовый gate - входной блок D
		if start_gate == input_block_d:
			var end_port_name = wire.end_port.name
			if end_gate.has_method("set_input"):
				var port_num = get_port_number(end_port_name)
				end_gate.set_input(port_num, d_value)
				print("Set input ", port_num, " of ", end_gate.name, " to D value: ", d_value)
			
		# Если стартовый gate - входной блок Enable
		elif start_gate == input_block_enable:
			var end_port_name = wire.end_port.name
			if end_gate.has_method("set_input"):
				var port_num = get_port_number(end_port_name)
				end_gate.set_input(port_num, e_value)
				print("Set input ", port_num, " of ", end_gate.name, " to Enable value: ", e_value)
			
		# Если стартовый gate - выходной блок (обратная связь)
		elif start_gate == output_block_q:
			var end_port_name = wire.end_port.name
			if end_gate.has_method("set_input"):
				var port_num = get_port_number(end_port_name)
				end_gate.set_input(port_num, latch_state)
				print("Set input ", port_num, " of ", end_gate.name, " to feedback value: ", latch_state)
			
		# Обычные gates
		elif start_gate.has_method("get_output"):
			var output_value = int(start_gate.get_output("Output"))
			var end_port_name = wire.end_port.name
			if end_gate.has_method("set_input"):
				var port_num = get_port_number(end_port_name)
				end_gate.set_input(port_num, output_value)
				print("Set input ", port_num, " of ", end_gate.name, " to gate output: ", output_value)
	
	# В конце обновляем выходной блок на основе OR вентиля
	update_output_from_or()

func update_output_from_or():
	# Находим OR вентиль, подключенный к выходному блоку
	for wire in wires:
		if not wire or not is_instance_valid(wire):
			continue
		if not wire.start_port or not is_instance_valid(wire.start_port):
			continue
		if not wire.end_port or not is_instance_valid(wire.end_port):
			continue
			
		var end_gate = wire.end_port.get_parent()
		if end_gate == output_block_q:
			var start_gate = wire.start_port.get_parent()
			if start_gate and start_gate.has_method("get_output"):
				var or_value = int(start_gate.get_output("Output"))
				if output_block_q:
					output_block_q.received_value = or_value
					print("Updated output from OR: ", or_value)
				break

func get_port_number(port_name):
	match port_name:
		"Input1", "InputPort", "Input":
			return 1
		"Input2":
			return 2
		_:
			return 1

func get_gates_data():
	var gates_data = []

	if input_block_d:
		var input_block_d_data = {
			"type": "INPUT_BLOCK_D",
			"position": [input_block_d.position.x, input_block_d.position.y]
		}
		gates_data.append(input_block_d_data)
	
	if input_block_enable:
		var input_block_enable_data = {
			"type": "INPUT_BLOCK_ENABLE",
			"position": [input_block_enable.position.x, input_block_enable.position.y]
		}
		gates_data.append(input_block_enable_data)
	
	if output_block_q:
		var output_block_q_data = {
			"type": "OUTPUT_BLOCK_Q", 
			"position": [output_block_q.position.x, output_block_q.position.y]
		}
		gates_data.append(output_block_q_data)

	for obj in movable_objects:
		var skip = false

		if obj == input_block_d or obj == input_block_enable:
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
		if obj == input_block_d or obj == input_block_enable:
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
	
	print("D Latch level cleared - kept Input/Output blocks, removed gates and wires")
	
func create_gate_from_data(gate_data):
	var gate_type = gate_data.get("type", "")
	var position_array = gate_data.get("position", [0, 0])
	var position = Vector2(position_array[0], position_array[1])
	
	if gate_type == "INPUT_BLOCK_D" and input_block_d:
		input_block_d.position = position
		print("Restored InputBlockD position: ", position)
		return
	elif gate_type == "INPUT_BLOCK_ENABLE" and input_block_enable:
		input_block_enable.position = position
		print("Restored InputBlockEnable position: ", position)
		return
	elif gate_type == "OUTPUT_BLOCK_Q" and output_block_q:
		output_block_q.position = position
		print("Restored OutputBlockQ position: ", position)
		return

	var gate_scene = null
	
	match gate_type:
		"AND":
			gate_scene = preload("res://scenes/gates/base_logic_el/ANDGate.tscn")
		"OR":
			gate_scene = preload("res://scenes/gates/base_logic_el/ORGate.tscn")
		"NOT":
			gate_scene = preload("res://scenes/gates/base_logic_el/NOTGate.tscn")
		"XOR":
			gate_scene = preload("res://scenes/gates/base_logic_el/XORGate.tscn")
		"NAND":
			gate_scene = preload("res://scenes/gates/base_logic_el/NANDGate.tscn")
		"NOR":
			gate_scene = preload("res://scenes/gates/base_logic_el/NORGate.tscn")
		"XNOR":
			gate_scene = preload("res://scenes/gates/base_logic_el/XNORGate.tscn")
		"IMPLICATION":
			gate_scene = preload("res://scenes/gates/base_logic_el/ImplicationGate.tscn")
	
	if gate_scene:
		var gate = gate_scene.instantiate()
		gate.position = position
		add_child(gate)
		movable_objects.append(gate)
		print("Restored gate: ", gate_type, " at ", position)

func find_port_by_name(parent_name, port_name):
	var parent = null
	
	if parent_name == "InputBlockD" and input_block_d:
		parent = input_block_d
	elif parent_name == "InputBlockEnable" and input_block_enable:
		parent = input_block_enable
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

	if obj == input_block_d:
		return "INPUT_BLOCK_D"
	elif obj == input_block_enable:
		return "INPUT_BLOCK_ENABLE"
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

		if obj == input_block_d or obj == input_block_enable:
			var output = obj.get_node_or_null("Output")
			if output: ports.append(output)
		elif obj == output_block_q:
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
	if input_block_d:
		var output_port = input_block_d.get_node_or_null("Output")
		if output_port and is_instance_valid(output_port):
			var sprite = output_port.get_node_or_null("Sprite2D")
			if sprite and is_instance_valid(sprite):
				sprite.texture = preload("res://assets/point.png")

	if input_block_enable:
		var output_port = input_block_enable.get_node_or_null("Output")
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

	for obj in movable_objects:
		if not obj or not is_instance_valid(obj):
			continue

		if obj == input_block_d or obj == input_block_enable:
			continue
		if obj == output_block_q:
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
	
	print("D Latch level: Reset all port sprites")

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
					
					# Проверяем наличие обратной связи после добавления провода
					check_feedback_wire()
					
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

			if obj == input_block_d or obj == input_block_enable:
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

func remove_wire(wire):
	if wire in wires:
		wires.erase(wire)
	if is_instance_valid(wire):
		wire.queue_free()
	
	# Проверяем наличие обратной связи после удаления провода
	check_feedback_wire()
	
	update_all_port_colors()
	print("Wire removed and port colors updated")

func create_wire_from_data(wire_data):
	var start_parent_name = wire_data.get("start_parent_name", "")
	var start_port_name = wire_data.get("start_port_name", "")
	var end_parent_name = wire_data.get("end_parent_name", "")
	var end_port_name = wire_data.get("end_port_name", "")
	
	print("Attempting to restore wire: ", start_parent_name, ".", start_port_name, " -> ", end_parent_name, ".", end_port_name)

	var start_port = find_port_by_name(start_parent_name, start_port_name)
	var end_port = find_port_by_name(end_parent_name, end_port_name)
	
	if not start_port or not end_port:
		var start_pos_array = wire_data.get("start_position", [0, 0])
		var end_pos_array = wire_data.get("end_position", [0, 0])
		var start_pos = Vector2(start_pos_array[0], start_pos_array[1])
		var end_pos = Vector2(end_pos_array[0], end_pos_array[1])
		
		var max_distance = 150.0 if is_three_input_level else 50.0
		if not start_port:
			start_port = find_port_near_position(start_pos, max_distance)
		if not end_port:
			end_port = find_port_near_position(end_pos, max_distance)
	
	if start_port and end_port and start_port != end_port:
		var wire = preload("res://scenes/components/Wire.tscn").instantiate()
		wire.connect_ports(start_port, end_port)
		add_child(wire)
		wires.append(wire)
		
		# Проверяем наличие обратной связи после восстановления провода
		check_feedback_wire()
		
		print("Successfully restored wire: ", start_parent_name, ".", start_port_name, " -> ", end_parent_name, ".", end_port_name)
		return true
	else:
		print("WARNING: Could not restore wire")
		print("  Start port found: ", start_port != null)
		print("  End port found: ", end_port != null)
		return false

func _on_add_not_button_pressed():
	var not_gate = preload("res://scenes/gates/base_logic_el/NOTGate.tscn").instantiate()
	not_gate.position = Vector2(600, 400)
	add_child(not_gate)
	movable_objects.append(not_gate)
	update_all_logic_objects()
	mark_level_state_dirty()

func _on_add_and_button_pressed():
	var and_gate = preload("res://scenes/gates/ANDGate.tscn").instantiate()
	and_gate.position = Vector2(600, 500)
	add_child(and_gate)
	movable_objects.append(and_gate)
	update_all_logic_objects()
	mark_level_state_dirty()

func _on_add_or_button_pressed():
	var or_gate = preload("res://scenes/gates/base_logic_el/ORGate.tscn").instantiate()
	or_gate.position = Vector2(600, 600)
	add_child(or_gate)
	movable_objects.append(or_gate)
	update_all_logic_objects()
	mark_level_state_dirty()
