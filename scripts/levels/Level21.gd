# Level21.gd
extends "res://scripts/levels/LevelEncoder.gd"

var or_gate_count: int = 0
var and_gate_count: int = 0
var not_gate_count: int = 0
var max_or_gates: int = 3
var max_and_gates: int = 2
var max_not_gates: int = 2

func _ready():
	level_data = preload("res://data/level_21_data.tres")
	super._ready()
	
	# Ждем полной инициализации test_results_panel
	await get_tree().process_frame
	
	# Устанавливаем заголовки для энкодера
	if test_results_panel and test_results_panel.has_method("set_titles"):
		test_results_panel.set_titles("Desired O0", "Desired O1", "Current O0", "Current O1")
	
	# Устанавливаем типы выходов для подсветки
	if output_block_o0:
		output_block_o0.output_type = "O0"
	if output_block_o1:
		output_block_o1.output_type = "O1"
	
	# Устанавливаем правильные метки для InputBlock2 (с префиксом "Input ")
	if input_block_i0_i1:
		input_block_i0_i1.input_labels = ["Input I0", "Input I1"]
		print("Level21: Set input labels for I0I1 to ['Input I0', 'Input I1']")
	if input_block_i2_i3:
		input_block_i2_i3.input_labels = ["Input I2", "Input I3"]
		print("Level21: Set input labels for I2I3 to ['Input I2', 'Input I3']")
	
	recount_gates()
	update_gate_buttons_state()

func setup_encoder_level():
	super.setup_encoder_level()
	
	# Устанавливаем правильные метки для входных блоков (с префиксом "Input ")
	if input_block_i0_i1:
		input_block_i0_i1.input_labels = ["Input I0", "Input I1"]
	if input_block_i2_i3:
		input_block_i2_i3.input_labels = ["Input I2", "Input I3"]
		
	# Устанавливаем типы выходов для выходных блоков
	if output_block_o0:
		output_block_o0.output_type = "O0"
	if output_block_o1:
		output_block_o1.output_type = "O1"

func recount_gates():
	or_gate_count = 0
	and_gate_count = 0
	not_gate_count = 0
	
	for obj in movable_objects:
		if obj and is_instance_valid(obj):
			var scene_file = obj.scene_file_path
			if scene_file.find("ORGate") != -1:
				or_gate_count += 1
			elif scene_file.find("ANDGate") != -1:
				and_gate_count += 1
			elif scene_file.find("NOTGate") != -1:
				not_gate_count += 1
	
	print("Recounted gates - OR: ", or_gate_count, ", AND: ", and_gate_count, ", NOT: ", not_gate_count)

func _on_add_or_button_pressed():
	if or_gate_count >= max_or_gates:
		print("Cannot add more OR gates. Maximum limit reached: ", max_or_gates)
		return
	
	print("Adding OR gate")
	var or_gate = preload("res://scenes/gates/base_logic_el/ORGate.tscn").instantiate()
	or_gate.position = Vector2(600, 400)
	add_child(or_gate)
	movable_objects.append(or_gate)
	or_gate_count += 1
	update_all_logic_objects()
	mark_level_state_dirty()
	update_gate_buttons_state()
	print("OR gate added. Current count: ", or_gate_count)

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

func _on_add_not_button_pressed():
	if not_gate_count >= max_not_gates:
		print("Cannot add more NOT gates. Maximum limit reached: ", max_not_gates)
		return
	
	print("Adding NOT gate")
	var not_gate = preload("res://scenes/gates/base_logic_el/NOTGate.tscn").instantiate()
	not_gate.position = Vector2(600, 600)
	add_child(not_gate)
	movable_objects.append(not_gate)
	not_gate_count += 1
	update_all_logic_objects()
	mark_level_state_dirty()
	update_gate_buttons_state()
	print("NOT gate added. Current count: ", not_gate_count)

func update_gate_buttons_state():
	var gate_buttons_container = $TopPanel/GateButtonsContainer
	var or_button = gate_buttons_container.get_node_or_null("OR")
	var and_button = gate_buttons_container.get_node_or_null("AND")
	var not_button = gate_buttons_container.get_node_or_null("NOT")
	
	if or_button:
		or_button.disabled = (or_gate_count >= max_or_gates)
		print("OR button disabled: ", or_button.disabled)
	
	if and_button:
		and_button.disabled = (and_gate_count >= max_and_gates)
		print("AND button disabled: ", and_button.disabled)
		
	if not_button:
		not_button.disabled = (not_gate_count >= max_not_gates)
		print("NOT button disabled: ", not_button.disabled)

# Методы для удаления гейтов
func remove_or_gate():
	if or_gate_count > 0:
		or_gate_count -= 1
		update_gate_buttons_state()
		print("OR gate removed. Current count: ", or_gate_count)

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

# Добавьте методы для других типов гейтов, даже если они не используются
func remove_xor_gate():
	print("remove_xor_gate called on Level21 (not used)")

func remove_xnor_gate():
	print("remove_xnor_gate called on Level21 (not used)")

func remove_nand_gate():
	print("remove_nand_gate called on Level21 (not used)")

func remove_nor_gate():
	print("remove_nor_gate called on Level21 (not used)")

func remove_sel0_gate():
	print("remove_sel0_gate called on Level21 (not used)")

func remove_sel1_gate():
	print("remove_sel1_gate called on Level21 (not used)")

func clear_level():
	super.clear_level()
	or_gate_count = 0
	and_gate_count = 0
	not_gate_count = 0
	update_gate_buttons_state()
	print("Level21 cleared - all gate counts reset to 0")

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
	
	# Устанавливаем правильные метки для InputBlock2 после восстановления
	if input_block_i0_i1:
		input_block_i0_i1.input_labels = ["Input I0", "Input I1"]
	if input_block_i2_i3:
		input_block_i2_i3.input_labels = ["Input I2", "Input I3"]
	
	update_all_logic_objects()
	recount_gates()  # Пересчитываем после восстановления
	update_gate_buttons_state()
	update_all_port_colors()
	
	print("Level state restored successfully. OR gates: ", or_gate_count, ", AND gates: ", and_gate_count, ", NOT gates: ", not_gate_count)

func create_gate_from_data(gate_data):
	var gate_type = gate_data.get("type", "")
	var position_array = gate_data.get("position", [0, 0])
	var position = Vector2(position_array[0], position_array[1])
	
	# Проверяем ограничения для гейтов
	if gate_type == "OR" and or_gate_count >= max_or_gates:
		print("Cannot restore OR gate: maximum limit reached")
		return
	elif gate_type == "AND" and and_gate_count >= max_and_gates:
		print("Cannot restore AND gate: maximum limit reached")
		return
	elif gate_type == "NOT" and not_gate_count >= max_not_gates:
		print("Cannot restore NOT gate: maximum limit reached")
		return
	
	# Проверяем специальные блоки Encoder
	if gate_type == "INPUT_BLOCK_I0I1" and input_block_i0_i1:
		input_block_i0_i1.position = position
		print("Restored InputBlockI0I1 position: ", position)
		return
	elif gate_type == "INPUT_BLOCK_I2I3" and input_block_i2_i3:
		input_block_i2_i3.position = position
		print("Restored InputBlockI2I3 position: ", position)
		return
	elif gate_type == "OUTPUT_BLOCK_O0" and output_block_o0:
		output_block_o0.position = position
		print("Restored OutputBlockO0 position: ", position)
		return
	elif gate_type == "OUTPUT_BLOCK_O1" and output_block_o1:
		output_block_o1.position = position
		print("Restored OutputBlockO1 position: ", position)
		return

	var gate_scene = null
	
	match gate_type:
		"OR":
			gate_scene = preload("res://scenes/gates/base_logic_el/ORGate.tscn")
		"AND":
			gate_scene = preload("res://scenes/gates/base_logic_el/ANDGate.tscn")
		"NOT":
			gate_scene = preload("res://scenes/gates/base_logic_el/NOTGate.tscn")
	
	if gate_scene:
		var gate = gate_scene.instantiate()
		gate.position = position
		add_child(gate)
		movable_objects.append(gate)
		
		# Увеличиваем счетчики
		if gate_type == "OR":
			or_gate_count += 1
		elif gate_type == "AND":
			and_gate_count += 1
		elif gate_type == "NOT":
			not_gate_count += 1
			
		print("Restored gate: ", gate_type, " at ", position)
