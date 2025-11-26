# Level15.gd
extends "res://scripts/levels/level_templates/Level2bitAdder.gd"

var half_adder_count: int = 0
var full_adder_count: int = 0
var cout0_count: int = 0
var max_half_adders: int = 2
var max_full_adders: int = 2
var max_cout0: int = 2

func _ready():
	level_data = preload("res://data/level_15_data.tres")

	if not level_data:
		push_error("Level15: level_data is null!")
		return
	
	print("Level15 data loaded:")
	print("  Input A1: ", level_data.input_values_a1)
	print("  Input A0: ", level_data.input_values_a0)
	print("  Input B1: ", level_data.input_values_b1)
	print("  Input B0: ", level_data.input_values_b0)
	print("  Expected S1: ", level_data.expected_s1)
	print("  Expected S0: ", level_data.expected_s0)
	print("  Expected Cout: ", level_data.expected_cout)
	
	super._ready()
	recount_components()
	update_component_buttons_state()

func recount_components():
	half_adder_count = 0
	full_adder_count = 0
	cout0_count = 0
	for obj in movable_objects:
		if obj and is_instance_valid(obj):
			var scene_file = obj.scene_file_path
			if scene_file.find("HalfAdder") != -1:
				half_adder_count += 1
			elif scene_file.find("FullAdder") != -1:
				full_adder_count += 1
			elif scene_file.find("Cout0") != -1:
				cout0_count += 1
	print("Recounted components - HalfAdders: ", half_adder_count, ", FullAdders: ", full_adder_count, ", Cout0: ", cout0_count)

func _on_add_half_adder_button_pressed():
	if half_adder_count >= max_half_adders:
		print("Cannot add more Half Adders. Maximum limit reached: ", max_half_adders)
		return
	
	var half_adder = preload("res://scenes/gates/HalfAdder.tscn").instantiate()
	half_adder.position = Vector2(600, 400)
	add_child(half_adder)
	movable_objects.append(half_adder)
	half_adder_count += 1
	update_all_logic_objects()
	mark_level_state_dirty()
	update_component_buttons_state()
	print("Half Adder added. Current count: ", half_adder_count)

func _on_add_full_adder_button_pressed():
	if full_adder_count >= max_full_adders:
		print("Cannot add more Full Adders. Maximum limit reached: ", max_full_adders)
		return
	
	var full_adder = preload("res://scenes/gates/FullAdder.tscn").instantiate()
	full_adder.position = Vector2(600, 600)
	add_child(full_adder)
	movable_objects.append(full_adder)
	full_adder_count += 1
	update_all_logic_objects()
	mark_level_state_dirty()
	update_component_buttons_state()
	print("Full Adder added. Current count: ", full_adder_count)

func _on_add_cout0_button_pressed():
	if cout0_count >= max_cout0:
		print("Cannot add more Cout0. Maximum limit reached: ", max_cout0)
		return
	
	var cout0 = preload("res://scenes/gates/Cout0.tscn").instantiate()
	cout0.position = Vector2(600, 800)
	add_child(cout0)
	movable_objects.append(cout0)
	cout0_count += 1
	update_all_logic_objects()
	mark_level_state_dirty()
	update_component_buttons_state()
	print("Cout0 added. Current count: ", cout0_count)

func update_component_buttons_state():
	var gate_buttons_container = $TopPanel/GateButtonsContainer
	var half_adder_button = gate_buttons_container.get_node_or_null("HALF_ADDER")
	var full_adder_button = gate_buttons_container.get_node_or_null("FULL_ADDER")
	var cout0_button = gate_buttons_container.get_node_or_null("COUT0")
	
	if half_adder_button:
		half_adder_button.disabled = (half_adder_count >= max_half_adders)
		print("Half Adder button disabled: ", half_adder_button.disabled)
	
	if full_adder_button:
		full_adder_button.disabled = (full_adder_count >= max_full_adders)
		print("Full Adder button disabled: ", full_adder_button.disabled)
	
	if cout0_button:
		cout0_button.disabled = (cout0_count >= max_cout0)
		print("Cout0 button disabled: ", cout0_button.disabled)

# Методы для удаления компонентов
func remove_half_adder():
	if half_adder_count > 0:
		half_adder_count -= 1
		update_component_buttons_state()
		print("Half Adder removed. Current count: ", half_adder_count)

func remove_full_adder():
	if full_adder_count > 0:
		full_adder_count -= 1
		update_component_buttons_state()
		print("Full Adder removed. Current count: ", full_adder_count)

func remove_cout0():
	if cout0_count > 0:
		cout0_count -= 1
		update_component_buttons_state()
		print("Cout0 removed. Current count: ", cout0_count)

# Методы для удаления базовых гейтов (не используются в этом уровне, но должны быть для совместимости)
func remove_and_gate():
	print("remove_and_gate called on Level15 (not used)")

func remove_xor_gate():
	print("remove_xor_gate called on Level15 (not used)")

func remove_or_gate():
	print("remove_or_gate called on Level15 (not used)")

func remove_not_gate():
	print("remove_not_gate called on Level15 (not used)")

func remove_xnor_gate():
	print("remove_xnor_gate called on Level15 (not used)")

func remove_nand_gate():
	print("remove_nand_gate called on Level15 (not used)")

func remove_nor_gate():
	print("remove_nor_gate called on Level15 (not used)")

func remove_sel0_gate():
	print("remove_sel0_gate called on Level15 (not used)")

func remove_sel1_gate():
	print("remove_sel1_gate called on Level15 (not used)")

func clear_level():
	super.clear_level()
	half_adder_count = 0
	full_adder_count = 0
	cout0_count = 0
	update_component_buttons_state()
	print("Level15 cleared - all component counts reset to 0")

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
	recount_components()  # Пересчитываем после восстановления
	update_component_buttons_state()
	update_all_port_colors()
	
	print("Level state restored successfully. HalfAdders: ", half_adder_count, ", FullAdders: ", full_adder_count, ", Cout0: ", cout0_count)

func create_gate_from_data(gate_data):
	var gate_type = gate_data.get("type", "")
	var position_array = gate_data.get("position", [0, 0])
	var position = Vector2(position_array[0], position_array[1])
	
	# Проверяем ограничения для компонентов
	if gate_type == "HALF_ADDER" and half_adder_count >= max_half_adders:
		print("Cannot restore Half Adder: maximum limit reached")
		return
	elif gate_type == "FULL_ADDER" and full_adder_count >= max_full_adders:
		print("Cannot restore Full Adder: maximum limit reached")
		return
	elif gate_type == "COUT0" and cout0_count >= max_cout0:
		print("Cannot restore Cout0: maximum limit reached")
		return
	
	# Проверяем специальные блоки 2-Bit Adder
	if gate_type == "INPUT_BLOCK_A" and input_block_a:
		input_block_a.position = position
		print("Restored InputBlockA position: ", position)
		return
	elif gate_type == "INPUT_BLOCK_B" and input_block_b:
		input_block_b.position = position
		print("Restored InputBlockB position: ", position)
		return
	elif gate_type == "OUTPUT_S1" and output_s1:
		output_s1.position = position
		print("Restored OutputS1 position: ", position)
		return
	elif gate_type == "OUTPUT_S0" and output_s0:
		output_s0.position = position
		print("Restored OutputS0 position: ", position)
		return
	elif gate_type == "OUTPUT_COUT" and output_cout:
		output_cout.position = position
		print("Restored OutputCout position: ", position)
		return

	var gate_scene = null
	
	match gate_type:
		"HALF_ADDER":
			gate_scene = preload("res://scenes/gates/HalfAdder.tscn")
		"FULL_ADDER":
			gate_scene = preload("res://scenes/gates/FullAdder.tscn")
		"COUT0":
			gate_scene = preload("res://scenes/gates/Cout0.tscn")
	
	if gate_scene:
		var gate = gate_scene.instantiate()
		gate.position = position
		add_child(gate)
		movable_objects.append(gate)
		
		# Увеличиваем счетчики
		if gate_type == "HALF_ADDER":
			half_adder_count += 1
		elif gate_type == "FULL_ADDER":
			full_adder_count += 1
		elif gate_type == "COUT0":
			cout0_count += 1
			
		print("Restored component: ", gate_type, " at ", position)
