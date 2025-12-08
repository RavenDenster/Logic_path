# Level28.gd
extends "res://scripts/levels/LevelT.gd"

var dtrigger_gate_count: int = 0
var xor_gate_count: int = 0
var constant_one_gate_count: int = 0
var max_dtrigger_gates: int = 1
var max_xor_gates: int = 1
var max_constant_one_gates: int = 1

func _ready():
	level_data = load("res://data/level_28_data.tres")

	if not level_data:
		push_error("Level28: level_data is null!")
		return
	
	super._ready()
	
	# Автоматически располагаем блоки по краям экрана
	setup_initial_block_positions()
	
	if test_results_panel and test_results_panel.has_method("set_titles"):
		test_results_panel.set_titles("Desired Q", "Current Q")
	
	recount_gates()
	update_gate_buttons_state()

func setup_initial_block_positions():
	var viewport_rect = get_viewport().get_visible_rect()
	var screen_width = viewport_rect.size.x
	var screen_height = viewport_rect.size.y
	
	# Располагаем входной блок слева (15% от ширины, по центру по вертикали)
	var input_block_clk = get_node_or_null("InputBlockClk")
	if input_block_clk:
		input_block_clk.position = Vector2(screen_width * 0.15, screen_height * 0.5)
		print("Level28: InputBlockClk positioned at: ", input_block_clk.position)
	
	# Располагаем выходной блок справа (85% от ширины, по центру по вертикали)
	var output_block_q = get_node_or_null("OutputBlockQ")
	if output_block_q:
		output_block_q.position = Vector2(screen_width * 0.85, screen_height * 0.5)
		print("Level28: OutputBlockQ positioned at: ", output_block_q.position)

func recount_gates():
	dtrigger_gate_count = 0
	xor_gate_count = 0
	constant_one_gate_count = 0
	for obj in movable_objects:
		if obj and is_instance_valid(obj):
			var scene_file = obj.scene_file_path
			if scene_file.find("DTrigger") != -1:
				dtrigger_gate_count += 1
			elif scene_file.find("XORGate") != -1:
				xor_gate_count += 1
			elif scene_file.find("ConstantOne") != -1:
				constant_one_gate_count += 1

func _on_add_dtrigger_button_pressed():
	if dtrigger_gate_count >= max_dtrigger_gates:
		print("Cannot add more D-триггеров. Maximum limit reached: ", max_dtrigger_gates)
		return
	
	var dtrigger_gate = load("res://scenes/gates/DTrigger.tscn").instantiate()
	var viewport_size = get_viewport().get_visible_rect().size
	dtrigger_gate.position = Vector2(viewport_size.x - 200, 200)
	add_child(dtrigger_gate)
	movable_objects.append(dtrigger_gate)
	dtrigger_gate_count += 1
	update_all_logic_objects()
	mark_level_state_dirty()
	update_gate_buttons_state()

func _on_add_xor_button_pressed():
	if xor_gate_count >= max_xor_gates:
		print("Cannot add more XOR gates. Maximum limit reached: ", max_xor_gates)
		return
	
	var xor_gate = load("res://scenes/gates/base_logic_el/XORGate.tscn").instantiate()
	var viewport_size = get_viewport().get_visible_rect().size
	xor_gate.position = Vector2(viewport_size.x - 400, 200)
	add_child(xor_gate)
	movable_objects.append(xor_gate)
	xor_gate_count += 1
	update_all_logic_objects()
	mark_level_state_dirty()
	update_gate_buttons_state()

func _on_add_constant_one_button_pressed():
	if constant_one_gate_count >= max_constant_one_gates:
		print("Cannot add more Constant One gates. Maximum limit reached: ", max_constant_one_gates)
		return
	
	var constant_one_gate = load("res://scenes/gates/ConstantOne.tscn").instantiate()
	var viewport_size = get_viewport().get_visible_rect().size
	constant_one_gate.position = Vector2(viewport_size.x - 600, 200)
	add_child(constant_one_gate)
	movable_objects.append(constant_one_gate)
	constant_one_gate_count += 1
	
	clock_signal_gate = constant_one_gate
	
	update_all_logic_objects()
	mark_level_state_dirty()
	update_gate_buttons_state()

func update_gate_buttons_state():
	var gate_buttons_container = $TopPanel/MainContainer/RightSection/GateButtonsContainer
	var dtrigger_button = gate_buttons_container.get_node_or_null("DTrigger")
	var xor_button = gate_buttons_container.get_node_or_null("XOR")
	var constant_one_button = gate_buttons_container.get_node_or_null("ConstantOne")
	
	if dtrigger_button:
		dtrigger_button.disabled = (dtrigger_gate_count >= max_dtrigger_gates)
	
	if xor_button:
		xor_button.disabled = (xor_gate_count >= max_xor_gates)
	
	if constant_one_button:
		constant_one_button.disabled = (constant_one_gate_count >= max_constant_one_gates)

func remove_dtrigger_gate():
	if dtrigger_gate_count > 0:
		dtrigger_gate_count -= 1
		update_gate_buttons_state()

func remove_xor_gate():
	if xor_gate_count > 0:
		xor_gate_count -= 1
		update_gate_buttons_state()

func remove_constant_one_gate():
	if constant_one_gate_count > 0:
		constant_one_gate_count -= 1
		if clock_signal_gate:
			clock_signal_gate = null
		update_gate_buttons_state()

func remove_and_gate():
	pass

func remove_or_gate():
	pass

func remove_not_gate():
	pass

func clear_level():
	super.clear_level()
	dtrigger_gate_count = 0
	xor_gate_count = 0
	constant_one_gate_count = 0
	clock_signal_gate = null
	# При очистке уровня также переставляем блоки по краям
	setup_initial_block_positions()
	update_gate_buttons_state()

func restore_level_state(state):
	clear_level()
	
	if state.has("gates"):
		for gate_data in state["gates"]:
			create_gate_from_data(gate_data)
	
	if state.has("wires"):
		for wire_data in state["wires"]:
			create_wire_from_data(wire_data)
	
	update_all_logic_objects()
	recount_gates()
	update_gate_buttons_state()
	update_all_port_colors()

func create_gate_from_data(gate_data):
	var gate_type = gate_data.get("type", "")
	var position_array = gate_data.get("position", [0, 0])
	var position = Vector2(position_array[0], position_array[1])
	
	if gate_type == "DTRIGGER" and dtrigger_gate_count >= max_dtrigger_gates:
		return
	elif gate_type == "XOR" and xor_gate_count >= max_xor_gates:
		return
	elif gate_type == "CONSTANT_ONE" and constant_one_gate_count >= max_constant_one_gates:
		return
	
	if gate_type == "INPUT_BLOCK_CLK" and has_node("InputBlockClk"):
		$InputBlockClk.position = position
		return
	elif gate_type == "OUTPUT_BLOCK_Q" and has_node("OutputBlockQ"):
		$OutputBlockQ.position = position
		return
	elif gate_type == "CLOCK_SIGNAL":
		var constant_one_gate = load("res://scenes/gates/ConstantOne.tscn").instantiate()
		constant_one_gate.position = position
		add_child(constant_one_gate)
		movable_objects.append(constant_one_gate)
		constant_one_gate_count += 1
		clock_signal_gate = constant_one_gate
		return

	var gate_scene = null
	
	match gate_type:
		"DTRIGGER":
			gate_scene = load("res://scenes/gates/DTrigger.tscn")
		"XOR":
			gate_scene = load("res://scenes/gates/base_logic_el/XORGate.tscn")
		"CONSTANT_ONE":
			gate_scene = load("res://scenes/gates/ConstantOne.tscn")
	
	if gate_scene:
		var gate = gate_scene.instantiate()
		gate.position = position
		add_child(gate)
		movable_objects.append(gate)
		
		if gate_type == "DTRIGGER":
			dtrigger_gate_count += 1
		elif gate_type == "XOR":
			xor_gate_count += 1
		elif gate_type == "CONSTANT_ONE":
			constant_one_gate_count += 1
			clock_signal_gate = gate

func custom_propagate_signals(clk_value):
	var dtrigger = null
	var xor_gate = null
	var constant_one = null
	
	for obj in movable_objects:
		if obj and obj.is_in_group("DTrigger"):
			dtrigger = obj
		elif obj and obj.is_in_group("XORGate"):
			xor_gate = obj
		elif obj and obj.is_in_group("ConstantOne"):
			constant_one = obj
	
	if not dtrigger or not xor_gate or not constant_one:
		return
	
	dtrigger.set_input(2, clk_value)
	
	var current_q = dtrigger.get_output("OutputQ")
	
	xor_gate.set_input(1, current_q)
	xor_gate.set_input(2, 1)
	
	xor_gate.update_output()
	var xor_output = xor_gate.get_output("Output")
	
	dtrigger.set_input(1, xor_output)
	
	if output_block_q:
		output_block_q.set_input(1, current_q)

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
		
		if original_text.find(hint_text) == -1:
			var theory_with_hint = original_text + "\n\n" + hint_text
			$TopPanel.set_theory_text(theory_with_hint)
