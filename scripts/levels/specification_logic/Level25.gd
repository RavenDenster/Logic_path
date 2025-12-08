# Level25.gd
extends "res://scripts/levels/level_templates/LevelRS.gd"

var nor_gate_count: int = 0
var max_nor_gates: int = 2

func _ready():
	level_data = load("res://data/level_25_data.tres")
	if not level_data:
		push_error("Level25: level_data is null!")
		return
	
	print("Level25 data loaded:")
	print(" Input R: ", level_data.input_values_r)
	print(" Input S: ", level_data.input_values_s)
	print(" Expected Q: ", level_data.expected_q)
	print(" Expected !Q: ", level_data.expected_not_q)
	
	# Вызываем super._ready() из LevelRS.gd
	super._ready()
	
	# Автоматически располагаем блоки по краям экрана
	setup_initial_block_positions()
	
	# Записываем начало прохождения уровня
	var level_number = get_level_number()
	if level_number > 0:
		var save_system = get_node_or_null("/root/SaveSystem")
		if save_system and save_system.has_method("record_level_start"):
			save_system.record_level_start(level_number)
	
	# Пересчитываем гейты после инициализации
	recount_gates()
	update_gate_buttons_state()

func setup_initial_block_positions():
	var viewport_rect = get_viewport().get_visible_rect()
	var screen_width = viewport_rect.size.x
	var screen_height = viewport_rect.size.y
	
	# Располагаем входные блоки слева (15% от ширины экрана)
	# Распределяем по вертикали
	var input_block_r = get_node_or_null("InputBlockR")
	if input_block_r:
		input_block_r.position = Vector2(screen_width * 0.15, screen_height * 0.35)
		print("Level25: InputBlockR positioned at: ", input_block_r.position)
	
	var input_block_s = get_node_or_null("InputBlockS")
	if input_block_s:
		input_block_s.position = Vector2(screen_width * 0.15, screen_height * 0.65)
		print("Level25: InputBlockS positioned at: ", input_block_s.position)
	
	# Располагаем выходные блоки справа (85% от ширины экрана)
	# Распределяем по вертикали
	var output_block_q = get_node_or_null("OutputBlockQ")
	if output_block_q:
		output_block_q.position = Vector2(screen_width * 0.85, screen_height * 0.35)
		print("Level25: OutputBlockQ positioned at: ", output_block_q.position)
	
	var output_block_not_q = get_node_or_null("OutputBlockNotQ")
	if output_block_not_q:
		output_block_not_q.position = Vector2(screen_width * 0.85, screen_height * 0.65)
		print("Level25: OutputBlockNotQ positioned at: ", output_block_not_q.position)

func _on_test_pressed():
	print("=== Testing RS level ===")
	
	# Записываем попытку
	var level_number = get_level_number()
	if level_number > 0:
		var save_system = get_node_or_null("/root/SaveSystem")
		if save_system and save_system.has_method("record_level_attempt"):
			save_system.record_level_attempt(level_number)
	
	reset_all_port_sprites()
	if output_block_q:
		output_block_q.set_default_style()
	if output_block_not_q:
		output_block_not_q.set_default_style()
	
	var player_q_outputs = []
	var player_not_q_outputs = []
	
	# Для RS-триггера важно сохранять состояние между тестами
	for obj in all_logic_objects:
		if obj and obj.has_method("reset_inputs"):
			obj.reset_inputs()
	
	for i in range(8):
		print("--- Test case ", i, " ---")
		input_block_r.current_test_index = i
		input_block_s.current_test_index = i
		print("Inputs: R=", input_block_r.values[i], " S=", input_block_s.values[i])
		propagate_signals()
		
		if output_block_q:
			player_q_outputs.append(int(output_block_q.received_value))
			print("Q output: ", output_block_q.received_value)
		else:
			player_q_outputs.append(0)
		
		if output_block_not_q:
			player_not_q_outputs.append(int(output_block_not_q.received_value))
			print("Not Q output: ", output_block_not_q.received_value)
		else:
			player_not_q_outputs.append(0)
	
	print("=== Test results ===")
	print("Player Q: ", player_q_outputs)
	print("Expected Q: ", level_data.expected_q)
	print("Player Not Q: ", player_not_q_outputs)
	print("Expected Not Q: ", level_data.expected_not_q)
	
	if test_results_panel and test_results_panel.has_method("update_current_outputs"):
		test_results_panel.update_current_outputs(player_q_outputs, player_not_q_outputs)
	
	print("Test panel updated")
	var q_correct = player_q_outputs == level_data.expected_q
	var not_q_correct = player_not_q_outputs == level_data.expected_not_q
	print("Q correct: ", q_correct, " Not Q correct: ", not_q_correct)
	
	if q_correct and not_q_correct:
		if output_block_q:
			output_block_q.set_correct_style()
		if output_block_not_q:
			output_block_not_q.set_correct_style()
		
		if not level_completed_this_session:
			# Сохраняем прогресс и записываем завершение уровня
			save_level_progress()
			
			var save_system = get_node_or_null("/root/SaveSystem")
			if save_system and save_system.has_method("record_level_completion"):
				save_system.record_level_completion(get_level_number())
			
			level_completed_this_session = true
			handle_test_success()
		print("Level completed successfully!")
	else:
		if output_block_q:
			output_block_q.set_default_style()
		if output_block_not_q:
			output_block_not_q.set_default_style()
		level_completed_this_session = false
		handle_test_failure()
		print("Level not completed - outputs don't match")
	
	update_all_port_colors()

func _on_add_nor_button_pressed():
	print("Adding NOR gate")
	
	if nor_gate_count >= max_nor_gates:
		print("Cannot add more NOR gates. Maximum limit reached: ", max_nor_gates)
		return
	
	var nor_gate = load("res://scenes/gates/base_logic_el/NORGate.tscn").instantiate()
	var viewport_size = get_viewport().get_visible_rect().size
	nor_gate.position = Vector2(viewport_size.x - 200, 150)
	add_child(nor_gate)
	movable_objects.append(nor_gate)
	nor_gate_count += 1
	
	update_all_logic_objects()
	mark_level_state_dirty()
	update_gate_buttons_state()
	
	print("NOR gate added. Current count: ", nor_gate_count)

func _on_add_rs_flip_flop_button_pressed():
	print("Adding RS Flip-Flop")
	var rs_flip_flop = load("res://scenes/gates/RSFlipFlop.tscn").instantiate()
	rs_flip_flop.position = Vector2(600, 400)
	add_child(rs_flip_flop)
	movable_objects.append(rs_flip_flop)
	
	update_all_logic_objects()
	mark_level_state_dirty()

func recount_gates():
	nor_gate_count = 0
	for obj in movable_objects:
		if obj and is_instance_valid(obj):
			var scene_file = obj.scene_file_path
			if "NORGate" in scene_file:
				nor_gate_count += 1
	print("Recounted gates - NOR: ", nor_gate_count)

func update_gate_buttons_state():
	var gate_buttons_container = $TopPanel/MainContainer/RightSection/GateButtonsContainer
	var nor_button = gate_buttons_container.get_node_or_null("NOR")
	
	if nor_button:
		nor_button.disabled = (nor_gate_count >= max_nor_gates)
		print("NOR button disabled: ", nor_button.disabled)

# Метод для удаления NOR-гейта
func remove_nor_gate():
	if nor_gate_count > 0:
		nor_gate_count -= 1
		update_gate_buttons_state()
		print("NOR gate removed. Current count: ", nor_gate_count)

func clear_level():
	super.clear_level()
	nor_gate_count = 0
	# При очистке уровня также переставляем блоки по краям
	setup_initial_block_positions()
	update_gate_buttons_state()
	print("Level25 cleared - NOR gate count reset to 0")

func restore_level_state(state):
	# Сначала очищаем уровень
	clear_level()
	
	# Затем восстанавливаем состояние
	if state.has("gates"):
		print("Restoring ", state["gates"].size(), " gates")
		for gate_data in state["gates"]:
			create_gate_from_data(gate_data)
	
	if state.has("wires"):
		print("Restoring ", state["wires"].size(), " wires")
		for wire_data in state["wires"]:
			create_wire_from_data(wire_data)
	
	update_all_logic_objects()
	recount_gates()  # Пересчитываем после восстановления
	update_gate_buttons_state()
	update_all_port_colors()
	
	print("Level state restored successfully. NOR gates: ", nor_gate_count)

func create_gate_from_data(gate_data):
	var gate_type = gate_data.get("type", "")
	var position_array = gate_data.get("position", [0, 0])
	var position = Vector2(position_array[0], position_array[1])
	
	# Проверяем ограничения для NOR-гейтов
	if gate_type == "NOR" and nor_gate_count >= max_nor_gates:
		print("Cannot restore NOR gate: maximum limit reached")
		return
	
	# Проверяем специальные блоки
	if gate_type == "INPUT_BLOCK_R" and has_node("InputBlockR"):
		$InputBlockR.position = position
		print("Restored InputBlockR position: ", position)
		return
	elif gate_type == "INPUT_BLOCK_S" and has_node("InputBlockS"):
		$InputBlockS.position = position
		print("Restored InputBlockS position: ", position)
		return
	elif gate_type == "OUTPUT_BLOCK_Q" and has_node("OutputBlockQ"):
		$OutputBlockQ.position = position
		print("Restored OutputBlockQ position: ", position)
		return
	elif gate_type == "OUTPUT_BLOCK_NOT_Q" and has_node("OutputBlockNotQ"):
		$OutputBlockNotQ.position = position
		print("Restored OutputBlockNotQ position: ", position)
		return
	
	var gate_scene = null
	
	match gate_type:
		"NOR":
			gate_scene = load("res://scenes/gates/base_logic_el/NORGate.tscn")
		"RSFLIPFLOP":
			gate_scene = load("res://scenes/gates/RSFlipFlop.tscn")
	
	if gate_scene:
		var gate = gate_scene.instantiate()
		gate.position = position
		add_child(gate)
		movable_objects.append(gate)
		
		# Увеличиваем счетчики
		if gate_type == "NOR":
			nor_gate_count += 1
			
		print("Restored gate: ", gate_type, " at ", position)

# Методы для других типов гейтов (не используются в этом уровне)
func remove_and_gate():
	print("remove_and_gate called on Level25 (not used)")

func remove_not_gate():
	print("remove_not_gate called on Level25 (not used)")

func remove_or_gate():
	print("remove_or_gate called on Level25 (not used)")

func remove_xor_gate():
	print("remove_xor_gate called on Level25 (not used)")

func remove_xnor_gate():
	print("remove_xnor_gate called on Level25 (not used)")

func remove_nand_gate():
	print("remove_nand_gate called on Level25 (not used)")

func remove_sel0_gate():
	print("remove_sel0_gate called on Level25 (not used)")

func remove_sel1_gate():
	print("remove_sel1_gate called on Level25 (not used)")
