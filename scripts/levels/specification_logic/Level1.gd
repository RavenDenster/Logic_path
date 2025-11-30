extends "res://scripts/levels/level_templates/LevelBaseLE.gd"

var or_gate_count: int = 0
var max_or_gates: int = 2

func _ready():
	level_data = preload("res://data/level_1_data.tres")
	super._ready()
	
	# Устанавливаем правильные метки для InputBlock2
	var input_block = get_node_or_null("InputBlock")
	if input_block and input_block.has_method("_highlight_input_labels"):
		input_block.input_labels = ["Input 1", "Input 2"]
		print("Level1: Set input labels to ['Input 1', 'Input 2']")
	
	update_gate_buttons_state()

func _on_add_or_button_pressed():
	if or_gate_count >= max_or_gates:
		print("Cannot add more OR gates. Maximum limit reached: ", max_or_gates)
		return
	
	var or_gate = preload("res://scenes/gates/base_logic_el/ORGate.tscn").instantiate()
	or_gate.position = Vector2(600, 400)
	add_child(or_gate)
	movable_objects.append(or_gate)
	or_gate_count += 1
	update_all_logic_objects()
	mark_level_state_dirty()
	update_gate_buttons_state()
	print("OR gate added. Current count: ", or_gate_count)

func update_gate_buttons_state():
	var gate_buttons_container = $TopPanel/MainContainer/RightSection/GateButtonsContainer
	var or_button = gate_buttons_container.get_node_or_null("OR")
	if or_button:
		or_button.disabled = (or_gate_count >= max_or_gates)
		print("OR button disabled: ", or_button.disabled)

func remove_or_gate():
	if or_gate_count > 0:
		or_gate_count -= 1
		update_gate_buttons_state()

func clear_level():
	super.clear_level()
	or_gate_count = 0
	update_gate_buttons_state()
	print("Level1 cleared - OR gate count reset to 0")

func restore_level_state(state):
	super.restore_level_state(state)
	or_gate_count = 0
	for obj in movable_objects:
		if obj and is_instance_valid(obj):
			var scene_file = obj.scene_file_path
			if "ORGate" in scene_file:
				or_gate_count += 1
	update_gate_buttons_state()
	print("OR gate count after restore: ", or_gate_count)
