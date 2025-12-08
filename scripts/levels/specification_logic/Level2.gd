extends "res://scripts/levels/level_templates/LevelBaseLE.gd"

var and_gate_count: int = 0
var max_and_gates: int = 2

func _ready():
	level_data = load("res://data/level_2_data.tres")
	super._ready()
		
	# Устанавливаем правильные метки для InputBlock2
	var input_block = get_node_or_null("InputBlock")
	if input_block and input_block.has_method("_highlight_input_labels"):
		input_block.input_labels = ["Input 1", "Input 2"]
		print("Level1: Set input labels to ['Input 1', 'Input 2']")
	
	setup_initial_block_positions()
	recount_and_gates()
	update_gate_buttons_state()

func setup_initial_block_positions():
	var viewport_rect = get_viewport().get_visible_rect()
	var screen_center_y = viewport_rect.size.y / 2
	
	# Располагаем InputBlock слева (10% от ширины экрана)
	var input_block = get_node_or_null("InputBlock")
	if input_block:
		input_block.position = Vector2(viewport_rect.size.x * 0.1, screen_center_y)
	
	# Располагаем OutputBlock справа (90% от ширины экрана)
	var output_block = get_node_or_null("OutputBlock")
	if output_block:
		output_block.position = Vector2(viewport_rect.size.x * 0.9, screen_center_y)


func recount_and_gates():
	and_gate_count = 0
	for obj in movable_objects:
		if obj and is_instance_valid(obj):
			var scene_file = obj.scene_file_path
			if "ANDGate" in scene_file:
				and_gate_count += 1
	print("Recounted AND gates: ", and_gate_count)

func _on_add_and_button_pressed():
	if and_gate_count >= max_and_gates:
		print("Cannot add more AND gates. Maximum limit reached: ", max_and_gates)
		return
	
	var and_gate = load("res://scenes/gates/base_logic_el/ANDGate.tscn").instantiate()
	var viewport_size = get_viewport().get_visible_rect().size
	and_gate.position =  Vector2(viewport_size.x - 300, 150)
	add_child(and_gate)
	movable_objects.append(and_gate)
	and_gate_count += 1
	update_all_logic_objects()
	mark_level_state_dirty()
	update_gate_buttons_state()
	print("AND gate added. Current count: ", and_gate_count)

func update_gate_buttons_state():
	var gate_buttons_container = $TopPanel/MainContainer/RightSection/GateButtonsContainer
	var and_button = gate_buttons_container.get_node_or_null("AND")
	if and_button:
		and_button.disabled = (and_gate_count >= max_and_gates)
		print("AND button disabled: ", and_button.disabled)

func remove_and_gate():
	if and_gate_count > 0:
		and_gate_count -= 1
		update_gate_buttons_state()

func clear_level():
	super.clear_level()
	and_gate_count = 0
	setup_initial_block_positions()
	update_gate_buttons_state()
	print("Level2 cleared - AND gate count reset to 0")

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
	recount_and_gates()
	update_gate_buttons_state()
	update_all_port_colors()
	
	print("Level state restored successfully. AND gates: ", and_gate_count)

func create_gate_from_data(gate_data):
	var gate_type = gate_data.get("type", "")
	var position_array = gate_data.get("position", [0, 0])
	var position = Vector2(position_array[0], position_array[1])

	if gate_type == "AND" and and_gate_count >= max_and_gates:
		print("Cannot restore AND gate: maximum limit reached")
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
			
		print("Restored gate: ", gate_type, " at ", position)

func _on_add_not_button_pressed():
	var not_gate = load("res://scenes/gates/base_logic_el/NOTGate.tscn").instantiate()
	not_gate.position = Vector2(600, 400)
	add_child(not_gate)
	movable_objects.append(not_gate)
	update_all_logic_objects()
	mark_level_state_dirty()
	print("NOT gate added to movable_objects array")
