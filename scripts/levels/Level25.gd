extends "res://scripts/levels/LevelRS.gd"

func _ready():
	level_data = preload("res://data/level_25_data.tres")

	if not level_data:
		push_error("Level25: level_data is null!")
		return
	
	print("Level25 data loaded:")
	print("  Input R: ", level_data.input_values_r)
	print("  Input S: ", level_data.input_values_s)
	print("  Expected Q: ", level_data.expected_q)
	print("  Expected !Q: ", level_data.expected_not_q)
	
	super._ready()

func _on_add_nor_button_pressed():
	print("Adding NOR gate")
	var nor_gate = preload("res://scenes/gates/NORGate.tscn").instantiate()
	nor_gate.position = Vector2(600, 400)
	add_child(nor_gate)
	movable_objects.append(nor_gate)
	update_all_logic_objects()
	mark_level_state_dirty()

func _on_add_rs_flip_flop_button_pressed():
	print("Adding RS Flip-Flop")
	var rs_flip_flop = preload("res://scenes/gates/RSFlipFlop.tscn").instantiate()
	rs_flip_flop.position = Vector2(600, 400)
	add_child(rs_flip_flop)
	movable_objects.append(rs_flip_flop)
	update_all_logic_objects()
	mark_level_state_dirty()
