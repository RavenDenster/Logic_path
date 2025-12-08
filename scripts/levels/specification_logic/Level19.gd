# Level19.gd
extends "res://scripts/levels/level_templates/LevelComparator.gd"

var and_gate_count: int = 0
var not_gate_count: int = 0
var xnor_gate_count: int = 0
var max_and_gates: int = 2
var max_not_gates: int = 2
var max_xnor_gates: int = 2

func _ready():
	level_data = load("res://data/level_19_data.tres")

	if not level_data:
		push_error("Level19: level_data is null!")
		return
	
	print("Level19 data loaded:")
	print("  Input A: ", level_data.input_values_a)
	print("  Input B: ", level_data.input_values_b)
	print("  Expected A>B: ", level_data.expected_agtb)
	print("  Expected A<B: ", level_data.expected_altb)
	print("  Expected A==B: ", level_data.expected_aeqb)
	
	super._ready()
	
	# Автоматически располагаем блоки по краям экрана
	setup_initial_block_positions()
	
	# Ждем полной инициализации test_results_panel
	await get_tree().process_frame
	
	# Устанавливаем заголовки для компаратора
	if test_results_panel and test_results_panel.has_method("set_titles"):
		test_results_panel.set_titles("Desired A>B", "Desired A<B", "Desired A==B", "Current A>B", "Current A<B", "Current A==B")
	
	# Устанавливаем типы выходов для подсветки
	if output_block_agtb:
		output_block_agtb.output_type = "A>B"
	if output_block_altb:
		output_block_altb.output_type = "A<B"
	if output_block_aeqb:
		output_block_aeqb.output_type = "A==B"
	
	# Устанавливаем метки для входного блока
	if input_block_ab:
		input_block_ab.input_labels = ["Input A", "Input B"]
	
	recount_gates()
	update_gate_buttons_state()

func setup_initial_block_positions():
	var viewport_rect = get_viewport().get_visible_rect()
	var screen_width = viewport_rect.size.x
	var screen_height = viewport_rect.size.y
	
	# Располагаем InputBlockAB слева (15% от ширины, по центру по вертикали)
	var input_block_ab = get_node_or_null("InputBlockAB")
	if input_block_ab:
		input_block_ab.position = Vector2(screen_width * 0.15, screen_height * 0.5)
		print("Level19: InputBlockAB positioned at: ", input_block_ab.position)
	
	# Располагаем выходные блоки справа (85% от ширины экрана)
	# Используем правильные имена: OutputBlock, OutputBlock2, OutputBlock3
	# Равномерно распределяем по вертикали
	var output_block = get_node_or_null("OutputBlock")
	if output_block:
		output_block.position = Vector2(screen_width * 0.85, screen_height * 0.3)
		print("Level19: OutputBlock (A>B) positioned at: ", output_block.position)
		output_block.output_type = "A>B"
	
	var output_block2 = get_node_or_null("OutputBlock2")
	if output_block2:
		output_block2.position = Vector2(screen_width * 0.85, screen_height * 0.5)
		print("Level19: OutputBlock2 (A<B) positioned at: ", output_block2.position)
		output_block2.output_type = "A<B"
	
	var output_block3 = get_node_or_null("OutputBlock3")
	if output_block3:
		output_block3.position = Vector2(screen_width * 0.85, screen_height * 0.7)
		print("Level19: OutputBlock3 (A==B) positioned at: ", output_block3.position)
		output_block3.output_type = "A==B"

func setup_comparator_level():
	super.setup_comparator_level()
	
	# Устанавливаем метки для входного блока
	if input_block_ab:
		input_block_ab.input_labels = ["Input A", "Input B"]
		
	# Устанавливаем типы выходов для выходных блоков
	if has_node("OutputBlock"):
		get_node("OutputBlock").output_type = "A>B"
	if has_node("OutputBlock2"):
		get_node("OutputBlock2").output_type = "A<B"
	if has_node("OutputBlock3"):
		get_node("OutputBlock3").output_type = "A==B"

func recount_gates():
	and_gate_count = 0
	not_gate_count = 0
	xnor_gate_count = 0
	
	for obj in movable_objects:
		if obj and is_instance_valid(obj):
			var scene_file = obj.scene_file_path
			if scene_file.find("ANDGate") != -1:
				and_gate_count += 1
			elif scene_file.find("NOTGate") != -1:
				not_gate_count += 1
			elif scene_file.find("XNORGate") != -1:
				xnor_gate_count += 1
	
	print("Recounted gates - AND: ", and_gate_count, ", NOT: ", not_gate_count, ", XNOR: ", xnor_gate_count)

func _on_add_and_button_pressed():
	if and_gate_count >= max_and_gates:
		print("Cannot add more AND gates. Maximum limit reached: ", max_and_gates)
		return
	
	var and_gate = load("res://scenes/gates/base_logic_el/ANDGate.tscn").instantiate()
	var viewport_size = get_viewport().get_visible_rect().size
	and_gate.position = Vector2(viewport_size.x - 600, 150)
	add_child(and_gate)
	movable_objects.append(and_gate)
	and_gate_count += 1
	update_all_logic_objects()
	mark_level_state_dirty()
	update_gate_buttons_state()
	print("AND gate added. Current count: ", and_gate_count)

func _on_add_not_button_pressed():
	if not_gate_count >= max_not_gates:
		print("Cannot add more NOT gates. Maximum limit reached: ", max_not_gates)
		return
	
	var not_gate = load("res://scenes/gates/base_logic_el/NOTGate.tscn").instantiate()
	var viewport_size = get_viewport().get_visible_rect().size
	not_gate.position = Vector2(viewport_size.x - 400, 150)
	add_child(not_gate)
	movable_objects.append(not_gate)
	not_gate_count += 1
	update_all_logic_objects()
	mark_level_state_dirty()
	update_gate_buttons_state()
	print("NOT gate added. Current count: ", not_gate_count)

func _on_add_nxor_button_pressed():
	if xnor_gate_count >= max_xnor_gates:
		print("Cannot add more XNOR gates. Maximum limit reached: ", max_xnor_gates)
		return
	
	var xnor_gate = load("res://scenes/gates/base_logic_el/XNORGate.tscn").instantiate()
	var viewport_size = get_viewport().get_visible_rect().size
	xnor_gate.position = Vector2(viewport_size.x - 200, 150)
	add_child(xnor_gate)
	movable_objects.append(xnor_gate)
	xnor_gate_count += 1
	update_all_logic_objects()
	mark_level_state_dirty()
	update_gate_buttons_state()
	print("XNOR gate added. Current count: ", xnor_gate_count)

func update_gate_buttons_state():
	var gate_buttons_container = $TopPanel/MainContainer/RightSection/GateButtonsContainer
	var and_button = gate_buttons_container.get_node_or_null("AND")
	var not_button = gate_buttons_container.get_node_or_null("NOT")
	var xnor_button = gate_buttons_container.get_node_or_null("XNOR")
	
	if and_button:
		and_button.disabled = (and_gate_count >= max_and_gates)
		print("AND button disabled: ", and_button.disabled)
	
	if not_button:
		not_button.disabled = (not_gate_count >= max_not_gates)
		print("NOT button disabled: ", not_button.disabled)
		
	if xnor_button:
		xnor_button.disabled = (xnor_gate_count >= max_xnor_gates)
		print("XNOR button disabled: ", xnor_button.disabled)

# Методы для удаления гейтов
func remove_and_gate():
	if and_gate_count > 0:
		and_gate_count -= 1
		update_gate_buttons_state()
		print("AND gate removed. Current count: ", and_gate_count)

func remove_not_gate():
	if not_gate_count > 0:
		not_gate_count -= 1
		update_gate_buttons_state()
		print("NOT gate removed. Current count: ", not_gate_count)

func remove_xnor_gate():
	if xnor_gate_count > 0:
		xnor_gate_count -= 1
		update_gate_buttons_state()
		print("XNOR gate removed. Current count: ", xnor_gate_count)

# Добавьте методы для других типов гейтов, даже если они не используются
func remove_xor_gate():
	print("remove_xor_gate called on Level19 (not used)")

func remove_or_gate():
	print("remove_or_gate called on Level19 (not used)")

func remove_nand_gate():
	print("remove_nand_gate called on Level19 (not used)")

func remove_nor_gate():
	print("remove_nor_gate called on Level19 (not used)")

func remove_sel0_gate():
	print("remove_sel0_gate called on Level19 (not used)")

func remove_sel1_gate():
	print("remove_sel1_gate called on Level19 (not used)")

func clear_level():
	super.clear_level()
	and_gate_count = 0
	not_gate_count = 0
	xnor_gate_count = 0
	# При очистке уровня также переставляем блоки по краям
	setup_initial_block_positions()
	update_gate_buttons_state()
	print("Level19 cleared - all gate counts reset to 0")

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
	
	print("Level state restored successfully. AND gates: ", and_gate_count, ", NOT gates: ", not_gate_count, ", XNOR gates: ", xnor_gate_count)

func create_gate_from_data(gate_data):
	var gate_type = gate_data.get("type", "")
	var position_array = gate_data.get("position", [0, 0])
	var position = Vector2(position_array[0], position_array[1])
	
	# Проверяем ограничения для гейтов
	if gate_type == "AND" and and_gate_count >= max_and_gates:
		print("Cannot restore AND gate: maximum limit reached")
		return
	elif gate_type == "NOT" and not_gate_count >= max_not_gates:
		print("Cannot restore NOT gate: maximum limit reached")
		return
	elif gate_type == "XNOR" and xnor_gate_count >= max_xnor_gates:
		print("Cannot restore XNOR gate: maximum limit reached")
		return
	
	# Проверяем специальные блоки Comparator
	if gate_type == "INPUT_BLOCK_AB" and has_node("InputBlockAB"):
		$InputBlockAB.position = position
		print("Restored InputBlockAB position: ", position)
		return
	elif gate_type == "OUTPUT_BLOCK_AGTB" and has_node("OutputBlock"):
		$OutputBlock.position = position
		print("Restored OutputBlock (A>B) position: ", position)
		return
	elif gate_type == "OUTPUT_BLOCK_ALTB" and has_node("OutputBlock2"):
		$OutputBlock2.position = position
		print("Restored OutputBlock2 (A<B) position: ", position)
		return
	elif gate_type == "OUTPUT_BLOCK_AEQB" and has_node("OutputBlock3"):
		$OutputBlock3.position = position
		print("Restored OutputBlock3 (A==B) position: ", position)
		return

	var gate_scene = null
	
	match gate_type:
		"AND":
			gate_scene = load("res://scenes/gates/base_logic_el/ANDGate.tscn")
		"NOT":
			gate_scene = load("res://scenes/gates/base_logic_el/NOTGate.tscn")
		"XNOR":
			gate_scene = load("res://scenes/gates/base_logic_el/XNORGate.tscn")
	
	if gate_scene:
		var gate = gate_scene.instantiate()
		gate.position = position
		add_child(gate)
		movable_objects.append(gate)
		
		# Увеличиваем счетчики
		if gate_type == "AND":
			and_gate_count += 1
		elif gate_type == "NOT":
			not_gate_count += 1
		elif gate_type == "XNOR":
			xnor_gate_count += 1
			
		print("Restored gate: ", gate_type, " at ", position)