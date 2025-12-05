extends Node2D

var drawing_wire = false
var start_port = null
var wires = []
var movable_objects = []
var all_logic_objects = []
var temp_line: Line2D
var input_blocks = []
var is_three_input_level = false
var dragging_object = null
var drag_offset = Vector2.ZERO

var failed_attempts_count: int = 0
var hints_enabled: bool = false

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
			var regex = RegEx.new()
			regex.compile("Level(\\d+)")
			var result = regex.search(scene_path)
			if result:
				return result.get_string(1).to_int()
	
	var scene_name = current_scene.name if current_scene else ""
	if "Level1" in scene_name: return 1
	if "Level2" in scene_name: return 2
	if "Level3" in scene_name: return 3
	if "Level4" in scene_name: return 4
	if "Level5" in scene_name: return 5
	if "Level6" in scene_name: return 6
	if "Level7" in scene_name: return 7
	if "Level8" in scene_name: return 8
	if "Level9" in scene_name: return 9
	if "Level10" in scene_name: return 10
	if "Level11" in scene_name: return 11
	if "Level12" in scene_name: return 12
	if "Level13" in scene_name: return 13
	
	return 0
	

func _ready():
	# Этот метод должен быть переопределен в дочерних классах
	push_error("_ready not implemented in child class for level type!")

func handle_test_failure():
	var level_number = get_level_number()
	if level_number > 0:
		var save_system = get_node_or_null("/root/SaveSystem")
		if save_system:
			save_system.increment_failed_attempts(level_number)
			failed_attempts_count = save_system.get_failed_attempts(level_number)
			hints_enabled = (failed_attempts_count >= 5)
			
			if hints_enabled and failed_attempts_count == 5:
				print("Hints activated for level ", level_number)
				# Обновляем текст теории с подсказкой
				_update_theory_with_hint()

func handle_test_success():
	var level_number = get_level_number()
	if level_number > 0:
		var save_system = get_node_or_null("/root/SaveSystem")
		if save_system:
			save_system.reset_failed_attempts(level_number)
			failed_attempts_count = 0
			hints_enabled = false

func _update_theory_with_hint():
	var level_number = get_level_number()
	var hint_text = _get_hint_for_level(level_number)
	
	if hint_text != "" and has_node("TopPanel"):
		var original_text = level_data.theory_text
		var theory_with_hint = original_text + "\n\n" + hint_text
		$TopPanel.set_theory_text(theory_with_hint)
		print("Theory updated with hint for level ", level_number)

func _get_hint_for_level(level_number: int) -> String:
	match level_number:
		1: # OR Gate
			return "[b]Подсказка:[/b] Для построения OR вам понадобится просто один элемент OR."
		2: # AND Gate  
			return "[b]Подсказка:[/b] Для построения AND вам понадобится просто один элемент AND."
		3: # NOT Gate
			return "[b]Подсказка:[/b] Y = NOT(A AND B)"
		4: # XOR Gate
			return "[b]Подсказка:[/b] Y = NOT(A OR B)"
		5: # NAND Gate
			return "[b]Подсказка:[/b] Y = (A AND NOT B) OR (NOT A AND B)"
		6: # NOR Gate
			return "[b]Подсказка:[/b] A → B = NOT A OR B"
		7: # XNOR Gate
			return "[b]Подсказка:[/b] Вы можете реализовать XNOR двумя способами: как инвертированный XOR (NOT(XOR)) или напрямую по формуле (A AND B) OR (NOT A AND NOT B)."
		8: # Implication
			return "[b]Подсказка:[/b] Вам понадобятся 3 элемента AND для проверки всех возможных пар (A,B), (A,C), (B,C) и 1 элемент OR для объединения результатов."
		9: # Half Adder
			return "[b]Подсказка:[/b] Создайте два элемента XOR и соедините их последовательно: первый обрабатывает A и B, второй обрабатывает результат первого XOR и вход C."
		10: # Full Adder
			return "[b]Подсказка:[/b] Схема состоит из двух частей: (A AND B) выбирает B когда A=1, а (NOT A AND C) выбирает C когда A=0. Объедините результаты с помощью OR."
		11: # 4-to-1 MUX
			return "[b]Подсказка:[/b] Для построеСоздайте две независимые схемы:
					1. Первая обнаруживает комбинацию 000: NOT A AND NOT B AND NOT C
					2. Вторая обнаруживает комбинацию 101: A AND NOT B AND C
					3. Объедините результаты через OR"
		12: # ALU Operation
			return "[b]Подсказка:[/b] Создайте три независимых пути:
					1. Путь для Data0: Data0 AND NOT Sel1 AND NOT Sel0
					2. Путь для Data1: Data1 AND NOT Sel1 AND Sel0  
					3. Путь для Data2: Data2 AND Sel1 AND NOT Sel0
					4. Объедините все три пути через OR-элемент"
		13: # 1-bit Comparator
			return "[b]Подсказка:[/b] Схема состоит из двух независимых частей:
					1. Для вычисления Sum используйте элемент XOR
					2. Для вычисления Carry используйте элемент AND
					3. Подключите оба входа A и B к обоим элементам."
		14:
			return "[b]Подсказка:[/b] Схема состоит из двух основных частей:
					1. Для вычисления Sum используйте два элемента XOR (A XOR B XOR Cin)
					2. Для вычисления Cout используйте комбинацию AND и OR элементов
					3. Первый AND вычисляет A AND B, второй AND вычисляет Cin AND (A XOR B)
					4. Объедините результаты двух AND элементов через OR элемент"
		15:
			return "[b]Подсказка:[/b] Схема состоит из двух основных компонентов:
					1. Полусумматор для младших битов A0 и B0 → получаем S0 и Cout0
					2. Полный сумматор для старших битов A1, B1 и переноса Cout0 → получаем S1 и Cout
					3. Соедините выход переноса полусумматора со входом переноса полного сумматора"
		16:
			return "[b]Подсказка:[/b] Схема состоит из двух независимых частей:
					1. Для вычисления Difference используйте элемент XOR
					2. Для вычисления Borrow используйте комбинацию NOT и AND: NOT A AND B
					3. Подключите оба входа A и B к соответствующим элементам"
		17:
			return "[b]Подсказка:[/b] Схема состоит из двух основных частей:
					1. Для вычисления Difference используйте два элемента XOR (A XOR B XOR Bin)
					2. Для вычисления Bout используйте комбинацию NOT, AND и OR элементов
					3. Первый AND: NOT A AND B
					4. Второй AND: NOT A AND Bin  
					5. Третий AND: B AND Bin
					6. Объедините результаты трех AND элементов через OR элемент"
		18:
			return "[b]Подсказка:[/b] Схема состоит из трех основных частей:
					1. Вычислите три операции параллельно: A AND B, A OR B, A XOR B
					2. Используйте мультиплексор 4→1 для выбора нужной операции:
					   - Вход 0: AND результат
					   - Вход 1: OR результат  
					   - Вход 2: XOR результат
					   - Вход 3: 0 (постоянный ноль)
					3. Управляйте мультиплексором с помощью кода операции OpCode"
		19:
			return "[b]Подсказка:[/b] Схема состоит из трех независимых частей:
					1. Для A>B: A AND NOT B
					2. Для A<B: NOT A AND B
					3. Для A==B: A XNOR B
					Используйте элементы NOT для инвертирования входов и AND/XNOR для комбинации сигналов."
		20:
			return "[b]Подсказка:[/b] Схема состоит из следующих компонентов:
					1. Два 1-битных компаратора:
					   - Первый для A1 и B1 (старшие биты)
					   - Второй для A0 и B0 (младшие биты)

					2. Для A>B: (A1>B1) OR (A1==B1 AND A0>B0)

					3. Для A<B: (A1<B1) OR (A1==B1 AND A0<B0)

					4. Для A==B: (A1==B1) AND (A0==B0)

					Используйте элементы AND и OR для объединения результатов сравнения."
		21:
			return "[b]Подсказка:[/b] Схема состоит из двух элементов OR:
					1. Первый OR объединяет входы I2 и I3 → выход O1 (старший бит)
					2. Второй OR объединяет входы I1 и I3 → выход O0 (младший бит)"
		22:
			return "[b]Подсказка:[/b] Схема состоит из двух частей:
					1. Для O1: I3 OR I2 (старший бит активируется при I3 или I2)
					2. Для O0: I3 OR (I1 AND NOT I2) 
					   - I1 активирует младший бит только если I2 неактивен
					   - I3 всегда активирует младший бит"
		23:
			return "[b]Подсказка:[/b] Схема состоит из четырех независимых частей:
					1. Y0: NOT A AND NOT B
					2. Y1: NOT A AND B
					3. Y2: A AND NOT B
					4. Y3: A AND B"
		24:
			return "[b]Подсказка:[/b] Схема состоит из восьми независимых частей:
					1. Создайте инвертированные версии сигналов A, B, C с помощью элементов NOT
					2. Для каждого выхода Y0-Y7 используйте трехвходовый AND элемент с соответствующей комбинацией:
					   - Y0: NOT A, NOT B, NOT C
					   - Y1: NOT A, NOT B, C
					   - Y2: NOT A, B, NOT C
					   - Y3: NOT A, B, C
					   - Y4: A, NOT B, NOT C
					   - Y5: A, NOT B, C
					   - Y6: A, B, NOT C
					   - Y7: A, B, C"
		25:
			return "[b]Подсказка:[/b] Схема состоит из двух элементов NOR, соединенных в кольцо обратной связи:
					1. Выход первого NOR подключите ко второму входу второго NOR
					2. Выход второго NOR подключите ко второму входу первого NOR
					3. Вход S подключите к первому входу первого NOR
					4. Вход R подключите к первому входу второго NOR
					5. Выход первого NOR будет Q
					6. Выход второго NOR будет !Q"
		26:
			return "[b]Подсказка:[/b] Схема состоит из двух путей, объединенных через OR:
					1. Прямой путь (активен при Enable=1): D AND Enable
					2. Путь обратной связи (активен при Enable=0): Q AND NOT Enable
					3. Объедините оба пути через OR элемент
					4. Создайте обратную связь: выход OR подключите ко второму AND элементу"
		_:
			return ""
		
func setup_two_input_level(): pass

func setup_three_input_level(): pass
	
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
	# Этот метод должен быть переопределен в дочерних классах
	push_error("get_gates_data not implemented in child class for level type!")
	return []


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
		
		print("=== SAVING LEVEL ", level_number, " ===")
		print("Gates to save: ", gates_data.size())
		for gate in gates_data:
			print("  - ", gate.get("type", "UNKNOWN"), " at ", gate.get("position", [0, 0]))
		
		print("Wires to save: ", wires_data.size())
		
		var save_system = get_node("/root/SaveSystem")
		if save_system:
			save_system.save_level_state(level_number, save_data)
			print("Level state saved for level ", level_number)
		else:
			print("ERROR: SaveSystem not found!")

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

	if state.has("gates"):
		print("Restoring ", state["gates"].size(), " gates")
		for gate_data in state["gates"]:
			create_gate_from_data(gate_data)

	if state.has("wires"):
		print("Restoring ", state["wires"].size(), " wires")
		for wire_data in state["wires"]:
			create_wire_from_data(wire_data)
	
	update_all_logic_objects()

	update_all_port_colors()
	
	print("Level state restored successfully")

func clear_level():
	# Этот метод должен быть переопределен в дочерних классах
	push_error("clear_level not implemented in child class for level type!")

func create_gate_from_data(gate_data):
	# Этот метод должен быть переопределен в дочерних классах
	push_error("create_gate_from_data not implemented in child class for level type!")

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
		print("Successfully restored wire: ", start_parent_name, ".", start_port_name, " -> ", end_parent_name, ".", end_port_name)
		return true
	else:
		print("WARNING: Could not restore wire")
		print("  Start port found: ", start_port != null)
		print("  End port found: ", end_port != null)
		return false
		
func find_port_by_name(parent_name, port_name):
	# Этот метод должен быть переопределен в дочерних классах
	push_error("find_port_by_name not implemented in child class for level type!")
	return null

func get_object_type(obj):
	# Этот метод должен быть переопределен в дочерних классах
	push_error("get_object_type not implemented in child class for level type!")
	return "UNKNOWN"

func find_port_near_position(position, max_distance = 50.0):
	# Этот метод должен быть переопределен в дочерних классах
	push_error("find_port_near_position not implemented in child class for level type!")
	return null
	
func _setup_top_panel_buttons():
	var menu_button = $TopPanel/MainContainer/LeftSection/MenuButton
	var hint_button = $TopPanel/MainContainer/LeftSection/TheoryButton
	var map_button = $TopPanel/MainContainer/LeftSection/MapButton
	var run_button = $TopPanel/MainContainer/LeftSection/RunButton
	
	menu_button.connect("pressed", _on_menu_button_pressed)

	map_button.connect("pressed", _on_map_button_pressed)
	run_button.connect("pressed", _on_test_pressed)

	var gate_buttons_container = $TopPanel/MainContainer/RightSection/GateButtonsContainer

	for child in gate_buttons_container.get_children():
		child.hide()

	for gate_type in level_data.available_gates:
		var button = gate_buttons_container.get_node_or_null(gate_type)
		if button:
			button.show()

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
				"SEL0":
					button.connect("pressed", _on_add_sel0_button_pressed)
				"SEL1":
					button.connect("pressed", _on_add_sel1_button_pressed)
				"HalfAdder":
					button.connect("pressed", _on_add_half_adder_button_pressed)
				"FullAdder":
					button.connect("pressed", _on_add_full_adder_button_pressed)
				"Cout0":
					button.connect("pressed", _on_add_cout0_button_pressed)
				"MUX4to1":
					button.connect("pressed", _on_add_mux4to1_button_pressed)
				"OpCode":
					button.connect("pressed", _on_add_opcode_button_pressed)
				"OneBitComparator": 
					button.connect("pressed", _on_add_onebit_comparator_button_pressed)
				"RSFlipFlop": 
					button.connect("pressed", _on_add_rs_flip_flop_button_pressed)
				"DFlipFlop":
					button.connect("pressed", _on_add_d_flip_flop_button_pressed)
				"CLK":
					button.connect("pressed", _on_add_clk_button_pressed)
					
func update_all_logic_objects():
	all_logic_objects = movable_objects.duplicate()
	print("Updated all_logic_objects: ", all_logic_objects)
	
func _on_test_pressed():
	# Базовый метод - будет переопределен в дочерних классах
	push_error("_on_test_pressed not implemented in child class for level type!")

func _input(event):
	# Этот метод должен быть переопределен в дочерних классах
	push_error("_input not implemented in child class for level type!")
					
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

func remove_wire(wire):
	if wire in wires:
		wires.erase(wire)
	if is_instance_valid(wire):
		wire.queue_free()
	
	update_all_port_colors()
	print("Wire removed and port colors updated")

func update_all_port_colors():
	reset_all_port_sprites()

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
	# Этот метод должен быть переопределен в дочерних классах
	push_error("reset_all_port_sprites not implemented in child class for level type!")

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
	query.collision_mask = 1 
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


func _on_add_not_button_pressed(): pass

func _on_add_and_button_pressed(): pass

func _on_add_or_button_pressed(): pass

func _on_add_xor_button_pressed(): pass

func _on_add_nor_button_pressed(): pass

func _on_add_nand_button_pressed(): pass

func _on_add_nxor_button_pressed(): pass

func _on_add_implication_button_pressed(): pass
	
func _on_add_sel0_button_pressed(): pass

func _on_add_sel1_button_pressed(): pass

func _on_add_half_adder_button_pressed(): pass
func _on_add_full_adder_button_pressed(): pass
func _on_add_cout0_button_pressed(): pass
func _on_add_mux4to1_button_pressed(): pass
func _on_add_opcode_button_pressed(): pass
func _on_add_rs_flip_flop_button_pressed(): pass

func _on_add_onebit_comparator_button_pressed():
	print("Adding OneBitComparator gate")
	var gate_scene = preload("res://scenes/gates/OneBitComparatorGate.tscn")
	var gate = gate_scene.instantiate()
	
	# Позиция рядом с курсором или в центре экрана
	var viewport_size = get_viewport_rect().size
	gate.position = Vector2(viewport_size.x / 2, viewport_size.y / 2)
	
	add_child(gate)
	movable_objects.append(gate)
	update_all_logic_objects()
	mark_level_state_dirty()
	
	print("OneBitComparator gate added at position: ", gate.position)

func save_and_exit(scene_path: String):

	level_state_dirty = true
	save_level_state()

	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file(scene_path)

func _on_menu_button_pressed():
	save_and_exit("res://scenes/ui/MainMenu.tscn")

func _on_map_button_pressed():
	save_and_exit("res://scenes/ui/LevelMap.tscn")
	
func _on_add_tflipflop_button_pressed(): 
	print("Base TFlipFlop button pressed - should be overridden in child class")
	pass
	
func _on_add_d_flip_flop_button_pressed(): 
	print("Adding D Flip-Flop from base class")

func _on_add_clk_button_pressed():
	print("Adding CLK Gate from base class") 
