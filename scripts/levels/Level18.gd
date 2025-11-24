# Level18.gd
extends "res://scripts/levels/LevelALU.gd"

# Счетчики и ограничения для уровня 18
var and_gate_count: int = 0
var or_gate_count: int = 0
var xor_gate_count: int = 0
var mux4to1_count: int = 0
var opcode_block_count: int = 0
var max_and_gates: int = 2
var max_or_gates: int = 2
var max_xor_gates: int = 2
var max_mux4to1: int = 1
var max_opcode_blocks: int = 1

func _ready():
	level_data = preload("res://data/level_18_data.tres")
	if not level_data:
		push_error("Level18: level_data is null!")
		return
	
	print("Level18 data loaded:")
	print(" Input A: ", level_data.input_values_a)
	print(" Input B: ", level_data.input_values_b)
	print(" Input Op0: ", level_data.input_values_op0)
	print(" Input Op1: ", level_data.input_values_op1)
	print(" Expected Result: ", level_data.expected_result)
	
	super._ready()
	recount_components()
	update_component_buttons_state()

func recount_components():
	and_gate_count = 0
	or_gate_count = 0
	xor_gate_count = 0
	mux4to1_count = 0
	opcode_block_count = 0
	
	for obj in movable_objects:
		if obj and is_instance_valid(obj):
			var scene_file = obj.scene_file_path
			var obj_type = get_object_type(obj)
			
			print("Found object: ", obj.name, " | Scene: ", scene_file, " | Type: ", obj_type)
			
			if obj_type == "AND":
				and_gate_count += 1
			elif obj_type == "OR":
				or_gate_count += 1
			elif obj_type == "XOR":
				xor_gate_count += 1
			elif obj_type == "MUX4to1":
				mux4to1_count += 1
			elif obj_type == "OpCode":
				opcode_block_count += 1
	
	print("Recounted components - AND: ", and_gate_count, ", OR: ", or_gate_count, ", XOR: ", xor_gate_count, ", MUX4to1: ", mux4to1_count, ", OpCode: ", opcode_block_count)

func update_component_buttons_state():
	var gate_buttons_container = $TopPanel/GateButtonsContainer
	var and_button = gate_buttons_container.get_node_or_null("AND")
	var or_button = gate_buttons_container.get_node_or_null("OR")
	var xor_button = gate_buttons_container.get_node_or_null("XOR")
	var mux_button = gate_buttons_container.get_node_or_null("MUX4to1")
	var opcode_button = gate_buttons_container.get_node_or_null("OpCode")
	
	if and_button:
		and_button.disabled = (and_gate_count >= max_and_gates)
		print("AND button disabled: ", and_button.disabled)
	
	if or_button:
		or_button.disabled = (or_gate_count >= max_or_gates)
		print("OR button disabled: ", or_button.disabled)
	
	if xor_button:
		xor_button.disabled = (xor_gate_count >= max_xor_gates)
		print("XOR button disabled: ", xor_button.disabled)
		
	if mux_button:
		mux_button.disabled = (mux4to1_count >= max_mux4to1)
		print("MUX4to1 button disabled: ", mux_button.disabled)
		
	if opcode_button:
		opcode_button.disabled = (opcode_block_count >= max_opcode_blocks)
		print("OpCode button disabled: ", opcode_button.disabled)

# Методы добавления компонентов с проверкой ограничений
func _on_add_and_button_pressed():
	if and_gate_count >= max_and_gates:
		print("Cannot add more AND gates. Maximum limit reached: ", max_and_gates)
		return
	
	var gate = preload("res://scenes/gates/base_logic_el/ANDGate.tscn").instantiate()
	gate.position = Vector2(600, 400)
	add_child(gate)
	movable_objects.append(gate)
	and_gate_count += 1
	update_all_logic_objects()
	mark_level_state_dirty()
	update_component_buttons_state()
	print("AND gate added. Current count: ", and_gate_count)

func _on_add_or_button_pressed():
	if or_gate_count >= max_or_gates:
		print("Cannot add more OR gates. Maximum limit reached: ", max_or_gates)
		return
	
	var gate = preload("res://scenes/gates/base_logic_el/ORGate.tscn").instantiate()
	gate.position = Vector2(600, 500)
	add_child(gate)
	movable_objects.append(gate)
	or_gate_count += 1
	update_all_logic_objects()
	mark_level_state_dirty()
	update_component_buttons_state()
	print("OR gate added. Current count: ", or_gate_count)

func _on_add_xor_button_pressed():
	if xor_gate_count >= max_xor_gates:
		print("Cannot add more XOR gates. Maximum limit reached: ", max_xor_gates)
		return
	
	var xor_gate = preload("res://scenes/gates/base_logic_el/XORGate.tscn").instantiate()
	xor_gate.position = Vector2(600, 600)
	xor_gate.name = "XORGate_" + str(randi() % 10000)  # Уникальное имя
	add_child(xor_gate)
	movable_objects.append(xor_gate)
	xor_gate_count += 1
	update_all_logic_objects()
	mark_level_state_dirty()
	update_component_buttons_state()
	print("XOR gate added. Current count: ", xor_gate_count)

func _on_add_mux4to1_button_pressed():
	if mux4to1_count >= max_mux4to1:
		print("Cannot add more MUX4to1. Maximum limit reached: ", max_mux4to1)
		return
	
	var gate = preload("res://scenes/gates/MUX4to1.tscn").instantiate()
	gate.position = Vector2(600, 700)
	add_child(gate)
	movable_objects.append(gate)
	mux4to1_count += 1
	update_all_logic_objects()
	mark_level_state_dirty()
	update_component_buttons_state()
	print("MUX4to1 added. Current count: ", mux4to1_count)

func _on_add_opcode_button_pressed():
	if opcode_block_count >= max_opcode_blocks:
		print("Cannot add more OpCode blocks. Maximum limit reached: ", max_opcode_blocks)
		return
	
	var gate = preload("res://scenes/gates/OpCodeBlock.tscn").instantiate()
	gate.position = Vector2(600, 800)
	add_child(gate)
	movable_objects.append(gate)
	opcode_block_count += 1
	update_all_logic_objects()
	mark_level_state_dirty()
	update_component_buttons_state()
	print("OpCodeBlock added. Current count: ", opcode_block_count)

# Методы удаления компонентов
func remove_and_gate():
	if and_gate_count > 0:
		and_gate_count -= 1
		update_component_buttons_state()
		print("AND gate removed. Current count: ", and_gate_count)

func remove_or_gate():
	if or_gate_count > 0:
		or_gate_count -= 1
		update_component_buttons_state()
		print("OR gate removed. Current count: ", or_gate_count)

func remove_xor_gate():
	if xor_gate_count > 0:
		xor_gate_count -= 1
		update_component_buttons_state()
		print("XOR gate removed. Current count: ", xor_gate_count)

func remove_mux4to1():
	if mux4to1_count > 0:
		mux4to1_count -= 1
		update_component_buttons_state()
		print("MUX4to1 removed. Current count: ", mux4to1_count)

func remove_opcode_block():
	if opcode_block_count > 0:
		opcode_block_count -= 1
		update_component_buttons_state()
		print("OpCodeBlock removed. Current count: ", opcode_block_count)

# Методы для других типов гейтов (для совместимости)
func remove_not_gate():
	print("remove_not_gate called on Level18 (not used)")

func remove_xnor_gate():
	print("remove_xnor_gate called on Level18 (not used)")

func remove_nand_gate():
	print("remove_nand_gate called on Level18 (not used)")

func remove_nor_gate():
	print("remove_nor_gate called on Level18 (not used)")

func remove_sel0_gate():
	print("remove_sel0_gate called on Level18 (not used)")

func remove_sel1_gate():
	print("remove_sel1_gate called on Level18 (not used)")

func clear_level():
	super.clear_level()
	and_gate_count = 0
	or_gate_count = 0
	xor_gate_count = 0
	mux4to1_count = 0
	opcode_block_count = 0
	update_component_buttons_state()
	print("Level18 cleared - all component counts reset to 0")

# Level18.gd - улучшенный метод restore_level_state
func restore_level_state(state):
	print("=== Starting level state restoration ===")
	
	# Сначала очищаем уровень
	clear_level()
	
	# Затем восстанавливаем состояние
	if state.has("gates"):
		print("Restoring ", state["gates"].size(), " gates")
		for gate_data in state["gates"]:
			create_gate_from_data(gate_data)
	else:
		print("No gates data found in save state")
	
	if state.has("wires"):
		print("Restoring ", state["wires"].size(), " wires")
		for wire_data in state["wires"]:
			create_wire_from_data(wire_data)
	else:
		print("No wires data found in save state")
	
	update_all_logic_objects()
	recount_components()  # Пересчитываем после восстановления
	update_component_buttons_state()
	update_all_port_colors()
	
	print("Level state restored successfully.")
	print("Final counts - AND: ", and_gate_count, ", OR: ", or_gate_count, ", XOR: ", xor_gate_count, ", MUX4to1: ", mux4to1_count, ", OpCode: ", opcode_block_count)
	print("Movable objects count: ", movable_objects.size())
	print("All logic objects count: ", all_logic_objects.size())

func create_gate_from_data(gate_data):
	var gate_type = gate_data.get("type", "")
	var position_array = gate_data.get("position", [0, 0])
	var position = Vector2(position_array[0], position_array[1])
	
	print("Attempting to restore gate: ", gate_type, " at position: ", position)
	
	# Проверяем ограничения перед созданием гейта
	if gate_type == "AND" and and_gate_count >= max_and_gates:
		print("Cannot restore AND gate: maximum limit reached (", and_gate_count, "/", max_and_gates, ")")
		return
	elif gate_type == "OR" and or_gate_count >= max_or_gates:
		print("Cannot restore OR gate: maximum limit reached (", or_gate_count, "/", max_or_gates, ")")
		return
	elif gate_type == "XOR" and xor_gate_count >= max_xor_gates:
		print("Cannot restore XOR gate: maximum limit reached (", xor_gate_count, "/", max_xor_gates, ")")
		return
	elif gate_type == "MUX4to1" and mux4to1_count >= max_mux4to1:
		print("Cannot restore MUX4to1: maximum limit reached (", mux4to1_count, "/", max_mux4to1, ")")
		return
	elif gate_type == "OpCode" and opcode_block_count >= max_opcode_blocks:
		print("Cannot restore OpCodeBlock: maximum limit reached (", opcode_block_count, "/", max_opcode_blocks, ")")
		return
	
	# Пропускаем специальные блоки ALU, они обрабатываются в родительском классе
	if gate_type == "INPUT_BLOCK_AB" and input_block_ab:
		input_block_ab.position = position
		print("Restored InputBlockAB position: ", position)
		return
	elif gate_type == "OUTPUT_BLOCK" and output_block:
		output_block.position = position
		print("Restored OutputBlock position: ", position)
		return
	
	var gate_scene = null
	var gate_name = ""
	
	match gate_type:
		"AND": 
			gate_scene = preload("res://scenes/gates/base_logic_el/ANDGate.tscn")
			gate_name = "ANDGate"
		"OR": 
			gate_scene = preload("res://scenes/gates/base_logic_el/ORGate.tscn")
			gate_name = "ORGate"
		"XOR": 
			gate_scene = preload("res://scenes/gates/base_logic_el/XORGate.tscn")
			gate_name = "XORGate"
		"MUX4to1": 
			gate_scene = preload("res://scenes/gates/MUX4to1.tscn")
			gate_name = "MUX4to1"
		"OpCode": 
			gate_scene = preload("res://scenes/gates/OpCodeBlock.tscn")
			gate_name = "OpCodeBlock"
	
	if gate_scene:
		var gate = gate_scene.instantiate()
		gate.position = position
		gate.name = gate_name + "_" + str(randi() % 10000)  # Уникальное имя
		add_child(gate)
		movable_objects.append(gate)
		
		# Увеличиваем счетчики
		if gate_type == "AND":
			and_gate_count += 1
		elif gate_type == "XOR":
			xor_gate_count += 1
		elif gate_type == "OR":
			or_gate_count += 1
		elif gate_type == "MUX4to1":
			mux4to1_count += 1
		elif gate_type == "OpCode":
			opcode_block_count += 1
		
		print("Successfully restored gate: ", gate_type, " at ", position, " (Count: ", and_gate_count, " AND, ", or_gate_count, " OR, ", xor_gate_count, " XOR)")
		
		if gate.has_method("reset_inputs"):
			gate.reset_inputs()
	else:
		print("WARNING: Could not find scene for gate type: ", gate_type)
