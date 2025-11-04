# Level15.gd
extends "res://scripts/levels/Level2bitAdder.gd"

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

func _on_add_half_adder_button_pressed():
	var half_adder = preload("res://scenes/gates/HalfAdder.tscn").instantiate()
	half_adder.position = Vector2(600, 400)
	add_child(half_adder)
	movable_objects.append(half_adder)
	update_all_logic_objects()
	mark_level_state_dirty()

func _on_add_full_adder_button_pressed():
	var full_adder = preload("res://scenes/gates/FullAdder.tscn").instantiate()
	full_adder.position = Vector2(600, 600)
	add_child(full_adder)
	movable_objects.append(full_adder)
	update_all_logic_objects()
	mark_level_state_dirty()

func _on_add_cout0_button_pressed():
	var cout0 = preload("res://scenes/gates/Cout0.tscn").instantiate()
	cout0.position = Vector2(600, 800)
	add_child(cout0)
	movable_objects.append(cout0)
	update_all_logic_objects()
	mark_level_state_dirty()
