extends "res://scripts/levels/LevelBase.gd"

var input_block_d
var input_block_enable
var output_block_q
var correct_scheme_detected = false

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
	
	# Добавлено: инициализация счетчика неудачных попыток и подсказок
	var level_number = get_level_number()
	if level_number > 0:
		var save_system = get_node_or_null("/root/SaveSystem")
		if save_system and save_system.has_method("record_level_start"):
			save_system.record_level_start(level_number)
		if save_system:
			failed_attempts_count = save_system.get_failed_attempts(level_number)
			hints_enabled = (failed_attempts_count >= 5)
			print("Failed attempts for level ", level_number, ": ", failed_attempts_count, ", hints enabled: ", hints_enabled)
			if hints_enabled:
				_update_theory_with_hint()
	
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
		
		# Устанавливаем разные метки для подсветки
		# Важно: метки должны точно соответствовать тому, что написано в таблице
		input_block_d.input_label = "Input D"
		input_block_enable.input_label = "Enable"
		
		print("D Latch input blocks initialized with labels:")
		print("  Input D label: '", input_block_d.input_label, "'")
		print("  Input Enable label: '", input_block_enable.input_label, "'")
		
		movable_objects.append(input_block_d)
		movable_objects.append(input_block_enable)
	else:
		push_error("Input blocks not found in D Latch level!")
	
	# Get output block
	output_block_q = get_node_or_null("OutputBlockQ")
	if output_block_q:
		output_block_q.expected = level_data.expected_q.duplicate()
		# Устанавливаем тип вывода для подсветки
		output_block_q.output_type = "Q"
		movable_objects.append(output_block_q)
		print("D Latch output block initialized")
	else:
		push_error("Output block not found in D Latch level!")
	
	test_results_panel = get_node_or_null("TestResultsPanelDLatch")
	if test_results_panel:
		print("D Latch test panel found")
		
		# Передаем ссылку на панель блокам
		if input_block_d:
			input_block_d.test_results_panel = test_results_panel
		if input_block_enable:
			input_block_enable.test_results_panel = test_results_panel
		if output_block_q:
			output_block_q.test_results_panel = test_results_panel
	else:
		print("WARNING: TestResultsPanelDLatch not found!")
	
	update_all_logic_objects()
	print("Movable objects: ", movable_objects.size())
	print("All logic objects: ", all_logic_objects.size())

func _on_test_pressed():
	print("=== Testing D Latch level ===")
	
	# Добавлено: запись попытки
	var level_number = get_level_number()
	if level_number > 0:
		var save_system = get_node_or_null("/root/SaveSystem")
		if save_system and save_system.has_method("record_level_attempt"):
			save_system.record_level_attempt(level_number)
	
	reset_all_port_sprites()
	
	if output_block_q:
		output_block_q.set_default_style()
	
	var player_q_outputs = []
	
	# Проверяем наличие правильной схемы D-защелки
	correct_scheme_detected = check_correct_d_latch_scheme()
	print("Correct D-latch scheme detected: ", correct_scheme_detected)
	
	# Используем правильную логику только если схема полностью корректна
	if correct_scheme_detected:
		print("Using correct D-latch formula for testing")
		# Используем правильную логику D-защелки
		var latch_state = 0
		for i in range(8):
			var d = input_block_d.values[i]
			var e = input_block_enable.values[i]
			
			# Формула D-защелки: Q_new = (D AND E) OR (Q_old AND NOT E)
			var q_new = 0
			if e == 1:  # Если Enable=1, пропускаем D
				q_new = d
			else:  # Если Enable=0, сохраняем предыдущее состояние
				q_new = latch_state
			
			player_q_outputs.append(q_new)
			latch_state = q_new
			print("Test case ", i, ": D=", d, " E=", e, " Q=", q_new)
	else:
		# Используем обычную логику распространения сигналов
		print("Using standard signal propagation")
		
		for i in range(8):
			print("--- Test case ", i, " ---")
			input_block_d.current_test_index = i
			input_block_enable.current_test_index = i
			
			print("Inputs: D=", input_block_d.values[i], " Enable=", input_block_enable.values[i])
			
			# Сбрасываем все вентили (включая output блок)
			for obj in all_logic_objects:
				if obj and obj.has_method("reset_inputs"):
					obj.reset_inputs()
			
			# Если нет проводов к выходному блоку, его значение должно быть 0
			var has_wire_to_output = false
			for wire in wires:
				if not wire or not is_instance_valid(wire):
					continue
				if not wire.end_port or not is_instance_valid(wire.end_port):
					continue
				var end_gate = wire.end_port.get_parent()
				if end_gate == output_block_q:
					has_wire_to_output = true
					break
			
			if not has_wire_to_output:
				# Если к выходу ничего не подключено, результат = 0
				player_q_outputs.append(0)
				print("No wires connected to output, Q = 0")
				continue
			
			# Для схемы с обратной связью может потребоваться несколько итераций
			var stable = false
			var previous_value = -1
			var iterations = 0
			var max_iterations = 10
			
			while not stable and iterations < max_iterations:
				# Получаем входные значения
				var d_value = input_block_d.get_output("Output")
				var e_value = input_block_enable.get_output("Output")
				
				# Распространяем сигналы
				propagate_signals(d_value, e_value)
				
				# Получаем текущее выходное значение
				var current_value = 0
				if output_block_q:
					current_value = output_block_q.get_output("Output")
				
				print("Iteration ", iterations, ": Q = ", current_value)
				
				# Проверяем стабильность
				if current_value == previous_value:
					stable = true
				else:
					previous_value = current_value
					iterations += 1
			
			if output_block_q:
				player_q_outputs.append(int(output_block_q.get_output("Output")))
				print("Final Q output: ", output_block_q.get_output("Output"))
			else:
				player_q_outputs.append(0)
	
	print("=== Test results ===")
	print("Player Q: ", player_q_outputs)
	
	var expected_output = level_data.expected_q
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
		# Добавлено: обработка успешной попытки
		handle_test_success()
	else:
		if output_block_q:
			output_block_q.set_default_style()
		level_completed_this_session = false
		print("Level not completed - outputs don't match")
		# Добавлено: обработка неудачной попытки
		handle_test_failure()
	
	update_all_port_colors()

func check_correct_d_latch_scheme():
	# Сначала проверим, что все необходимые компоненты есть
	var and_gates = []
	var or_gates = []
	var not_gates = []
	
	for obj in movable_objects:
		var obj_type = get_object_type(obj)
		if obj_type == "AND":
			and_gates.append(obj)
		elif obj_type == "OR":
			or_gates.append(obj)
		elif obj_type == "NOT":
			not_gates.append(obj)
	
	# Проверяем наличие необходимых компонентов
	if and_gates.size() < 2 or or_gates.size() < 1 or not_gates.size() < 1:
		print("Missing required gates: AND=", and_gates.size(), " OR=", or_gates.size(), " NOT=", not_gates.size())
		return false
	
	# Построим карту соединений
	var connections = {}
	
	# Инициализируем для всех объектов
	for obj in movable_objects:
		connections[obj] = {"inputs": [], "outputs": []}
	
	# Заполняем соединения из проводов
	for wire in wires:
		var start_gate = wire.start_port.get_parent()
		var end_gate = wire.end_port.get_parent()
		
		if start_gate in connections and end_gate in connections:
			connections[start_gate]["outputs"].append(end_gate)
			connections[end_gate]["inputs"].append(start_gate)
	
	# Ищем AND1: подключен к D и Enable
	var and1 = null
	for and_gate in and_gates:
		var inputs = connections[and_gate]["inputs"]
		if input_block_d in inputs and input_block_enable in inputs:
			and1 = and_gate
			break
	
	if not and1:
		print("Не найден AND, подключенный к D и Enable")
		return false
	
	# Ищем NOT, подключенный к Enable
	var not_gate = null
	for n in not_gates:
		var inputs = connections[n]["inputs"]
		if input_block_enable in inputs:
			not_gate = n
			break
	
	if not not_gate:
		print("Не найден NOT, подключенный к Enable")
		return false
	
	# Ищем AND2, подключенный к NOT и к Q (обратная связь)
	var and2 = null
	for and_gate in and_gates:
		if and_gate == and1:
			continue
		var inputs = connections[and_gate]["inputs"]
		if not_gate in inputs and output_block_q in inputs:
			and2 = and_gate
			break
	
	if not and2:
		print("Не найден AND, подключенный к NOT и Q (обратная связь)")
		return false
	
	# Проверяем, что выходы AND1 и AND2 подключены к OR
	var or_gate = null
	for o in or_gates:
		var inputs = connections[o]["inputs"]
		if and1 in inputs and and2 in inputs:
			or_gate = o
			break
	
	if not or_gate:
		print("Не найден OR, подключенный к выходам обоих AND")
		return false
	
	# Проверяем, что выход OR подключен к Q
	if output_block_q in connections[or_gate]["outputs"]:
		# Все проверки пройдены, схема правильная
		print("All D-latch connections verified successfully")
		return true
	else:
		print("Выход OR не подключен к Q")
		return false

func propagate_signals(d_value, e_value):
	# Сначала установим входные значения
	var input_values = {}
	
	# Устанавливаем значения для всех входов на основе проводов
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
		
		# Получаем значение от стартового гейта
		var output_value = 0
		if start_gate == input_block_d:
			output_value = d_value
		elif start_gate == input_block_enable:
			output_value = e_value
		elif start_gate.has_method("get_output"):
			output_value = int(start_gate.get_output("Output"))
		
		# Передаем значение конечному гейту
		var end_port_name = wire.end_port.name
		if end_gate.has_method("set_input"):
			var port_num = get_port_number(end_port_name)
			end_gate.set_input(port_num, output_value)

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
		var output_port = input_block_d.get_node_or_null("output")
		if output_port and is_instance_valid(output_port):
			var sprite = output_port.get_node_or_null("Sprite2D")
			if sprite and is_instance_valid(sprite):
				sprite.texture = load("res://assets/point.png")
				print("Reset InputBlockD output port")
	
	if input_block_enable:
		var output_port = input_block_enable.get_node_or_null("output")
		if output_port and is_instance_valid(output_port):
			var sprite = output_port.get_node_or_null("Sprite2D")
			if sprite and is_instance_valid(sprite):
				sprite.texture = load("res://assets/point.png")
				print("Reset InputBlockEnable output port")
	
	if output_block_q:
		var input_port = output_block_q.get_node_or_null("InputPort")
		if input_port and is_instance_valid(input_port):
			var sprite = input_port.get_node_or_null("Sprite2D")
			if sprite and is_instance_valid(sprite):
				sprite.texture = load("res://assets/point.png")
				print("Reset OutputBlockQ input port")
		
		# Также сбрасываем выходной порт
		var output_port = output_block_q.get_node_or_null("Output")
		if output_port and is_instance_valid(output_port):
			var sprite = output_port.get_node_or_null("Sprite2D")
			if sprite and is_instance_valid(sprite):
				sprite.texture = load("res://assets/point.png")
				print("Reset OutputBlockQ output port")
	
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
				sprite.texture = load("res://assets/point.png")
	
	print("D Latch level: Reset all port sprites")

func update_all_port_colors():
	# Сначала сбрасываем все порты
	reset_all_port_sprites()
	
	# Затем красим только подключенные порты
	for wire in wires:
		if not wire or not is_instance_valid(wire):
			continue
		if not wire.start_port or not is_instance_valid(wire.start_port):
			continue
		if not wire.end_port or not is_instance_valid(wire.end_port):
			continue
		
		var start_sprite = wire.start_port.get_node_or_null("Sprite2D")
		var end_sprite = wire.end_port.get_node_or_null("Sprite2D")
		
		if start_sprite and is_instance_valid(start_sprite):
			start_sprite.texture = load("res://assets/pointGreen.png")
		
		if end_sprite and is_instance_valid(end_sprite):
			end_sprite.texture = load("res://assets/pointGreen.png")
	
	print("Updated port colors for ", wires.size(), " wires")

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
							
							# Вызываем подсветку при клике на InputBlock или OutputBlock
							if obj.has_method("_on_area_mouse_entered"):
								obj._on_area_mouse_entered()
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
					
					# Уменьшаем счетчики гейтов (если есть такие методы)
					var scene_file = obj.scene_file_path
					if "ANDGate" in scene_file:
						if has_method("remove_and_gate"):
							remove_and_gate()
					elif "ORGate" in scene_file:
						if has_method("remove_or_gate"):
							remove_or_gate()
					elif "NOTGate" in scene_file:
						if has_method("remove_not_gate"):
							remove_not_gate()
					elif "XORGate" in scene_file:
						if has_method("remove_xor_gate"):
							remove_xor_gate()
					elif "XNORGate" in scene_file:
						if has_method("remove_xnor_gate"):
							remove_xnor_gate()
					elif "NANDGate" in scene_file:
						if has_method("remove_nand_gate"):
							remove_nand_gate()
					elif "NORGate" in scene_file:
						if has_method("remove_nor_gate"):
							remove_nor_gate()
					
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

func remove_nor_gate():
	pass

func remove_and_gate():
	pass

func remove_not_gate():
	pass

func remove_or_gate():
	pass
	
func remove_xor_gate():
	pass
	
func remove_xnor_gate():
	pass
	
func remove_nand_gate():
	pass
	
func remove_wire(wire):
	if wire in wires:
		wires.erase(wire)
		if is_instance_valid(wire):
			wire.queue_free()
		
		update_all_port_colors()
		print("Wire removed and port colors updated")

func remove_wires_connected_to_gate(gate):
	var wires_to_remove = []
	for wire in wires:
		if wire.start_port.get_parent() == gate or wire.end_port.get_parent() == gate:
			wires_to_remove.append(wire)
	
	for wire in wires_to_remove:
		if wire in wires:
			wires.erase(wire)
		if is_instance_valid(wire):
			wire.queue_free()
	
	update_all_port_colors()
	print("Removed wires connected to gate: ", gate.name)

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
		var wire = load("res://scenes/components/Wire.tscn").instantiate()
		wire.connect_ports(start_port, end_port)
		add_child(wire)
		wires.append(wire)
		
		print("Successfully restored wire: ", start_parent_name, ".", start_port_name, " -> ", end_parent_name, ".", end_port_name)
		return true
	else:
		print("WARNING: Could not restore wire")
		print(" Start port found: ", start_port != null)
		print(" End port found: ", end_port != null)
		return false

func _on_add_not_button_pressed():
	var not_gate = load("res://scenes/gates/base_logic_el/NOTGate.tscn").instantiate()
	not_gate.position = Vector2(600, 400)
	add_child(not_gate)
	movable_objects.append(not_gate)
	update_all_logic_objects()
	mark_level_state_dirty()

func _on_add_and_button_pressed():
	var and_gate = load("res://scenes/gates/ANDGate.tscn").instantiate()
	and_gate.position = Vector2(600, 500)
	add_child(and_gate)
	movable_objects.append(and_gate)
	update_all_logic_objects()
	mark_level_state_dirty()

func _on_add_or_button_pressed():
	var or_gate = load("res://scenes/gates/base_logic_el/ORGate.tscn").instantiate()
	or_gate.position = Vector2(600, 600)
	add_child(or_gate)
	movable_objects.append(or_gate)
	update_all_logic_objects()
	mark_level_state_dirty()
