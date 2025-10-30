extends Node2D

var drawing_wire = false
var start_port = null
var wires = []
var movable_objects = []
var all_logic_objects = []
var temp_line: Line2D
var dragging_object = null
var drag_offset = Vector2.ZERO

var level_data: Resource

@onready var test_results_panel = $TestResultsPanel
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
	
	return 0
	

func _ready():
	if not level_data:
		push_error("Level data not set in child class!")
		return

	if $TopPanel:
		$TopPanel.set_level_name(level_data.level_name)
		$TopPanel.set_theory_text(level_data.theory_text)
	
	$InputBlock.values_A = level_data.input_values_a.duplicate()
	$InputBlock.values_B = level_data.input_values_b.duplicate()

	$OutputBlock.expected = level_data.expected_output.duplicate()

	movable_objects.append($InputBlock)
	movable_objects.append($OutputBlock)

	var level_number = get_level_number()
	if level_number > 0:
		var save_system = get_node("/root/SaveSystem")
		if save_system:
			save_system.set_last_played_level(level_number)
			print("Last played level set to: ", level_number)
	
	update_all_logic_objects()
	await get_tree().process_frame

	if test_results_panel:
		test_results_panel.load_initial_data(level_data.input_values_a, level_data.input_values_b, level_data.expected_output)
	else:
		print("ERROR: test_results_panel is null!")
		
	temp_line = Line2D.new()
	add_child(temp_line)
	temp_line.default_color = Color("#e39e45")
	temp_line.width = 8
	temp_line.points = []
	
	_setup_top_panel_buttons()

	load_level_state()

	auto_save_timer = Timer.new()
	auto_save_timer.wait_time = 2.0
	auto_save_timer.one_shot = true
	auto_save_timer.timeout.connect(_on_auto_save_timeout)
	add_child(auto_save_timer)

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
	
	for obj in movable_objects:
		if obj == $InputBlock or obj == $OutputBlock:
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
		if wire and wire.start_port and wire.end_port:
			var wire_data = {
				"start_port_position": [wire.start_port.global_position.x, wire.start_port.global_position.y],
				"end_port_position": [wire.end_port.global_position.x, wire.end_port.global_position.y]
			}
			wires_data.append(wire_data)
	
	return wires_data

func save_level_state():
	var level_number = get_level_number()
	if level_number > 0:
		var gates_data = get_gates_data()
		var wires_data = get_wires_data()
		
		var save_system = get_node("/root/SaveSystem")
		if save_system:
			save_system.save_level_state(level_number, gates_data, wires_data)
			print("Level state saved for level ", level_number)
		else:
			push_error("SaveSystem not found!")

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
	clear_level()
	
	if state.has("gates"):
		for gate_data in state["gates"]:
			create_gate_from_data(gate_data)
	
	if state.has("wires"):
		for wire_data in state["wires"]:
			create_wire_from_data(wire_data)
	
	update_all_logic_objects()

func clear_level():
	for wire in wires:
		if is_instance_valid(wire):
			wire.queue_free()
	wires.clear()
	
	for i in range(movable_objects.size() - 1, -1, -1):
		var obj = movable_objects[i]
		if obj != $InputBlock and obj != $OutputBlock:
			if is_instance_valid(obj):
				obj.queue_free()
			movable_objects.remove_at(i)
	
	update_all_logic_objects()
	reset_all_port_sprites()

func create_gate_from_data(gate_data):
	var gate_type = gate_data.get("type", "")
	var position_array = gate_data.get("position", [0, 0])
	var position = Vector2(position_array[0], position_array[1])
	
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
	var start_pos_array = wire_data.get("start_port_position", [0, 0])
	var end_pos_array = wire_data.get("end_port_position", [0, 0])
	var start_pos = Vector2(start_pos_array[0], start_pos_array[1])
	var end_pos = Vector2(end_pos_array[0], end_pos_array[1])
	
	var start_port = find_port_near_position(start_pos)
	var end_port = find_port_near_position(end_pos)
	
	if start_port and end_port and start_port != end_port:
		var wire = preload("res://scenes/components/Wire.tscn").instantiate()
		wire.connect_ports(start_port, end_port)
		add_child(wire)
		wires.append(wire)
		print("Restored wire")

func find_port_near_position(position, max_distance = 50.0):
	var closest_port = null
	var closest_distance = max_distance
	
	for obj in movable_objects:
		var ports = []
		
		if obj == $InputBlock:
			ports = [$InputBlock/OutputA, $InputBlock/OutputB]
		elif obj == $OutputBlock:
			ports = [$OutputBlock/InputPort]
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
			if port:
				drawing_wire = true
				start_port = port
			else:
				for obj in movable_objects:
					var sprite = obj.get_node("Sprite2D")
					if sprite:
						var local_mouse = sprite.to_local(get_global_mouse_position())
						var sprite_rect = sprite.get_rect()
						if sprite_rect.has_point(local_mouse):
							dragging_object = obj
							drag_offset = obj.global_position - get_global_mouse_position()
							break
		else:
			if drawing_wire:
				var end_port = get_port_under_mouse()
				if end_port and end_port != start_port:
					var wire = preload("res://scenes/components/Wire.tscn").instantiate()
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
			if obj == $InputBlock or obj == $OutputBlock:
				continue
				
			var sprite = obj.get_node("Sprite2D")
			if sprite:
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
				var wire_points = wire.get_points()
				if wire_points.size() >= 2:
					var closest_point = get_closest_point_on_line(wire_points, mouse_pos)
					if closest_point.distance_to(mouse_pos) < 10:
						wire.queue_free()
						wires.remove_at(i)
						update_all_port_colors()
						mark_level_state_dirty()
						break

func remove_wires_connected_to_gate(gate):
	for i in range(wires.size() - 1, -1, -1):
		var wire = wires[i]
		if wire.start_port.get_parent() == gate or wire.end_port.get_parent() == gate:
			wire.queue_free()
			wires.remove_at(i)
	update_all_port_colors()

func update_all_port_colors():
	reset_all_port_sprites()
	
	for wire in wires:
		if wire and wire.start_port and wire.end_port:
			var start_sprite = wire.start_port.get_node("Sprite2D")
			var end_sprite = wire.end_port.get_node("Sprite2D")
			
			if start_sprite:
				start_sprite.texture = preload("res://assets/pointGreen.png")
			if end_sprite:
				end_sprite.texture = preload("res://assets/pointGreen.png")

func reset_all_port_sprites():
	for port in [$InputBlock/OutputA, $InputBlock/OutputB]:
		var sprite = port.get_node("Sprite2D")
		if sprite:
			sprite.texture = preload("res://assets/point.png")

	var output_port = $OutputBlock/InputPort
	var output_sprite = output_port.get_node("Sprite2D")
	if output_sprite:
		output_sprite.texture = preload("res://assets/point.png")
	
	for obj in movable_objects:
		if obj == $InputBlock or obj == $OutputBlock:
			continue
			
		var input_ports = []
		var input1 = obj.get_node_or_null("Input1")
		var input2 = obj.get_node_or_null("Input2")
		var input_port = obj.get_node_or_null("InputPort")
		var output = obj.get_node_or_null("Output")
		
		if input1: input_ports.append(input1)
		if input2: input_ports.append(input2)
		if input_port: input_ports.append(input_port)
		if output: input_ports.append(output)
		
		for port in input_ports:
			if port and port.has_node("Sprite2D"):
				var sprite = port.get_node("Sprite2D")
				if sprite:
					sprite.texture = preload("res://assets/point.png")

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
	var intersects = space_state.intersect_point(query, 1)
	if intersects.size() > 0:
		var collider = intersects[0].collider
		if collider is Area2D:
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
	var collision_shape = port.get_node("CollisionShape2D")
	if collision_shape:
		return collision_shape.global_position
	return port.global_position

func _on_test_pressed():
	reset_all_port_sprites()
	
	var player_outputs = []
	$OutputBlock.set_default_style()

	for i in range(4):
		$InputBlock.current_test_index = i
		propagate_signals()
		player_outputs.append(int($OutputBlock.received_value))
	
	print("Test results - Actual: ", player_outputs)

	if test_results_panel:
		test_results_panel.update_current_outputs(player_outputs)
	else:
		print("ERROR: test_results_panel is null!")

	if player_outputs == $OutputBlock.expected:
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
	
