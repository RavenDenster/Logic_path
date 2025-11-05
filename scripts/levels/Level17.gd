extends "res://scripts/levels/LevelFullAdder.gd"

func _ready():
	level_data = preload("res://data/level_17_data.tres")

	if not level_data:
		push_error("Level17: level_data is null!")
		return
	
	print("Level17 data loaded:")
	print("  Input A: ", level_data.input_values_a)
	print("  Input B: ", level_data.input_values_b)
	print("  Input Cin: ", level_data.input_values_cin)
	print("  Expected Difference: ", level_data.expected_sum)
	print("  Expected Bout: ", level_data.expected_cout)
	
	super._ready()

	setup_full_adder_level()

func _on_add_and_button_pressed():
	var and_gate = preload("res://scenes/gates/ANDGate.tscn").instantiate()
	and_gate.position = Vector2(600, 400)
	add_child(and_gate)
	movable_objects.append(and_gate)
	update_all_logic_objects()
	mark_level_state_dirty()

func _on_add_xor_button_pressed():
	var xor_gate = preload("res://scenes/gates/XORGate.tscn").instantiate()
	xor_gate.position = Vector2(600, 600)
	add_child(xor_gate)
	movable_objects.append(xor_gate)
	update_all_logic_objects()
	mark_level_state_dirty()

func _on_add_not_button_pressed():
	var not_gate = preload("res://scenes/gates/NOTGate.tscn").instantiate()
	not_gate.position = Vector2(600, 800)
	add_child(not_gate)
	movable_objects.append(not_gate)
	update_all_logic_objects()
	mark_level_state_dirty()

func _on_add_or_button_pressed():
	var or_gate = preload("res://scenes/gates/ORGate.tscn").instantiate()
	or_gate.position = Vector2(600, 1000)
	add_child(or_gate)
	movable_objects.append(or_gate)
	update_all_logic_objects()
	mark_level_state_dirty()
