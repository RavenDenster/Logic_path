# Level14.gd
extends "res://scripts/levels/level_templates/LevelFullAdder.gd"

var and_gate_count: int = 0
var xor_gate_count: int = 0
var or_gate_count: int = 0
var max_and_gates: int = 2
var max_xor_gates: int = 2
var max_or_gates: int = 2

func _ready():
	level_data = load("res://data/level_14_data.tres")

	if not level_data:
		push_error("Level14: level_data is null!")
		return
	
	print("Level14 data loaded:")
	print("  Input A: ", level_data.input_values_a)
	print("  Input B: ", level_data.input_values_b)
	print("  Input Cin: ", level_data.input_values_cin)
	print("  Expected Sum: ", level_data.expected_sum)
	print("  Expected Cout: ", level_data.expected_cout)
	
	super._ready()
	
	# Явно устанавливаем заголовки для полного сумматора (опционально)
	if test_results_panel and test_results_panel.has_method("set_titles"):
		test_results_panel.set_titles("Desired SUM", "Desired COUT", "Current SUM", "Current COUT")
	
	recount_gates()
	update_gate_buttons_state()

func recount_gates():
	and_gate_count = 0
	xor_gate_count = 0
	or_gate_count = 0
	for obj in movable_objects:
		if obj and is_instance_valid(obj):
			var scene_file = obj.scene_file_path
			if scene_file.find("ANDGate") != -1:
				and_gate_count += 1
			elif scene_file.find("XORGate") != -1:
				xor_gate_count += 1
			elif scene_file.find("ORGate") != -1:
				or_gate_count += 1
	print("Recounted gates - AND: ", and_gate_count, ", XOR: ", xor_gate_count, ", OR: ", or_gate_count)

func _on_add_and_button_pressed():
	if and_gate_count >= max_and_gates:
		print("Cannot add more AND gates. Maximum limit reached: ", max_and_gates)
		return
	
	var and_gate = load("res://scenes/gates/base_logic_el/ANDGate.tscn").instantiate()
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
	
	var xor_gate = load("res://scenes/gates/base_logic_el/XORGate.tscn").instantiate()
	xor_gate.position = Vector2(600, 600)
	add_child(xor_gate)
	movable_objects.append(xor_gate)
	xor_gate_count += 1
	update_all_logic_objects()
	mark_level_state_dirty()
	update_gate_buttons_state()
	print("XOR gate added. Current count: ", xor_gate_count)

func _on_add_or_button_pressed():
	if or_gate_count >= max_or_gates:
		print("Cannot add more OR gates. Maximum limit reached: ", max_or_gates)
		return
	
	var or_gate = load("res://scenes/gates/base_logic_el/ORGate.tscn").instantiate()
	or_gate.position = Vector2(600, 800)
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
	var xor_button = gate_buttons_container.get_node_or_null("XOR")
	var or_button = gate_buttons_container.get_node_or_null("OR")
	
	if and_button:
		and_button.disabled = (and_gate_count >= max_and_gates)
		print("AND button disabled: ", and_button.disabled)
	
	if xor_button:
		xor_button.disabled = (xor_gate_count >= max_xor_gates)
		print("XOR button disabled: ", xor_button.disabled)
	
	if or_button:
		or_button.disabled = (or_gate_count >= max_or_gates)
		print("OR button disabled: ", or_button.disabled)

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

func remove_or_gate():
	if or_gate_count > 0:
		or_gate_count -= 1
		update_gate_buttons_state()
		print("OR gate removed. Current count: ", or_gate_count)

# Добавьте методы для других типов гейтов, даже если они не используются
func remove_not_gate():
	print("remove_not_gate called on Level14 (not used)")

func remove_xnor_gate():
	print("remove_xnor_gate called on Level14 (not used)")

func remove_nand_gate():
	print("remove_nand_gate called on Level14 (not used)")

func remove_nor_gate():
	print("remove_nor_gate called on Level14 (not used)")

func remove_sel0_gate():
	print("remove_sel0_gate called on Level14 (not used)")

func remove_sel1_gate():
	print("remove_sel1_gate called on Level14 (not used)")

func clear_level():
	super.clear_level()
	and_gate_count = 0
	xor_gate_count = 0
	or_gate_count = 0
	update_gate_buttons_state()
	print("Level14 cleared - AND gate count reset to 0, XOR gate count reset to 0, OR gate count reset to 0")

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
	
	print("Level state restored successfully. AND gates: ", and_gate_count, ", XOR gates: ", xor_gate_count, ", OR gates: ", or_gate_count)

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
	elif gate_type == "OR" and or_gate_count >= max_or_gates:
		print("Cannot restore OR gate: maximum limit reached")
		return
	
	# Проверяем специальные блоки Full Adder
	if gate_type == "INPUT_BLOCK_A" and input_block_a:
		input_block_a.position = position
		print("Restored InputBlockA position: ", position)
		return
	elif gate_type == "INPUT_BLOCK_B" and input_block_b:
		input_block_b.position = position
		print("Restored InputBlockB position: ", position)
		return
	elif gate_type == "INPUT_BLOCK_CIN" and input_block_cin:
		input_block_cin.position = position
		print("Restored InputBlockCin position: ", position)
		return
	elif gate_type == "OUTPUT_BLOCK_SUM" and output_block_sum:
		output_block_sum.position = position
		print("Restored OutputBlockSum position: ", position)
		return
	elif gate_type == "OUTPUT_BLOCK_COUT" and output_block_cout:
		output_block_cout.position = position
		print("Restored OutputBlockCout position: ", position)
		return

	var gate_scene = null
	
	match gate_type:
		"AND":
			gate_scene = load("res://scenes/gates/base_logic_el/ANDGate.tscn")
		"XOR":
			gate_scene = load("res://scenes/gates/base_logic_el/XORGate.tscn")
		"OR":
			gate_scene = load("res://scenes/gates/base_logic_el/ORGate.tscn")
	
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
		elif gate_type == "OR":
			or_gate_count += 1
			
		print("Restored gate: ", gate_type, " at ", position)
