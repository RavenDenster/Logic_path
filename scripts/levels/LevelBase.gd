extends Node2D

var drawing_wire = false
var start_port = null
var wires = []
var movable_objects = []
var all_logic_objects = []
var temp_line: Line2D
var input_blocks = []  # Массив для хранения всех InputBlock'ов
var is_three_input_level = false
var dragging_object = null
var drag_offset = Vector2.ZERO

var level_data: Resource

var test_results_panel = null
var level_completed_this_session = false
var level_state_dirty = false
var auto_save_timer = null

func get_level_number() -> int:
	var current_scene = get_tree().current_scene
	if current_scene:
		var scene_path = current_scene.scene_file_path
		if scene_path:
			# Извлекаем номер уровня из пути к сцене
			var regex = RegEx.new()
			regex.compile("Level(\\d+)")
			var result = regex.search(scene_path)
			if result:
				return result.get_string(1).to_int()
	
	# Альтернативный способ: проверяем имя сцены
	var scene_name = current_scene.name if current_scene else ""
	if "Level1" in scene_name: return 1
	if "Level2" in scene_name: return 2
	if "Level3" in scene_name: return 3
	if "Level4" in scene_name: return 4
	if "Level5" in scene_name: return 5
	if "Level6" in scene_name: return 6
	if "Level7" in scene_name: return 7  # Добавляем 7 уровень
	
	return 0
	

func _ready():
	if not level_data:
		push_error("Level data not set in child class!")
		return
	
	# Инициализируем переменные
	wires = []
	movable_objects = []
	all_logic_objects = []
	input_blocks = []
	test_results_panel = null
	
	# Проверяем, есть ли данные для третьего входа
	is_three_input_level = level_data.get("input_values_c") != null and level_data.input_values_c.size() > 0
	
	# Настраиваем TopPanel с названием уровня и теорией
	if has_node("TopPanel") and $TopPanel.has_method("set_level_name"):
		$TopPanel.set_level_name(level_data.level_name)
		$TopPanel.set_theory_text(level_data.theory_text)
	
	# Настраиваем OutputBlock на основе данных уровня
	if has_node("OutputBlock"):
		$OutputBlock.expected = level_data.expected_output.duplicate()
	
	# Сначала настраиваем уровень (2 или 3 входа)
	if is_three_input_level:
		setup_three_input_level()
	else:
		setup_two_input_level()
	
	# Инициализируем временную линию для рисования проводов
	temp_line = Line2D.new()
	add_child(temp_line)
	temp_line.default_color = Color("#e39e45")
	temp_line.width = 8
	temp_line.points = []
	
	# Настраиваем кнопки на TopPanel
	_setup_top_panel_buttons()
	
	# Обновляем список логических объектов
	update_all_logic_objects()
	
	# Ждем один кадр для инициализации сцены
	await get_tree().process_frame
	
	# Загружаем начальные данные на панель результатов
	if test_results_panel:
		if is_three_input_level and test_results_panel.has_method("load_initial_data"):
			test_results_panel.load_initial_data(level_data.input_values_a, level_data.input_values_b, level_data.input_values_c, level_data.expected_output)
		elif test_results_panel.has_method("load_initial_data"):
			test_results_panel.load_initial_data(level_data.input_values_a, level_data.input_values_b, level_data.expected_output)
	else:
		print("WARNING: test_results_panel is null - this is normal for three-input levels")
	
	# Загружаем состояние уровня при запуске
	load_level_state()
	
	# Таймер для автосохранения
	auto_save_timer = Timer.new()
	auto_save_timer.wait_time = 2.0
	auto_save_timer.one_shot = true
	auto_save_timer.timeout.connect(_on_auto_save_timeout)
	add_child(auto_save_timer)
	
	print("LevelBase ready completed successfully")

func setup_two_input_level():
	print("Setting up two-input level")
	
	# Настраиваем InputBlock на основе данных уровня
	if has_node("InputBlock"):
		$InputBlock.values_A = level_data.input_values_a.duplicate()
		$InputBlock.values_B = level_data.input_values_b.duplicate()
		
		# Добавляем перемещаемые объекты
		movable_objects.append($InputBlock)
		movable_objects.append($OutputBlock)
		
		# Устанавливаем ссылку на панель результатов
		if has_node("TestResultsPanel"):
			test_results_panel = $TestResultsPanel
			print("Two-input level: TestResultsPanel found")
		else:
			print("WARNING: TestResultsPanel not found in two-input level")
	else:
		push_error("InputBlock not found in two-input level!")

func setup_three_input_level():
	print("Setting up three-input level")
	
	# Скрываем старый InputBlock, если он существует
	if has_node("InputBlock"):
		$InputBlock.hide()
	
	# Ищем вручную размещенные InputBlock'и
	input_blocks = []
	
	# Проверяем, есть ли уже размещенные InputBlock'и
	var input_block_a = get_node_or_null("InputBlockA")
	var input_block_b = get_node_or_null("InputBlockB") 
	var input_block_c = get_node_or_null("InputBlockC")
	
	# Если блоки уже существуют (например, восстановлены из сохранения), используем их
	if input_block_a and input_block_b and input_block_c:
		print("Using existing InputBlocks")
		input_blocks = [input_block_a, input_block_b, input_block_c]
		
		# Устанавливаем значения только если они еще не установлены
		if input_block_a.values.is_empty():
			input_block_a.values = level_data.input_values_a.duplicate()
			print("Set values for InputBlockA")
		if input_block_b.values.is_empty():
			input_block_b.values = level_data.input_values_b.duplicate()
			print("Set values for InputBlockB")
		if input_block_c.values.is_empty():
			input_block_c.values = level_data.input_values_c.duplicate()
			print("Set values for InputBlockC")
	else:
		print("Creating InputBlocks programmatically")
		# Создаем блоки программно
		var input_block_scene = preload("res://scenes/components/SingleInputBlock.tscn")
		
		# InputBlock A
		input_block_a = input_block_scene.instantiate()
		input_block_a.name = "InputBlockA"
		input_block_a.position = Vector2(200, 300)
		input_block_a.values = level_data.input_values_a.duplicate()
		add_child(input_block_a)
		
		# InputBlock B  
		input_block_b = input_block_scene.instantiate()
		input_block_b.name = "InputBlockB"
		input_block_b.position = Vector2(200, 500)
		input_block_b.values = level_data.input_values_b.duplicate()
		add_child(input_block_b)
		
		# InputBlock C
		input_block_c = input_block_scene.instantiate()
		input_block_c.name = "InputBlockC"
		input_block_c.position = Vector2(200, 700)
		input_block_c.values = level_data.input_values_c.duplicate()
		add_child(input_block_c)
		
		input_blocks = [input_block_a, input_block_b, input_block_c]
	
	# Добавляем в movable_objects (если еще не добавлены)
	for input_block in input_blocks:
		if not input_block in movable_objects:
			movable_objects.append(input_block)
			print("Added to movable_objects: ", input_block.name)
	
	if not $OutputBlock in movable_objects:
		movable_objects.append($OutputBlock)
		print("Added OutputBlock to movable_objects")
	
	# Ищем вручную размещенную TestResultsPanel3Inputs
	test_results_panel = get_node_or_null("TestResultsPanel3Inputs")
	
	if not test_results_panel:
		print("Creating TestResultsPanel3Inputs programmatically")
		# Создаем новую панель результатов для трех входов
		var new_panel_scene = preload("res://scenes/ui/TestResultsPanel3Inputs.tscn")
		if ResourceLoader.exists(new_panel_scene.resource_path):
			var new_panel = new_panel_scene.instantiate()
			
			# Позиционируем новую панель
			new_panel.position = Vector2(1200, 200)
			add_child(new_panel)
			
			# Заменяем ссылку на панель результатов
			test_results_panel = new_panel
			print("Created TestResultsPanel3Inputs")
		else:
			push_error("TestResultsPanel3Inputs scene not found")
	else:
		print("Using existing TestResultsPanel3Inputs")
	
	print("Three-input level setup completed with ", input_blocks.size(), " input blocks")
	
func _exit_tree():

	save_level_state()

func mark_level_state_dirty():
	level_state_dirty = true
	if auto_save_timer and not auto_save_timer.is_stopped():
		auto_save_timer.start()

func _on_auto_save_timeout():
	if level_state_dirty:
		save_level_state()
		level_state_dirty = false

func get_gates_data():
	var gates_data = []
	
	# Раздельная логика для уровней с двумя и тремя входами
	if not is_three_input_level:
		# Уровни 1-6: сохраняем позиции InputBlock и OutputBlock
		if has_node("InputBlock"):
			var input_block_data = {
				"type": "INPUT_BLOCK",
				"position": [$InputBlock.position.x, $InputBlock.position.y]
			}
			gates_data.append(input_block_data)
		
		if has_node("OutputBlock"):
			var output_block_data = {
				"type": "OUTPUT_BLOCK", 
				"position": [$OutputBlock.position.x, $OutputBlock.position.y]
			}
			gates_data.append(output_block_data)
	else:
		# Уровень 7: сохраняем позиции InputBlockA, InputBlockB, InputBlockC и OutputBlock
		for input_block in input_blocks:
			if input_block and is_instance_valid(input_block):
				var input_block_data = {
					"type": "INPUT_BLOCK_SINGLE",
					"name": input_block.name,
					"position": [input_block.position.x, input_block.position.y]
				}
				gates_data.append(input_block_data)
		
		if has_node("OutputBlock"):
			var output_block_data = {
				"type": "OUTPUT_BLOCK",
				"position": [$OutputBlock.position.x, $OutputBlock.position.y]
			}
			gates_data.append(output_block_data)
	
	# Сохраняем логические гейты (AND, OR, NOT и т.д.) для всех уровней
	for obj in movable_objects:
		# Пропускаем InputBlock и OutputBlock, так как их уже обработали
		if (not is_three_input_level and (obj == $InputBlock or obj == $OutputBlock)) or \
		   (is_three_input_level and (obj in input_blocks or obj == $OutputBlock)):
			continue
			
		var scene_file = obj.scene_file_path
		var gate_type = "UNKNOWN"
		
		if "ANDGate" in scene_file:
			gate_type = "AND"
		elif "ORGate" in scene_file:
			gate_type = "OR"
		elif "NOTGate" in scene_file:
			gate_type = "NOT"
		elif "XORGate" in scene_file:
			gate_type = "XOR"
		elif "NANDGate" in scene_file:
			gate_type = "NAND"
		elif "NORGate" in scene_file:
			gate_type = "NOR"
		elif "XNORGate" in scene_file:
			gate_type = "XNOR"
		elif "ImplicationGate" in scene_file:
			gate_type = "IMPLICATION"
		
		var gate_data = {
			"type": gate_type,
			"position": [obj.position.x, obj.position.y]
		}
		gates_data.append(gate_data)
	
	return gates_data

func get_wires_data():
	var wires_data = []
	
	for wire in wires:
		if wire and wire.start_port and wire.end_port and is_instance_valid(wire.start_port) and is_instance_valid(wire.end_port):
			var start_parent = wire.start_port.get_parent()
			var end_parent = wire.end_port.get_parent()
			var start_port_name = wire.start_port.name
			var end_port_name = wire.end_port.name
			
			var wire_data = {
				"start_parent_name": start_parent.name,
				"start_port_name": start_port_name,
				"end_parent_name": end_parent.name,
				"end_port_name": end_port_name,
				"start_position": [wire.start_port.global_position.x, wire.start_port.global_position.y],
				"end_position": [wire.end_port.global_position.x, wire.end_port.global_position.y]
			}
			wires_data.append(wire_data)
	
	print("Saved ", wires_data.size(), " wires")
	return wires_data

func save_level_state():
	var level_number = get_level_number()
	if level_number > 0:
		var gates_data = get_gates_data()
		var wires_data = get_wires_data()
		
		var save_data = {
			"gates": gates_data,
			"wires": wires_data
		}
		
		print("Saving level ", level_number, " (", "three-input" if is_three_input_level else "two-input", ")")
		print("Gates: ", gates_data.size(), ", Wires: ", wires_data.size())
		
		# Подробное логирование для отладки
		for gate in gates_data:
			print("  Gate: ", gate.get("type", "UNKNOWN"), " at ", gate.get("position", [0, 0]))
		
		var save_system = get_node("/root/SaveSystem")
		if save_system:
			save_system.save_level_state(level_number, save_data)
			print("Level state saved for level ", level_number)
	
func load_level_state():
	var level_number = get_level_number()
	if level_number > 0:
		var save_system = get_node_or_null("/root/SaveSystem")
		if save_system:
			var state = save_system.get_level_state(level_number)
			if state:
				restore_level_state(state)
				print("Level state loaded for level ", level_number)
			else:
				print("No saved state found for level ", level_number)
		else:
			push_error("SaveSystem not found!")

func restore_level_state(state):
	if not state:
		print("No state to restore")
		return
		
	clear_level()
	
	print("Restoring level state for ", "three-input" if is_three_input_level else "two-input", " level")
	print("State data: ", state.keys())
	
	# Восстанавливаем гейты (включая InputBlock и OutputBlock)
	if state.has("gates"):
		print("Restoring ", state["gates"].size(), " gates")
		for gate_data in state["gates"]:
			create_gate_from_data(gate_data)
	
	# Восстанавливаем провода
	if state.has("wires"):
		print("Restoring ", state["wires"].size(), " wires")
		for wire_data in state["wires"]:
			create_wire_from_data(wire_data)
	
	update_all_logic_objects()
	# Обновляем цвета портов после восстановления всех проводов
	update_all_port_colors()
	
	print("Level state restored successfully")

func clear_level():
	# Удаляем провода
	for wire in wires:
		if is_instance_valid(wire):
			wire.queue_free()
	wires.clear()
	
	# Удаляем только логические гейты, сохраняя InputBlock и OutputBlock
	# Раздельная логика для уровней с двумя и тремя входами
	for i in range(movable_objects.size() - 1, -1, -1):
		var obj = movable_objects[i]
		
		if not is_three_input_level:
			# Уровни 1-6: сохраняем только InputBlock и OutputBlock
			if obj == $InputBlock or obj == $OutputBlock:
				continue
		else:
			# Уровень 7: сохраняем InputBlockA/B/C и OutputBlock
			if obj in input_blocks or obj == $OutputBlock:
				continue
			
		if is_instance_valid(obj):
			obj.queue_free()
		movable_objects.remove_at(i)
	
	update_all_logic_objects()
	reset_all_port_sprites()
	
	print("Level cleared - kept Input/Output blocks, removed gates and wires")

func create_gate_from_data(gate_data):
	var gate_type = gate_data.get("type", "")
	var position_array = gate_data.get("position", [0, 0])
	var position = Vector2(position_array[0], position_array[1])
	
	# Обрабатываем специальные типы блоков для уровней 1-6
	if gate_type == "INPUT_BLOCK" and has_node("InputBlock"):
		$InputBlock.position = position
		print("Restored InputBlock position: ", position)
		return
	elif gate_type == "OUTPUT_BLOCK" and has_node("OutputBlock"):
		$OutputBlock.position = position
		print("Restored OutputBlock position: ", position)
		return
	elif gate_type == "INPUT_BLOCK_SINGLE" and is_three_input_level:
		# Уровень 7: восстанавливаем позиции InputBlockSingle
		var block_name = gate_data.get("name", "")
		
		# Ищем существующий InputBlockSingle по имени
		var found_block = null
		for obj in get_children():
			if obj.name == block_name:
				found_block = obj
				break
		
		if found_block and is_instance_valid(found_block):
			found_block.position = position
			print("Restored InputBlockSingle position: ", block_name, " at ", position)
			
			# Убедимся, что блок добавлен в input_blocks
			if not found_block in input_blocks:
				input_blocks.append(found_block)
			if not found_block in movable_objects:
				movable_objects.append(found_block)
		else:
			print("WARNING: InputBlockSingle not found: ", block_name)
		return
	
	# Создаем логические гейты
	var gate_scene = null
	
	match gate_type:
		"AND":
			gate_scene = preload("res://scenes/gates/ANDGate.tscn")
		"OR":
			gate_scene = preload("res://scenes/gates/ORGate.tscn")
		"NOT":
			gate_scene = preload("res://scenes/gates/NOTGate.tscn")
		"XOR":
			gate_scene = preload("res://scenes/gates/XORGate.tscn")
		"NAND":
			gate_scene = preload("res://scenes/gates/NANDGate.tscn")
		"NOR":
			gate_scene = preload("res://scenes/gates/NORGate.tscn")
		"XNOR":
			gate_scene = preload("res://scenes/gates/XNORGate.tscn")
		"IMPLICATION":
			gate_scene = preload("res://scenes/gates/ImplicationGate.tscn")
	
	if gate_scene:
		var gate = gate_scene.instantiate()
		gate.position = position
		add_child(gate)
		movable_objects.append(gate)
		print("Restored gate: ", gate_type, " at ", position)

func create_wire_from_data(wire_data):
	var start_parent_name = wire_data.get("start_parent_name", "")
	var start_port_name = wire_data.get("start_port_name", "")
	var end_parent_name = wire_data.get("end_parent_name", "")
	var end_port_name = wire_data.get("end_port_name", "")
	
	print("Attempting to restore wire: ", start_parent_name, ".", start_port_name, " -> ", end_parent_name, ".", end_port_name)
	
	# Сначала пытаемся найти порты по именам
	var start_port = find_port_by_name(start_parent_name, start_port_name)
	var end_port = find_port_by_name(end_parent_name, end_port_name)
	
	# Если не нашли по именам, пытаемся по позициям
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
		print("Successfully restored wire: ", start_parent_name, ".", start_port_name, " -> ", end_parent_name, ".", end_port_name)
		return true
	else:
		print("WARNING: Could not restore wire")
		print("  Start port found: ", start_port != null)
		print("  End port found: ", end_port != null)
		return false
		
func find_port_by_name(parent_name, port_name):
	# Ищем родительский объект
	var parent = null
	
	# Проверяем основные блоки
	if parent_name == "OutputBlock" and has_node("OutputBlock"):
		parent = $OutputBlock
	elif parent_name == "InputBlock" and has_node("InputBlock"):
		parent = $InputBlock
	elif is_three_input_level:
		# Для трехвходового уровня ищем среди input_blocks
		for input_block in input_blocks:
			if input_block and input_block.name == parent_name:
				parent = input_block
				break
	
	# Если не нашли в основных блоках, ищем среди всех movable_objects
	if not parent:
		for obj in movable_objects:
			if obj and obj.name == parent_name:
				parent = obj
				break
	
	if not parent:
		print("Parent not found: ", parent_name)
		return null
	
	# Ищем порт у родителя - исправляем использование get_node_or_null
	var port = null
	if port_name is String or port_name is NodePath:
		port = parent.get_node_or_null(port_name)
	else:
		# Если port_name не строка, преобразуем в строку
		port = parent.get_node_or_null(str(port_name))
	
	if not port:
		print("Port not found: ", parent_name, "/", port_name)
		# Дополнительная отладка: выводим все дочерние узлы
		print("Available children in ", parent_name, ":")
		for child in parent.get_children():
			print("  - ", child.name, " (Type: ", child.get_class(), ")")
	
	return port

func find_port_near_position(position, max_distance = 50.0):
	var closest_port = null
	var closest_distance = max_distance
	
	for obj in movable_objects:
		if not obj or not is_instance_valid(obj):
			continue
			
		var ports = []
		if has_node("InputBlock") and obj == $InputBlock and obj.visible and not is_three_input_level:
			# Двухвходовой блок
			ports = [$InputBlock/OutputA, $InputBlock/OutputB]
		elif is_three_input_level and obj in input_blocks:
			# Трехвходовые блоки
			var output = obj.get_node_or_null("Output")
			if output: ports.append(output)
		elif obj == $OutputBlock:
			# Выходной блок
			var input_port = obj.get_node_or_null("InputPort")
			if input_port: ports.append(input_port)
		else:
			# Логические гейты
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
	
func _setup_top_panel_buttons():
	var menu_button = $TopPanel/HBoxContainer/MenuButton
	var hint_button = $TopPanel/HBoxContainer/TheoryButton
	var map_button = $TopPanel/HBoxContainer/MapButton
	var run_button = $TopPanel/HBoxContainer/RunButton
	
	menu_button.connect("pressed", _on_menu_button_pressed)
	# Теперь TopPanel сам обрабатывает теорию
	map_button.connect("pressed", _on_map_button_pressed)
	run_button.connect("pressed", _on_test_pressed)
	
	# Показываем только те гейты, которые разрешены для этого уровня
	var gate_buttons_container = $TopPanel/GateButtonsContainer
	
	# Скрываем все кнопки сначала
	for child in gate_buttons_container.get_children():
		child.hide()
	
	# Показываем только разрешенные гейты
	for gate_type in level_data.available_gates:
		var button = gate_buttons_container.get_node_or_null(gate_type)
		if button:
			button.show()
			# Подключаем сигналы только для видимых кнопок
			match gate_type:
				"NOT":
					button.connect("pressed", _on_add_not_button_pressed)
				"AND":
					button.connect("pressed", _on_add_and_button_pressed)
				"OR":
					button.connect("pressed", _on_add_or_button_pressed)
				"XOR":
					button.connect("pressed", _on_add_xor_button_pressed)
				"NOR":
					button.connect("pressed", _on_add_nor_button_pressed)
				"NAND":
					button.connect("pressed", _on_add_nand_button_pressed)
				"XNOR":
					button.connect("pressed", _on_add_nxor_button_pressed)
				"Implication":
					button.connect("pressed", _on_add_implication_button_pressed)
					
func update_all_logic_objects():
	all_logic_objects = movable_objects.duplicate()
	print("Updated all_logic_objects: ", all_logic_objects)

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
		
		# Сначала проверяем объекты
		for i in range(movable_objects.size() - 1, -1, -1):
			var obj = movable_objects[i]
			# Пропускаем входные и выходные блоки
			if (not is_three_input_level and (obj == $InputBlock or obj == $OutputBlock)) or \
			   (is_three_input_level and (obj in input_blocks or obj == $OutputBlock)):
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
		
		# Затем проверяем провода
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
						# Удаляем провод и сбрасываем порты
						if wire.has_method("disconnect_ports"):
							wire.disconnect_ports()
						else:
							# Резервный метод, если функция disconnect_ports недоступна
							update_all_port_colors()
						
						wire.queue_free()
						wires.remove_at(i)
						mark_level_state_dirty()
						print("Wire removed")
						break
					
func remove_wires_connected_to_gate(gate):
	var wires_to_remove = []
	
	# Сначала собираем все провода для удаления
	for wire in wires:
		if wire.start_port.get_parent() == gate or wire.end_port.get_parent() == gate:
			wires_to_remove.append(wire)
	
	# Затем удаляем их
	for wire in wires_to_remove:
		if wire in wires:
			wires.erase(wire)
		if is_instance_valid(wire):
			wire.queue_free()
	
	# Немедленное обновление цветов портов
	update_all_port_colors()
	print("Removed wires connected to gate: ", gate.name)

func update_all_port_colors():
	# Сначала сбрасываем ВСЕ порты
	reset_all_port_sprites()
	
	# Затем устанавливаем зеленый цвет только для подключенных портов
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
			start_sprite.texture = preload("res://assets/pointGreen.png")
		if end_sprite and is_instance_valid(end_sprite):
			end_sprite.texture = preload("res://assets/pointGreen.png")
	
	print("Updated port colors for ", wires.size(), " wires")
	
func reset_all_port_sprites():
	# Сбрасываем все порты более надежным способом
	
	# Сбрасываем порты InputBlock для двух входов
	if not is_three_input_level and has_node("InputBlock"):
		var input_block = $InputBlock
		for port_name in ["OutputA", "OutputB"]:
			var port = input_block.get_node_or_null(port_name)
			if port and is_instance_valid(port):
				var sprite = port.get_node_or_null("Sprite2D")
				if sprite and is_instance_valid(sprite):
					sprite.texture = preload("res://assets/point.png")
	
	# Сбрасываем порты InputBlockSingle для трех входов
	if is_three_input_level:
		for input_block in input_blocks:
			if input_block and is_instance_valid(input_block):
				var output_port = input_block.get_node_or_null("Output")
				if output_port and is_instance_valid(output_port):
					var sprite = output_port.get_node_or_null("Sprite2D")
					if sprite and is_instance_valid(sprite):
						sprite.texture = preload("res://assets/point.png")
	
	# Сбрасываем порты OutputBlock
	if has_node("OutputBlock"):
		var output_block = $OutputBlock
		var input_port = output_block.get_node_or_null("InputPort")
		if input_port and is_instance_valid(input_port):
			var sprite = input_port.get_node_or_null("Sprite2D")
			if sprite and is_instance_valid(sprite):
				sprite.texture = preload("res://assets/point.png")
	
	# Сбрасываем порты всех логических гейтов
	for obj in movable_objects:
		if not obj or not is_instance_valid(obj):
			continue
			
		# Пропускаем InputBlock и OutputBlock, так как их уже обработали
		if (not is_three_input_level and (obj == $InputBlock or obj == $OutputBlock)) or \
		   (is_three_input_level and (obj in input_blocks or obj == $OutputBlock)):
			continue
		
		# Ищем все возможные порты
		var ports = []
		var possible_port_names = ["Input1", "Input2", "InputPort", "Output"]
		
		for port_name in possible_port_names:
			var port = obj.get_node_or_null(port_name)
			if port and is_instance_valid(port):
				ports.append(port)
		
		# Сбрасываем спрайты портов
		for port in ports:
			var sprite = port.get_node_or_null("Sprite2D")
			if sprite and is_instance_valid(sprite):
				sprite.texture = preload("res://assets/point.png")
	
	print("Reset all port sprites")

func get_closest_point_on_line(points, target_point):
	var closest_point = points[0]
	var min_distance = target_point.distance_to(points[0])
	
	for i in range(points.size() - 1):
		var segment_start = points[i]
		var segment_end = points[i + 1]
		var closest_on_segment = get_closest_point_on_segment(segment_start, segment_end, target_point)
		var distance = target_point.distance_to(closest_on_segment)
		if distance < min_distance:
			min_distance = distance
			closest_point = closest_on_segment
	
	return closest_point

func get_closest_point_on_segment(a, b, p):
	var ab = b - a
	var ap = p - a
	var ab_length_squared = ab.length_squared()
	
	if ab_length_squared == 0:
		return a
	
	var t = ap.dot(ab) / ab_length_squared
	t = clamp(t, 0.0, 1.0)
	
	return a + ab * t

func get_port_under_mouse():
	var mouse_pos = get_global_mouse_position()
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = mouse_pos
	query.collide_with_areas = true
	query.collision_mask = 1  # Убедимся, что проверяем правильный слой
	var intersects = space_state.intersect_point(query, 1)
	if intersects.size() > 0:
		var collider = intersects[0].collider
		if collider is Area2D and is_instance_valid(collider):
			return collider
	return null

func _process(delta):
	if drawing_wire and start_port:
		var start_pos = get_collision_shape_global_position(start_port)
		var mouse_pos = get_global_mouse_position()
		
		var points_array = []
		points_array.append(start_pos)
		
		var distance = abs(start_pos.x - mouse_pos.x)
		var bend_offset = min(80, distance * 0.3)
		
		if abs(start_pos.y - mouse_pos.y) < 15:
			points_array.append(mouse_pos)
		else:
			if mouse_pos.x >= start_pos.x:
				var bend_point1 = Vector2(start_pos.x + bend_offset, start_pos.y)
				var bend_point2 = Vector2((start_pos.x + bend_offset + mouse_pos.x) / 2, mouse_pos.y)
				points_array.append(bend_point1)
				points_array.append(bend_point2)
			else:
				var bend_point1 = Vector2(start_pos.x - bend_offset, start_pos.y)
				var bend_point2 = Vector2((start_pos.x - bend_offset + mouse_pos.x) / 2, mouse_pos.y)
				points_array.append(bend_point1)
				points_array.append(bend_point2)
			
			points_array.append(mouse_pos)
		
		temp_line.points = points_array
	else:
		temp_line.points = []
	
	for wire in wires:
		wire.update_wire()
	
	if dragging_object != null:
		dragging_object.global_position = get_global_mouse_position() + drag_offset
		if auto_save_timer and auto_save_timer.is_stopped():
			mark_level_state_dirty()

func get_collision_shape_global_position(port):
	if not port or not is_instance_valid(port):
		return Vector2.ZERO
	
	var collision_shape = port.get_node_or_null("CollisionShape2D")
	if collision_shape and is_instance_valid(collision_shape):
		return collision_shape.global_position
	return port.global_position

func _on_test_pressed():
	reset_all_port_sprites()
	if has_node("OutputBlock"):
		$OutputBlock.set_default_style()
	
	var player_outputs = []
	
	if is_three_input_level:
		# Тестирование для трех входов (8 тестов)
		for i in range(8):
			# Устанавливаем текущий индекс теста для всех трех входных блоков
			for input_block in input_blocks:
				input_block.current_test_index = i
			
			propagate_signals_three_inputs()
			if has_node("OutputBlock"):
				player_outputs.append(int($OutputBlock.received_value))
	else:
		# Оригинальная логика для двух входов (4 теста)
		for i in range(4):
			if has_node("InputBlock"):
				$InputBlock.current_test_index = i
			propagate_signals()
			if has_node("OutputBlock"):
				player_outputs.append(int($OutputBlock.received_value))
	
	print("Test results - Actual: ", player_outputs)
	
	# Обновляем панель результатов
	if test_results_panel:
		if is_three_input_level and test_results_panel.has_method("update_current_outputs"):
			test_results_panel.update_current_outputs(player_outputs)
		elif test_results_panel.has_method("update_current_outputs"):
			test_results_panel.update_current_outputs(player_outputs)
	
	# Проверяем результаты
	if has_node("OutputBlock"):
		var expected = $OutputBlock.expected
		if player_outputs == expected:
			$OutputBlock.set_correct_style()
			if not level_completed_this_session:
				save_level_progress()
				level_completed_this_session = true
		else:
			$OutputBlock.set_default_style()
			level_completed_this_session = false
	
	update_all_port_colors()
	
func save_level_progress():
	var level_number = get_level_number()
	if level_number > 0:
		var save_system = get_node_or_null("/root/SaveSystem")
		if save_system:
			save_system.complete_level(level_number)
			print("Progress saved for level ", level_number)
		else:
			push_error("SaveSystem not found!")

func extract_level_number(scene_name):
	var regex = RegEx.new()
	regex.compile("(\\d+)")
	var result = regex.search(scene_name)
	if result:
		return result.get_string(1).to_int()
	return 0

func propagate_signals():
	for obj in all_logic_objects:
		if obj.has_method("reset_inputs"):
			obj.reset_inputs()
	
	print("=== Starting signal propagation ===")
	
	var dependencies = {}
	var dependents = {}
	
	for obj in all_logic_objects:
		dependencies[obj] = []
		dependents[obj] = []
	
	for wire in wires:
		var start_gate = wire.start_port.get_parent()
		var end_gate = wire.end_port.get_parent()
		
		if start_gate != end_gate:
			if not dependencies[end_gate].has(start_gate):
				dependencies[end_gate].append(start_gate)
			if not dependents[start_gate].has(end_gate):
				dependents[start_gate].append(end_gate)
	
	var queue = []
	var in_degree = {}
	
	for obj in all_logic_objects:
		in_degree[obj] = dependencies[obj].size()
		if in_degree[obj] == 0:
			queue.append(obj)
	
	var processed_order = []
	
	while queue.size() > 0:
		var current = queue.pop_front()
		processed_order.append(current)
		
		for dependent in dependents[current]:
			in_degree[dependent] -= 1
			if in_degree[dependent] == 0:
				queue.append(dependent)
	
	print("Processing order: ", processed_order)
	
	for current in processed_order:
		print("Processing: ", current.name)
		
		if current == $InputBlock:
			for port_name in ["OutputA", "OutputB"]:
				var port = current.get_node_or_null(port_name)
				if port:
					for wire in wires:
						if wire.start_port == port:
							var end_gate = wire.end_port.get_parent()
							var end_port_name = wire.end_port.name
							var val = int(current.get_output(port_name))
							
							if end_gate.has_method("set_input"):
								var port_num = 1
								if end_port_name == "Input2":
									port_num = 2
								elif end_port_name == "InputPort":
									port_num = 1
								elif end_port_name == "Input":
									port_num = 1
								
								print("Setting input for ", end_gate.name, " port ", port_num, " to ", val)
								end_gate.set_input(port_num, val)
		
		elif current.has_method("get_output"):
			var output_value = int(current.get_output("Output"))
			print(current.name, " output value: ", output_value)
			
			for wire in wires:
				if wire.start_port.get_parent() == current:
					var end_gate = wire.end_port.get_parent()
					var end_port_name = wire.end_port.name
					
					if end_gate.has_method("set_input"):
						var port_num = 1
						if end_port_name == "Input2":
							port_num = 2
						elif end_port_name == "InputPort":
							port_num = 1
						elif end_port_name == "Input":
							port_num = 1
						
						print("Setting input for ", end_gate.name, " port ", port_num, " to ", output_value)
						end_gate.set_input(port_num, output_value)
	
	print("Final OutputBlock value: ", $OutputBlock.received_value)
	print("=== Signal propagation complete ===")
	
func propagate_signals_three_inputs():
	# Сбрасываем все объекты, кроме входных блоков
	for obj in all_logic_objects:
		if obj.has_method("reset_inputs") and not (obj in input_blocks):
			obj.reset_inputs()
	
	print("=== Starting signal propagation for three inputs ===")
	
	# Строим граф зависимостей
	var dependencies = {}
	var dependents = {}
	
	for obj in all_logic_objects:
		dependencies[obj] = []
		dependents[obj] = []
	
	# Заполняем зависимости на основе проводов
	for wire in wires:
		if not wire or not is_instance_valid(wire):
			continue
		if not wire.start_port or not is_instance_valid(wire.start_port):
			continue
		if not wire.end_port or not is_instance_valid(wire.end_port):
			continue
			
		var start_gate = wire.start_port.get_parent()
		var end_gate = wire.end_port.get_parent()
		
		if start_gate != end_gate:
			if not dependencies[end_gate].has(start_gate):
				dependencies[end_gate].append(start_gate)
			if not dependents[start_gate].has(end_gate):
				dependents[start_gate].append(end_gate)
	
	# Топологическая сортировка (алгоритм Кана)
	var queue = []
	var in_degree = {}
	
	for obj in all_logic_objects:
		in_degree[obj] = dependencies[obj].size()
		if in_degree[obj] == 0:
			queue.append(obj)
	
	var processed_order = []
	
	while queue.size() > 0:
		var current = queue.pop_front()
		processed_order.append(current)
		
		for dependent in dependents[current]:
			in_degree[dependent] -= 1
			if in_degree[dependent] == 0:
				queue.append(dependent)
	
	print("Processing order for three inputs: ", processed_order)
	
	# Обрабатываем объекты в порядке топологической сортировки
	for current in processed_order:
		if not current or not is_instance_valid(current):
			continue
			
		print("Processing: ", current.name)
		
		# Если это входной блок (InputBlockSingle)
		if current in input_blocks and current.has_method("get_output"):
			# Получаем выходное значение
			var output_value = int(current.get_output("Output"))
			print(current.name, " output value: ", output_value)
			
			# Передаем значение по всем исходящим проводам
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
						
						print("Setting input for ", end_gate.name, " port ", port_num, " to ", output_value)
						end_gate.set_input(port_num, output_value)
		
		# Если это логический гейт (AND, OR, NOT и т.д.)
		elif current.has_method("get_output") and current != $OutputBlock:
			# Вычисляем выходное значение гейта
			var output_value = int(current.get_output("Output"))
			print(current.name, " output value: ", output_value)
			
			# Передаем значение по всем исходящим проводам
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
						
						print("Setting input for ", end_gate.name, " port ", port_num, " to ", output_value)
						end_gate.set_input(port_num, output_value)
	
	if has_node("OutputBlock"):
		print("Final OutputBlock value: ", $OutputBlock.received_value)
	print("=== Signal propagation for three inputs complete ===")

func _on_add_not_button_pressed():
	pass

func _on_add_and_button_pressed():
	pass

func _on_add_or_button_pressed():
	pass

func _on_add_xor_button_pressed():
	pass

func _on_add_nor_button_pressed():
	pass

func _on_add_nand_button_pressed():
	pass

func _on_add_nxor_button_pressed():
	pass

func _on_add_implication_button_pressed():
	pass

func _on_menu_button_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")

func _on_map_button_pressed():
	print("Map button pressed - going to level map")
	get_tree().change_scene_to_file("res://scenes/ui/LevelMap.tscn")
	
