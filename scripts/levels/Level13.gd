# Level13.gd
extends "res://scripts/levels/LevelHalfAdder.gd"

func _ready():
	level_data = preload("res://data/level_13_data.tres")
	
	# Проверяем, что данные загружены правильно
	if not level_data:
		push_error("Level13: level_data is null!")
		return
	
	print("Level13 data loaded:")
	print("  Input A: ", level_data.input_values_a)
	print("  Input B: ", level_data.input_values_b)
	print("  Expected Sum: ", level_data.expected_sum)
	print("  Expected Carry: ", level_data.expected_carry)
	
	super._ready()
	
	# Вызываем нашу собственную настройку
	setup_half_adder_level()

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
