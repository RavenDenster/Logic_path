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
	var menu_button = $TopPanel/HBoxContainer/MenuButton
	var hint_button = $TopPanel/HBoxContainer/TheoryButton
	var map_button = $TopPanel/HBoxContainer/MapButton
	var run_button = $TopPanel/HBoxContainer/RunButton
	
	menu_button.connect("pressed", _on_menu_button_pressed)

	map_button.connect("pressed", _on_map_button_pressed)
	run_button.connect("pressed", _on_test_pressed)

	var gate_buttons_container = $TopPanel/GateButtonsContainer

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
	
