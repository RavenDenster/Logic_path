extends "res://scripts/levels/level_templates/LevelThreeInputs.gd"

var and_gate_count: int = 0
var or_gate_count: int = 0
var not_gate_count: int = 0
var max_and_gates: int = 5
var max_or_gates: int = 2
var max_not_gates: int = 4

func _ready():
	level_data = load("res://data/level_11_data.tres")
	super._ready()
	recount_gates()
	update_gate_buttons_state()
	
func recount_gates():
	and_gate_count = 0
	or_gate_count = 0
	not_gate_count = 0
	for obj in movable_objects:
		if obj and is_instance_valid(obj):
			var scene_file = obj.scene_file_path
			if scene_file.find("ANDGate") != -1:
				and_gate_count += 1
			elif scene_file.find("ORGate") != -1:
				or_gate_count += 1
			elif scene_file.find("NOTGate") != -1:
				not_gate_count += 1
	print("Recounted gates - AND: ", and_gate_count, ", OR: ", or_gate_count, ", NOT: ", not_gate_count)

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

func _on_add_or_button_pressed():
	if or_gate_count >= max_or_gates:
		print("Cannot add more OR gates. Maximum limit reached: ", max_or_gates)
		return
	
	var or_gate = load("res://scenes/gates/base_logic_el/ORGate.tscn").instantiate()
	or_gate.position = Vector2(600, 600)
	add_child(or_gate)
	movable_objects.append(or_gate)
	or_gate_count += 1
	update_all_logic_objects()
	mark_level_state_dirty()
	update_gate_buttons_state()
	print("OR gate added. Current count: ", or_gate_count)

func _on_add_not_button_pressed():
	if not_gate_count >= max_not_gates:
		print("Cannot add more NOT gates. Maximum limit reached: ", max_not_gates)
		return
	
	var not_gate = load("res://scenes/gates/base_logic_el/NOTGate.tscn").instantiate()
	not_gate.position = Vector2(600, 800)
	add_child(not_gate)
	movable_objects.append(not_gate)
	not_gate_count += 1
	update_all_logic_objects()
	mark_level_state_dirty()
	update_gate_buttons_state()
	print("NOT gate added. Current count: ", not_gate_count)

func update_gate_buttons_state():
	var gate_buttons_container = $TopPanel/GateButtonsContainer
	var and_button = gate_buttons_container.get_node_or_null("AND")
	var or_button = gate_buttons_container.get_node_or_null("OR")
	var not_button = gate_buttons_container.get_node_or_null("NOT")
	
	if and_button:
		and_button.disabled = (and_gate_count >= max_and_gates)
		print("AND button disabled: ", and_button.disabled)
	
	if or_button:
		or_button.disabled = (or_gate_count >= max_or_gates)
		print("OR button disabled: ", or_button.disabled)
	
	if not_button:
		not_button.disabled = (not_gate_count >= max_not_gates)
		print("NOT button disabled: ", not_button.disabled)

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

func remove_not_gate():
	if not_gate_count > 0:
		not_gate_count -= 1
		update_gate_buttons_state()
		print("NOT gate removed. Current count: ", not_gate_count)

func remove_xor_gate():
	print("remove_xor_gate called on Level11 (not used)")

func remove_xnor_gate():
	print("remove_xnor_gate called on Level11 (not used)")

func remove_nand_gate():
	print("remove_nand_gate called on Level11 (not used)")

func remove_nor_gate():
	print("remove_nor_gate called on Level11 (not used)")

func clear_level():
	super.clear_level()
	and_gate_count = 0
	or_gate_count = 0
	not_gate_count = 0
	update_gate_buttons_state()
	print("Level11 cleared - AND gate count reset to 0, OR gate count reset to 0, NOT gate count reset to 0")

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
	
	print("Level state restored successfully. AND gates: ", and_gate_count, ", OR gates: ", or_gate_count, ", NOT gates: ", not_gate_count)

func create_gate_from_data(gate_data):
	var gate_type = gate_data.get("type", "")
	var position_array = gate_data.get("position", [0, 0])
	var position = Vector2(position_array[0], position_array[1])

	if gate_type == "AND" and and_gate_count >= max_and_gates:
		print("Cannot restore AND gate: maximum limit reached")
		return
	elif gate_type == "OR" and or_gate_count >= max_or_gates:
		print("Cannot restore OR gate: maximum limit reached")
		return
	elif gate_type == "NOT" and not_gate_count >= max_not_gates:
		print("Cannot restore NOT gate: maximum limit reached")
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
		"AND":
			gate_scene = load("res://scenes/gates/base_logic_el/ANDGate.tscn")
		"OR":
			gate_scene = load("res://scenes/gates/base_logic_el/ORGate.tscn")
		"NOT":
			gate_scene = load("res://scenes/gates/base_logic_el/NOTGate.tscn")
	
	if gate_scene:
		var gate = gate_scene.instantiate()
		gate.position = position
		add_child(gate)
		movable_objects.append(gate)
		
		if gate_type == "AND":
			and_gate_count += 1
		elif gate_type == "OR":
			or_gate_count += 1
		elif gate_type == "NOT":
			not_gate_count += 1
			
		print("Restored gate: ", gate_type, " at ", position)
