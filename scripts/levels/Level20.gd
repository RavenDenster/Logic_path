extends "res://scripts/levels/LevelComparator2.gd"

func _ready():
	level_data = preload("res://data/level_20_data.tres")

	if not level_data:
		push_error("Level20: level_data is null!")
		return
	
	print("Level20 data loaded:")
	print("  Input A1: ", level_data.input_values_a1)
	print("  Input A0: ", level_data.input_values_a0)
	print("  Input B1: ", level_data.input_values_b1)
	print("  Input B0: ", level_data.input_values_b0)
	print("  Expected A>B: ", level_data.expected_agtb)
	print("  Expected A<B: ", level_data.expected_altb)
	print("  Expected A==B: ", level_data.expected_aeqb)
	
	super._ready()

func _on_add_comparator_button_pressed():
	print("Adding 1-bit Comparator")
	var comparator = preload("res://scenes/gates/OneBitComparatorGate.tscn").instantiate()
	comparator.position = Vector2(600, 400)
	add_child(comparator)
	movable_objects.append(comparator)
	update_all_logic_objects()
	mark_level_state_dirty()

func _on_add_and_button_pressed():
	print("Adding AND gate")
	var and_gate = preload("res://scenes/gates/ANDGate.tscn").instantiate()
	and_gate.position = Vector2(600, 500)
	add_child(and_gate)
	movable_objects.append(and_gate)
	update_all_logic_objects()
	mark_level_state_dirty()

func _on_add_or_button_pressed():
	print("Adding OR gate")
	var or_gate = preload("res://scenes/gates/ORGate.tscn").instantiate()
	or_gate.position = Vector2(600, 600)
	add_child(or_gate)
	movable_objects.append(or_gate)
	update_all_logic_objects()
	mark_level_state_dirty()
