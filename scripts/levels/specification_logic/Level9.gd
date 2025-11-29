extends "res://scripts/levels/level_templates/LevelThreeInputs.gd"

var xor_gate_count: int = 0
var max_xor_gates: int = 2

func _ready():
	level_data = load("res://data/level_9_data.tres")
	super._ready()
	recount_gates()
	update_gate_buttons_state()

func recount_gates():
	xor_gate_count = 0
	for obj in movable_objects:
		if obj and is_instance_valid(obj):
			var scene_file = obj.scene_file_path
			if scene_file.find("XORGate") != -1:
				xor_gate_count += 1
	print("Recounted gates - XOR: ", xor_gate_count)

func _on_add_xor_button_pressed():
	if xor_gate_count >= max_xor_gates:
		print("Cannot add more XOR gates. Maximum limit reached: ", max_xor_gates)
		return
	
	var xor_gate = load("res://scenes/gates/base_logic_el/XORGate.tscn").instantiate()
	xor_gate.position = Vector2(600, 400)
	add_child(xor_gate)
	movable_objects.append(xor_gate)
	xor_gate_count += 1
	update_all_logic_objects()
	mark_level_state_dirty()
	update_gate_buttons_state()
	print("XOR gate added. Current count: ", xor_gate_count)

func update_gate_buttons_state():
	var gate_buttons_container = $TopPanel/GateButtonsContainer
	var xor_button = gate_buttons_container.get_node_or_null("XOR")
	
	if xor_button:
		xor_button.disabled = (xor_gate_count >= max_xor_gates)
		print("XOR button disabled: ", xor_button.disabled)

func remove_or_gate():
	print("remove_or_gate called on Level9 (not used)")

func remove_and_gate():
	print("remove_and_gate called on Level9 (not used)")

func remove_not_gate():
	print("remove_not_gate called on Level9 (not used)")

func remove_xor_gate():
	if xor_gate_count > 0:
		xor_gate_count -= 1
		update_gate_buttons_state()
		print("XOR gate removed. Current count: ", xor_gate_count)

func clear_level():
	super.clear_level()
	xor_gate_count = 0
	update_gate_buttons_state()
	print("Level9 cleared - XOR gate count reset to 0")

func restore_level_state(state):

	clear_level()

	if state.has("gates"):
		print("Restoring ", state["gates"].size(), " gates")
		for gate_data in state["gates"]:
			create_gate_from_data(gate_data)
	
	if state.has("wires"):
		print("Restoring ", state["wires"].size(), " wires")
		for wire_data in state["wires"]:
			create_wire_from_data(wire_data)
	
	update_all_logic_objects()
	recount_gates() 
	update_gate_buttons_state()
	update_all_port_colors()
	
	print("Level state restored successfully. XOR gates: ", xor_gate_count)

func create_gate_from_data(gate_data):
	var gate_type = gate_data.get("type", "")
	var position_array = gate_data.get("position", [0, 0])
	var position = Vector2(position_array[0], position_array[1])

	if gate_type == "XOR" and xor_gate_count >= max_xor_gates:
		print("Cannot restore XOR gate: maximum limit reached")
		return
	
	if gate_type == "INPUT_BLOCK_SINGLE":
		var block_name = gate_data.get("name", "")
		var found_block = null
		for obj in get_children():
			if obj.name == block_name:
				found_block = obj
				break
		
		if found_block and is_instance_valid(found_block):
			found_block.position = position
			print("Restored InputBlockSingle position: ", block_name, " at ", position)
			if not found_block in input_blocks:
				input_blocks.append(found_block)
			if not found_block in movable_objects:
				movable_objects.append(found_block)
		else:
			print("WARNING: InputBlockSingle not found: ", block_name)
		return
	elif gate_type == "OUTPUT_BLOCK" and has_node("OutputBlock"):
		$OutputBlock.position = position
		print("Restored OutputBlock position: ", position)
		return

	var gate_scene = null
	
	match gate_type:
		"XOR":
			gate_scene = load("res://scenes/gates/base_logic_el/XORGate.tscn")
	
	if gate_scene:
		var gate = gate_scene.instantiate()
		gate.position = position
		add_child(gate)
		movable_objects.append(gate)

		if gate_type == "XOR":
			xor_gate_count += 1
			
		print("Restored gate: ", gate_type, " at ", position)
