extends "res://scripts/levels/LevelHalfAdder.gd"

var and_gate_count: int = 0
var xor_gate_count: int = 0
var max_and_gates: int = 2
var max_xor_gates: int = 2

func _ready():
	level_data = preload("res://data/level_13_data.tres")

	if not level_data:
		push_error("Level13: level_data is null!")
		return
	
	print("Level13 data loaded:")
	print("  Input A: ", level_data.input_values_a)
	print("  Input B: ", level_data.input_values_b)
	print("  Expected Sum: ", level_data.expected_sum)
	print("  Expected Carry: ", level_data.expected_carry)
	
	super._ready()
	
	# Ждем полной инициализации test_results_panel
	await get_tree().process_frame
	
	# Устанавливаем заголовки для полусумматора
	if test_results_panel and test_results_panel.has_method("set_titles"):
		# Ждем еще немного чтобы убедиться что панель готова
		await get_tree().process_frame
		test_results_panel.set_titles("Desired SUM", "Desired CARRY", "Current SUM", "Current CARRY")
	
	recount_gates()
	update_gate_buttons_state()

func recount_gates():
	and_gate_count = 0
	xor_gate_count = 0
	for obj in movable_objects:
		if obj and is_instance_valid(obj):
			var scene_file = obj.scene_file_path
			if scene_file.find("ANDGate") != -1:
				and_gate_count += 1
			elif scene_file.find("XORGate") != -1:
				xor_gate_count += 1
	print("Recounted gates - AND: ", and_gate_count, ", XOR: ", xor_gate_count)

func _on_add_and_button_pressed():
	if and_gate_count >= max_and_gates:
		print("Cannot add more AND gates. Maximum limit reached: ", max_and_gates)
		return
	
	var and_gate = preload("res://scenes/gates/base_logic_el/ANDGate.tscn").instantiate()
	and_gate.position = Vector2(600, 400)
	add_child(and_gate)
	movable_objects.append(and_gate)
	and_gate_count += 1
	update_all_logic_objects()
	mark_level_state_dirty()
	update_gate_buttons_state()
	print("AND gate added. Current count: ", and_gate_count)

func _on_add_xor_button_pressed():
	if xor_gate_count >= max_xor_gates:
		print("Cannot add more XOR gates. Maximum limit reached: ", max_xor_gates)
		return
	
	var xor_gate = preload("res://scenes/gates/base_logic_el/XORGate.tscn").instantiate()
	xor_gate.position = Vector2(600, 600)
	add_child(xor_gate)
	movable_objects.append(xor_gate)
	xor_gate_count += 1
	update_all_logic_objects()
	mark_level_state_dirty()
	update_gate_buttons_state()
	print("XOR gate added. Current count: ", xor_gate_count)

func update_gate_buttons_state():
	var gate_buttons_container = $TopPanel/GateButtonsContainer
	var and_button = gate_buttons_container.get_node_or_null("AND")
	var xor_button = gate_buttons_container.get_node_or_null("XOR")
	
	if and_button:
		and_button.disabled = (and_gate_count >= max_and_gates)
		print("AND button disabled: ", and_button.disabled)
	
	if xor_button:
		xor_button.disabled = (xor_gate_count >= max_xor_gates)
		print("XOR button disabled: ", xor_button.disabled)

# Методы для удаления гейтов
func remove_and_gate():
	if and_gate_count > 0:
		and_gate_count -= 1
		update_gate_buttons_state()
		print("AND gate removed. Current count: ", and_gate_count)

func remove_xor_gate():
	if xor_gate_count > 0:
		xor_gate_count -= 1
		update_gate_buttons_state()
		print("XOR gate removed. Current count: ", xor_gate_count)

# Добавьте методы для других типов гейтов, даже если они не используются
func remove_or_gate():
	print("remove_or_gate called on Level13 (not used)")

func remove_not_gate():
	print("remove_not_gate called on Level13 (not used)")

func remove_xnor_gate():
	print("remove_xnor_gate called on Level13 (not used)")

func remove_nand_gate():
	print("remove_nand_gate called on Level13 (not used)")

func remove_nor_gate():
	print("remove_nor_gate called on Level13 (not used)")

func remove_sel0_gate():
	print("remove_sel0_gate called on Level13 (not used)")

func remove_sel1_gate():
	print("remove_sel1_gate called on Level13 (not used)")

func clear_level():
	super.clear_level()
	and_gate_count = 0
	xor_gate_count = 0
	update_gate_buttons_state()
	print("Level13 cleared - AND gate count reset to 0, XOR gate count reset to 0")

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
	
	print("Level state restored successfully. AND gates: ", and_gate_count, ", XOR gates: ", xor_gate_count)

func create_gate_from_data(gate_data):
	var gate_type = gate_data.get("type", "")
	var position_array = gate_data.get("position", [0, 0])
	var position = Vector2(position_array[0], position_array[1])
	
	# Проверяем ограничения для гейтов
	if gate_type == "AND" and and_gate_count >= max_and_gates:
		print("Cannot restore AND gate: maximum limit reached")
		return
	elif gate_type == "XOR" and xor_gate_count >= max_xor_gates:
		print("Cannot restore XOR gate: maximum limit reached")
		return
	
	if gate_type == "INPUT_BLOCK" and has_node("InputBlock"):
		$InputBlock.position = position
		print("Restored InputBlock position: ", position)
		return
	elif gate_type == "OUTPUT_BLOCK_SUM" and has_node("OutputBlockSum"):
		$OutputBlockSum.position = position
		print("Restored OutputBlockSum position: ", position)
		return
	elif gate_type == "OUTPUT_BLOCK_CARRY" and has_node("OutputBlockCarry"):
		$OutputBlockCarry.position = position
		print("Restored OutputBlockCarry position: ", position)
		return

	var gate_scene = null
	
	match gate_type:
		"AND":
			gate_scene = preload("res://scenes/gates/base_logic_el/ANDGate.tscn")
		"XOR":
			gate_scene = preload("res://scenes/gates/base_logic_el/XORGate.tscn")
	
	if gate_scene:
		var gate = gate_scene.instantiate()
		gate.position = position
		add_child(gate)
		movable_objects.append(gate)
		
		# Увеличиваем счетчики
		if gate_type == "AND":
			and_gate_count += 1
		elif gate_type == "XOR":
			xor_gate_count += 1
			
		print("Restored gate: ", gate_type, " at ", position)
