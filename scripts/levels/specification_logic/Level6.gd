extends "res://scripts/levels/level_templates/LevelBaseLE.gd"

var or_gate_count: int = 0
var not_gate_count: int = 0
var max_or_gates: int = 2
var max_not_gates: int = 2

func _ready():
	level_data = preload("res://data/level_6_data.tres")
	super._ready()
	recount_gates()
	update_gate_buttons_state()

func recount_gates():
	or_gate_count = 0
	not_gate_count = 0
	for obj in movable_objects:
		if obj and is_instance_valid(obj):
			var scene_file = obj.scene_file_path
			if "ORGate" in scene_file:
				or_gate_count += 1
			elif "NOTGate" in scene_file:
				not_gate_count += 1
	print("Recounted gates - OR: ", or_gate_count, ", NOT: ", not_gate_count)

func _on_add_or_button_pressed():
	if or_gate_count >= max_or_gates:
		print("Cannot add more OR gates. Maximum limit reached: ", max_or_gates)
		return
	
	var or_gate = preload("res://scenes/gates/base_logic_el/ORGate.tscn").instantiate()
	or_gate.position = Vector2(600, 300)
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
	
	var not_gate = preload("res://scenes/gates/base_logic_el/NOTGate.tscn").instantiate()
	not_gate.position = Vector2(600, 400)
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
	var not_button = gate_buttons_container.get_node_or_null("NOT")
	
	if or_button:
		or_button.disabled = (or_gate_count >= max_or_gates)
		print("OR button disabled: ", or_button.disabled)
	
	if not_button:
		not_button.disabled = (not_gate_count >= max_not_gates)
		print("NOT button disabled: ", not_button.disabled)

func remove_or_gate():
	if or_gate_count > 0:
		or_gate_count -= 1
		update_gate_buttons_state()

func remove_not_gate():
	if not_gate_count > 0:
		not_gate_count -= 1
		update_gate_buttons_state()

func clear_level():
	super.clear_level()
	or_gate_count = 0
	not_gate_count = 0
	update_gate_buttons_state()
	print("Level6 cleared - OR gate count reset to 0, NOT gate count reset to 0")

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
	
	print("Level state restored successfully. OR gates: ", or_gate_count, ", NOT gates: ", not_gate_count)

func create_gate_from_data(gate_data):
	var gate_type = gate_data.get("type", "")
	var position_array = gate_data.get("position", [0, 0])
	var position = Vector2(position_array[0], position_array[1])

	if gate_type == "OR" and or_gate_count >= max_or_gates:
		print("Cannot restore OR gate: maximum limit reached")
		return
	elif gate_type == "NOT" and not_gate_count >= max_not_gates:
		print("Cannot restore NOT gate: maximum limit reached")
		return
	
	if gate_type == "INPUT_BLOCK" and has_node("InputBlock"):
		$InputBlock.position = position
		print("Restored InputBlock position: ", position)
		return
	elif gate_type == "OUTPUT_BLOCK" and has_node("OutputBlock"):
		$OutputBlock.position = position
		print("Restored OutputBlock position: ", position)
		return

	var gate_scene = null
	
	match gate_type:
		"OR":
			gate_scene = preload("res://scenes/gates/base_logic_el/ORGate.tscn")
		"NOT":
			gate_scene = preload("res://scenes/gates/base_logic_el/NOTGate.tscn")
	
	if gate_scene:
		var gate = gate_scene.instantiate()
		gate.position = position
		add_child(gate)
		movable_objects.append(gate)

		if gate_type == "OR":
			or_gate_count += 1
		elif gate_type == "NOT":
			not_gate_count += 1
			
		print("Restored gate: ", gate_type, " at ", position)
