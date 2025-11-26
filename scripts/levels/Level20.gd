# Level20.gd
extends "res://scripts/levels/LevelComparator2.gd"

var and_gate_count: int = 0
var or_gate_count: int = 0
var comparator_gate_count: int = 0
var max_and_gates: int = 4
var max_or_gates: int = 3
var max_comparator_gates: int = 2

func _ready():
	level_data = preload("res://data/level_20_data.tres")

	if not level_data:
		push_error("Level20: level_data is null!")
		return
	
	print("Level20 data loaded:")
	print("  Input A1: ", level_data.input_values_a1)
	print("  Input A0: ", level_data.input_values_a0)
	print("  Input B1: ", level_data.input_values_b1)
	print("  Input B0: ", level_data.input_values_b0)
	print("  Expected A>B: ", level_data.expected_agtb)
	print("  Expected A<B: ", level_data.expected_altb)
	print("  Expected A==B: ", level_data.expected_aeqb)
	
	super._ready()
	
	# Ждем полной инициализации test_results_panel
	await get_tree().process_frame
	
	# Устанавливаем заголовки для 2-битного компаратора
	if test_results_panel and test_results_panel.has_method("set_titles"):
		test_results_panel.set_titles("Desired A>B", "Desired A<B", "Desired A==B", "Current A>B", "Current A<B", "Current A==B")
	
	# Устанавливаем типы выходов для подсветки
	if output_block_agtb:
		output_block_agtb.output_type = "A>B"
	if output_block_altb:
		output_block_altb.output_type = "A<B"
	if output_block_aeqb:
		output_block_aeqb.output_type = "A==B"
	
	# Устанавливаем метки для входных блоков - используем простые метки для совместимости
	if input_block_a:
		input_block_a.input_labels = ["A1", "A0"]
	if input_block_b:
		input_block_b.input_labels = ["B1", "B0"]
	
	recount_gates()
	update_gate_buttons_state()

func setup_comparator2_level():
	super.setup_comparator2_level()
	
	# Устанавливаем метки для входных блоков - используем простые метки для совместимости
	if input_block_a:
		input_block_a.input_labels = ["A1", "A0"]
	if input_block_b:
		input_block_b.input_labels = ["B1", "B0"]
		
	# Устанавливаем типы выходов для выходных блоков
	if output_block_agtb:
		output_block_agtb.output_type = "A>B"
	if output_block_altb:
		output_block_altb.output_type = "A<B"
	if output_block_aeqb:
		output_block_aeqb.output_type = "A==B"

func recount_gates():
	and_gate_count = 0
	or_gate_count = 0
	comparator_gate_count = 0
	
	for obj in movable_objects:
		if obj and is_instance_valid(obj):
			var scene_file = obj.scene_file_path
			if scene_file.find("ANDGate") != -1:
				and_gate_count += 1
			elif scene_file.find("ORGate") != -1:
				or_gate_count += 1
			elif scene_file.find("OneBitComparatorGate") != -1:
				comparator_gate_count += 1
	
	print("Recounted gates - AND: ", and_gate_count, ", OR: ", or_gate_count, ", Comparator: ", comparator_gate_count)

func _on_add_comparator_button_pressed():
	if comparator_gate_count >= max_comparator_gates:
		print("Cannot add more Comparator gates. Maximum limit reached: ", max_comparator_gates)
		return
	
	print("Adding 1-bit Comparator")
	var comparator = preload("res://scenes/gates/OneBitComparatorGate.tscn").instantiate()
	comparator.position = Vector2(600, 400)
	add_child(comparator)
	movable_objects.append(comparator)
	comparator_gate_count += 1
	update_all_logic_objects()
	mark_level_state_dirty()
	update_gate_buttons_state()
	print("Comparator gate added. Current count: ", comparator_gate_count)

func _on_add_and_button_pressed():
	if and_gate_count >= max_and_gates:
		print("Cannot add more AND gates. Maximum limit reached: ", max_and_gates)
		return
	
	print("Adding AND gate")
	var and_gate = preload("res://scenes/gates/base_logic_el/ANDGate.tscn").instantiate()
	and_gate.position = Vector2(600, 500)
	add_child(and_gate)
	movable_objects.append(and_gate)
	and_gate_count += 1
	update_all_logic_objects()
	mark_level_state_dirty()
	update_gate_buttons_state()
	print("AND gate added. Current count: ", and_gate_count)

func _on_add_or_button_pressed():
	if or_gate_count >= max_or_gates:
		print("Cannot add more OR gates. Maximum limit reached: ", max_or_gates)
		return
	
	print("Adding OR gate")
	var or_gate = preload("res://scenes/gates/base_logic_el/ORGate.tscn").instantiate()
	or_gate.position = Vector2(600, 600)
	add_child(or_gate)
	movable_objects.append(or_gate)
	or_gate_count += 1
	update_all_logic_objects()
	mark_level_state_dirty()
	update_gate_buttons_state()
	print("OR gate added. Current count: ", or_gate_count)

func update_gate_buttons_state():
	var gate_buttons_container = $TopPanel/GateButtonsContainer
	var and_button = gate_buttons_container.get_node_or_null("AND")
	var or_button = gate_buttons_container.get_node_or_null("OR")
	var comparator_button = gate_buttons_container.get_node_or_null("OneBitComparator")
	
	if and_button:
		and_button.disabled = (and_gate_count >= max_and_gates)
		print("AND button disabled: ", and_button.disabled)
	
	if or_button:
		or_button.disabled = (or_gate_count >= max_or_gates)
		print("OR button disabled: ", or_button.disabled)
		
	if comparator_button:
		comparator_button.disabled = (comparator_gate_count >= max_comparator_gates)
		print("Comparator button disabled: ", comparator_button.disabled)

# Методы для удаления гейтов
func remove_and_gate():
	if and_gate_count > 0:
		and_gate_count -= 1
		update_gate_buttons_state()
		print("AND gate removed. Current count: ", and_gate_count)

func remove_or_gate():
	if or_gate_count > 0:
		or_gate_count -= 1
		update_gate_buttons_state()
		print("OR gate removed. Current count: ", or_gate_count)

func remove_comparator_gate():
	if comparator_gate_count > 0:
		comparator_gate_count -= 1
		update_gate_buttons_state()
		print("Comparator gate removed. Current count: ", comparator_gate_count)

# Добавьте методы для других типов гейтов, даже если они не используются
func remove_xor_gate():
	print("remove_xor_gate called on Level20 (not used)")

func remove_not_gate():
	print("remove_not_gate called on Level20 (not used)")

func remove_xnor_gate():
	print("remove_xnor_gate called on Level20 (not used)")

func remove_nand_gate():
	print("remove_nand_gate called on Level20 (not used)")

func remove_nor_gate():
	print("remove_nor_gate called on Level20 (not used)")

func remove_sel0_gate():
	print("remove_sel0_gate called on Level20 (not used)")

func remove_sel1_gate():
	print("remove_sel1_gate called on Level20 (not used)")

func clear_level():
	super.clear_level()
	and_gate_count = 0
	or_gate_count = 0
	comparator_gate_count = 0
	update_gate_buttons_state()
	print("Level20 cleared - all gate counts reset to 0")

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
	
	print("Level state restored successfully. AND gates: ", and_gate_count, ", OR gates: ", or_gate_count, ", Comparator gates: ", comparator_gate_count)

func create_gate_from_data(gate_data):
	var gate_type = gate_data.get("type", "")
	var position_array = gate_data.get("position", [0, 0])
	var position = Vector2(position_array[0], position_array[1])
	var gate_name = gate_data.get("name", "")
	
	# Проверяем ограничения для гейтов
	if gate_type == "AND" and and_gate_count >= max_and_gates:
		print("Cannot restore AND gate: maximum limit reached")
		return
	elif gate_type == "OR" and or_gate_count >= max_or_gates:
		print("Cannot restore OR gate: maximum limit reached")
		return
	elif gate_type == "OneBitComparator" and comparator_gate_count >= max_comparator_gates:
		print("Cannot restore Comparator gate: maximum limit reached")
		return
	
	# Проверяем специальные блоки 2-битного компаратора
	if gate_type == "INPUT_BLOCK_A" and input_block_a:
		input_block_a.position = position
		if gate_name != "":
			input_block_a.name = gate_name
		print("Restored InputBlockA position: ", position)
		return
	elif gate_type == "INPUT_BLOCK_B" and input_block_b:
		input_block_b.position = position
		if gate_name != "":
			input_block_b.name = gate_name
		print("Restored InputBlockB position: ", position)
		return
	elif gate_type == "OUTPUT_BLOCK_AGTB" and output_block_agtb:
		output_block_agtb.position = position
		if gate_name != "":
			output_block_agtb.name = gate_name
		print("Restored OutputBlockAgtb position: ", position)
		return
	elif gate_type == "OUTPUT_BLOCK_ALTB" and output_block_altb:
		output_block_altb.position = position
		if gate_name != "":
			output_block_altb.name = gate_name
		print("Restored OutputBlockAltb position: ", position)
		return
	elif gate_type == "OUTPUT_BLOCK_AEQB" and output_block_aeqb:
		output_block_aeqb.position = position
		if gate_name != "":
			output_block_aeqb.name = gate_name
		print("Restored OutputBlockAeqb position: ", position)
		return

	var gate_scene = null
	
	match gate_type:
		"AND":
			gate_scene = preload("res://scenes/gates/base_logic_el/ANDGate.tscn")
		"OR":
			gate_scene = preload("res://scenes/gates/base_logic_el/ORGate.tscn")
		"OneBitComparator":
			gate_scene = preload("res://scenes/gates/OneBitComparatorGate.tscn")
	
	if gate_scene:
		var gate = gate_scene.instantiate()
		gate.position = position
		if gate_name != "":
			gate.name = gate_name
		
		add_child(gate)
		movable_objects.append(gate)
		
		# Увеличиваем счетчики
		if gate_type == "AND":
			and_gate_count += 1
		elif gate_type == "OR":
			or_gate_count += 1
		elif gate_type == "OneBitComparator":
			comparator_gate_count += 1
			
		print("Restored gate: ", gate_type, " at ", position)
