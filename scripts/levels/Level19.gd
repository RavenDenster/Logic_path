extends "res://scripts/levels/LevelComparator.gd"

func _ready():
	level_data = preload("res://data/level_19_data.tres")

	if not level_data:
		push_error("Level19: level_data is null!")
		return
	
	print("Level19 data loaded:")
	print("  Input A: ", level_data.input_values_a)
	print("  Input B: ", level_data.input_values_b)
	print("  Expected A>B: ", level_data.expected_agtb)
	print("  Expected A<B: ", level_data.expected_altb)
	print("  Expected A==B: ", level_data.expected_aeqb)
	
	super._ready()
	
	# Проверяем, что кнопки подключены
	print("Level19: Checking button connections...")

func _on_add_and_button_pressed():
	print("Adding AND gate")
	var and_gate = preload("res://scenes/gates/ANDGate.tscn").instantiate()
	and_gate.position = Vector2(600, 400)
	add_child(and_gate)
	movable_objects.append(and_gate)
	update_all_logic_objects()
	mark_level_state_dirty()

func _on_add_not_button_pressed():
	print("Adding NOT gate")
	var not_gate = preload("res://scenes/gates/NOTGate.tscn").instantiate()
	not_gate.position = Vector2(600, 500)
	add_child(not_gate)
	movable_objects.append(not_gate)
	update_all_logic_objects()
	mark_level_state_dirty()

func _on_add_nxor_button_pressed():
	print("Adding XNOR gate")
	var xnor_gate = preload("res://scenes/gates/XNORGate.tscn").instantiate()
	xnor_gate.position = Vector2(600, 600)
	add_child(xnor_gate)
	movable_objects.append(xnor_gate)
	update_all_logic_objects()
	mark_level_state_dirty()


# Добавьте этот метод для отладки
func _setup_top_panel_buttons():
	print("Setting up top panel buttons for Level19")
	super._setup_top_panel_buttons()
