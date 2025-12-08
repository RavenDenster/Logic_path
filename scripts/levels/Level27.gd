# Level27.gd
extends "res://scripts/levels/LevelD2.gd"

var not_gate_count: int = 0
var dlatch_gate_count: int = 0
var max_not_gates: int = 2
var max_dlatch_gates: int = 2

func _ready():
	level_data = load("res://data/level_27_data.tres")

	if not level_data:
		push_error("Level27: level_data is null!")
		return
	
	print("Level27 data loaded:")
	print("  Input D: ", level_data.input_values_d)
	print("  Input CLK: ", level_data.input_values_clk)
	print("  Expected Q: ", level_data.expected_q)
	
	super._ready()
	
	# Автоматически располагаем блоки по краям экрана
	setup_initial_block_positions()
	
	# ДОБАВЬТЕ ЭТОТ КОД ПОСЛЕ super._ready():
	# Проверяем и включаем подсказки если нужно
	var level_number = get_level_number()
	if level_number > 0:
		var save_system = get_node_or_null("/root/SaveSystem")
		if save_system:
			failed_attempts_count = save_system.get_failed_attempts(level_number)
			hints_enabled = (failed_attempts_count >= 5)
			print("Failed attempts for level ", level_number, ": ", failed_attempts_count, ", hints enabled: ", hints_enabled)
			
			# Если подсказки уже включены, обновляем теорию
			if hints_enabled:
				_update_theory_with_hint()
	
	# Явно устанавливаем output_label для OutputBlockQ
	if output_block_q:
		output_block_q.output_label = "Current Q"
	
	# Устанавливаем заголовки для D-триггера
	if test_results_panel and test_results_panel.has_method("set_titles"):
		test_results_panel.set_titles("Desired Q", "Current Q")
	
	recount_gates()
	update_gate_buttons_state()

func setup_initial_block_positions():
	var viewport_rect = get_viewport().get_visible_rect()
	var screen_width = viewport_rect.size.x
	var screen_height = viewport_rect.size.y
	
	# Располагаем входные блоки слева (15% от ширины экрана)
	# Распределяем по вертикали
	var input_block_d = get_node_or_null("InputBlockD")
	if input_block_d:
		input_block_d.position = Vector2(screen_width * 0.15, screen_height * 0.35)
		print("Level27: InputBlockD positioned at: ", input_block_d.position)
	
	var input_block_clk = get_node_or_null("InputBlockClk")
	if input_block_clk:
		input_block_clk.position = Vector2(screen_width * 0.15, screen_height * 0.65)
		print("Level27: InputBlockClk positioned at: ", input_block_clk.position)
	
	# Располагаем выходной блок справа (85% от ширины, по центру по вертикали)
	var output_block_q = get_node_or_null("OutputBlockQ")
	if output_block_q:
		output_block_q.position = Vector2(screen_width * 0.85, screen_height * 0.5)
		print("Level27: OutputBlockQ positioned at: ", output_block_q.position)

func recount_gates():
	not_gate_count = 0
	dlatch_gate_count = 0
	
	for obj in movable_objects:
		if obj and is_instance_valid(obj):
			var scene_file = obj.scene_file_path
			if scene_file.find("NOTGate") != -1:
				not_gate_count += 1
			elif scene_file.find("DLatchGate") != -1:
				dlatch_gate_count += 1
				
	print("Recounted gates - NOT: ", not_gate_count, ", D-Latch: ", dlatch_gate_count)

func _on_add_not_button_pressed():
	if not_gate_count >= max_not_gates:
		print("Cannot add more NOT gates. Maximum limit reached: ", max_not_gates)
		return
	
	var not_gate = load("res://scenes/gates/base_logic_el/NOTGate.tscn").instantiate()
	var viewport_size = get_viewport().get_visible_rect().size
	not_gate.position = Vector2(viewport_size.x - 600, 200)
	add_child(not_gate)
	movable_objects.append(not_gate)
	not_gate_count += 1
	update_all_logic_objects()
	mark_level_state_dirty()
	update_gate_buttons_state()
	print("NOT gate added. Current count: ", not_gate_count)

func _on_add_dlatch_button_pressed():
	if dlatch_gate_count >= max_dlatch_gates:
		print("Cannot add more D-Latch gates. Maximum limit reached: ", max_dlatch_gates)
		return
	
	var dlatch_gate = load("res://scenes/gates/DLatchGate.tscn").instantiate()
	var viewport_size = get_viewport().get_visible_rect().size
	dlatch_gate.position = Vector2(viewport_size.x - 400, 200)
	add_child(dlatch_gate)
	movable_objects.append(dlatch_gate)
	dlatch_gate_count += 1
	update_all_logic_objects()
	mark_level_state_dirty()
	update_gate_buttons_state()
	print("D-Latch gate added. Current count: ", dlatch_gate_count)

func update_gate_buttons_state():
	var gate_buttons_container = $TopPanel/MainContainer/RightSection/GateButtonsContainer
	var not_button = gate_buttons_container.get_node_or_null("NOT")
	var dlatch_button = gate_buttons_container.get_node_or_null("D_LATCH")
	
	if not_button:
		not_button.disabled = (not_gate_count >= max_not_gates)
		print("NOT button disabled: ", not_button.disabled)
	
	if dlatch_button:
		dlatch_button.disabled = (dlatch_gate_count >= max_dlatch_gates)
		print("D-Latch button disabled: ", dlatch_button.disabled)

# Методы для удаления гейтов
func remove_not_gate():
	if not_gate_count > 0:
		not_gate_count -= 1
		update_gate_buttons_state()
		print("NOT gate removed. Current count: ", not_gate_count)

func remove_dlatch_gate():
	if dlatch_gate_count > 0:
		dlatch_gate_count -= 1
		update_gate_buttons_state()
		print("D-Latch gate removed. Current count: ", dlatch_gate_count)

# Добавляем методы для других типов гейтов, даже если они не используются
func remove_and_gate():
	print("remove_and_gate called on Level27 (not used)")

func remove_xor_gate():
	print("remove_xor_gate called on Level27 (not used)")

func remove_xnor_gate():
	print("remove_xnor_gate called on Level27 (not used)")

func remove_nand_gate():
	print("remove_nand_gate called on Level27 (not used)")

func remove_nor_gate():
	print("remove_nor_gate called on Level27 (not used)")

func remove_sel0_gate():
	print("remove_sel0_gate called on Level27 (not used)")

func remove_sel1_gate():
	print("remove_sel1_gate called on Level27 (not used)")

func remove_or_gate():
	print("remove_or_gate called on Level27 (not used)")

func clear_level():
	super.clear_level()
	not_gate_count = 0
	dlatch_gate_count = 0
	# При очистке уровня также переставляем блоки по краям
	setup_initial_block_positions()
	update_gate_buttons_state()
	print("Level27 cleared - NOT gate count reset to 0, D-Latch gate count reset to 0")

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
	
	print("Level state restored successfully. NOT gates: ", not_gate_count, ", D-Latch gates: ", dlatch_gate_count)
