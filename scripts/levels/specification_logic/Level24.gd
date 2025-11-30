# Level24.gd
extends "res://scripts/levels/level_templates/LevelDecoder8.gd"

var and_gate_count: int = 0
var not_gate_count: int = 0
var max_and_gates: int = 15
var max_not_gates: int = 4

func _ready():
	level_data = load("res://data/level_24_data.tres")

	if not level_data:
		push_error("Level24: level_data is null!")
		return
	
	print("Level24 data loaded:")
	print("  Input A: ", level_data.input_values_a)
	print("  Input B: ", level_data.input_values_b)
	print("  Input C: ", level_data.input_values_c)
	
	super._ready()
	
	# Устанавливаем метки для входных блоков
	if input_block_a:
		input_block_a.input_label = "Input A"
	if input_block_b:
		input_block_b.input_label = "Input B"
	if input_block_c:
		input_block_c.input_label = "Input C"
	
	# Устанавливаем типы выходных блоков
	for i in range(output_blocks.size()):
		if output_blocks[i]:
			output_blocks[i].output_type = "Y" + str(i)
	
	# Ждем полной инициализации test_results_panel
	await get_tree().process_frame
	
	recount_gates()
	update_gate_buttons_state()

func recount_gates():
	and_gate_count = 0
	not_gate_count = 0
	for obj in movable_objects:
		if obj and is_instance_valid(obj):
			var scene_file = obj.scene_file_path
			if scene_file.find("ANDGate") != -1:
				and_gate_count += 1
			elif scene_file.find("NOTGate") != -1:
				not_gate_count += 1
	print("Recounted gates - AND: ", and_gate_count, ", NOT: ", not_gate_count)

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

func _on_add_not_button_pressed():
	if not_gate_count >= max_not_gates:
		print("Cannot add more NOT gates. Maximum limit reached: ", max_not_gates)
		return
	
	var not_gate = load("res://scenes/gates/base_logic_el/NOTGate.tscn").instantiate()
	not_gate.position = Vector2(600, 500)
	add_child(not_gate)
	movable_objects.append(not_gate)
	not_gate_count += 1
	update_all_logic_objects()
	mark_level_state_dirty()
	update_gate_buttons_state()
	print("NOT gate added. Current count: ", not_gate_count)

func update_gate_buttons_state():
	var gate_buttons_container = $TopPanel/MainContainer/RightSection/GateButtonsContainer
	var and_button = gate_buttons_container.get_node_or_null("AND")
	var not_button = gate_buttons_container.get_node_or_null("NOT")
	
	if and_button:
		and_button.disabled = (and_gate_count >= max_and_gates)
		print("AND button disabled: ", and_button.disabled)
	
	if not_button:
		not_button.disabled = (not_gate_count >= max_not_gates)
		print("NOT button disabled: ", not_button.disabled)

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

func clear_level():
	super.clear_level()
	and_gate_count = 0
	not_gate_count = 0
	update_gate_buttons_state()
	print("Level24 cleared - all gate counts reset to 0")

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
	
	print("Level state restored successfully. AND gates: ", and_gate_count, ", NOT gates: ", not_gate_count)

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
	
	# Проверяем специальные блоки Decoder
	if gate_type == "INPUT_BLOCK_A" and input_block_a:
		input_block_a.position = position
		print("Restored InputBlockA position: ", position)
		return
	elif gate_type == "INPUT_BLOCK_B" and input_block_b:
		input_block_b.position = position
		print("Restored InputBlockB position: ", position)
		return
	elif gate_type == "INPUT_BLOCK_C" and input_block_c:
		input_block_c.position = position
		print("Restored InputBlockC position: ", position)
		return
	elif gate_type.begins_with("OUTPUT_BLOCK_Y") and output_blocks:
		var index_str = gate_type.replace("OUTPUT_BLOCK_Y", "")
		var index = index_str.to_int()
		if index >= 0 and index < output_blocks.size() and output_blocks[index]:
			output_blocks[index].position = position
			print("Restored OutputBlockY", index, " position: ", position)
		return

	var gate_scene = null
	
	match gate_type:
		"AND":
			gate_scene = load("res://scenes/gates/base_logic_el/ANDGate.tscn")
		"NOT":
			gate_scene = load("res://scenes/gates/base_logic_el/NOTGate.tscn")
	
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
			
		print("Restored gate: ", gate_type, " at ", position)

# Добавьте методы для других типов гейтов, даже если они не используются
func remove_xor_gate():
	print("remove_xor_gate called on Level24 (not used)")

func remove_xnor_gate():
	print("remove_xnor_gate called on Level24 (not used)")

func remove_nand_gate():
	print("remove_nand_gate called on Level24 (not used)")

func remove_nor_gate():
	print("remove_nor_gate called on Level24 (not used)")

func remove_sel0_gate():
	print("remove_sel0_gate called on Level24 (not used)")

func remove_sel1_gate():
	print("remove_sel1_gate called on Level24 (not used)")

func remove_or_gate():
	print("remove_or_gate called on Level24 (not used)")
