extends "res://scripts/levels/LevelBase.gd"

func _ready():
	level_data = preload("res://data/level_11_data.tres")
	super._ready()

func _on_add_sel0_button_pressed():
	var sel0_gate = preload("res://scenes/gates/Sel0.tscn").instantiate()
	sel0_gate.position = Vector2(600, 400)
	add_child(sel0_gate)
	movable_objects.append(sel0_gate)
	update_all_logic_objects()
	mark_level_state_dirty()
	print("Sel0 gate added")

func _on_add_sel1_button_pressed():
	var sel1_gate = preload("res://scenes/gates/Sel1.tscn").instantiate()
	sel1_gate.position = Vector2(600, 500)
	add_child(sel1_gate)
	movable_objects.append(sel1_gate)
	update_all_logic_objects()
	mark_level_state_dirty()
	print("Sel1 gate added")
	
func _on_add_and_button_pressed():
	var and_gate = preload("res://scenes/gates/ANDGate.tscn").instantiate()
	and_gate.position = Vector2(600, 400)
	add_child(and_gate)
	movable_objects.append(and_gate)
	update_all_logic_objects()
	mark_level_state_dirty()

func _on_add_or_button_pressed():
	var or_gate = preload("res://scenes/gates/ORGate.tscn").instantiate()
	or_gate.position = Vector2(600, 600)
	add_child(or_gate)
	movable_objects.append(or_gate)
	update_all_logic_objects()
	mark_level_state_dirty()

func _on_add_not_button_pressed():
	var not_gate = preload("res://scenes/gates/NOTGate.tscn").instantiate()
	not_gate.position = Vector2(600, 800)
	add_child(not_gate)
	movable_objects.append(not_gate)
	update_all_logic_objects()
	mark_level_state_dirty()
	
func _on_test_pressed():
	reset_all_port_sprites()
	if has_node("OutputBlock"):
		$OutputBlock.set_default_style()
	
	var player_outputs = []
	
	# Получаем все Sel0 и Sel1 гейты
	var sel0_gates = get_tree().get_nodes_in_group("Sel0")
	var sel1_gates = get_tree().get_nodes_in_group("Sel1")
	
	print("Testing with ", sel0_gates.size(), " Sel0 gates and ", sel1_gates.size(), " Sel1 gates")
	
	for i in range(8):
		# Устанавливаем входные блоки
		for input_block in input_blocks:
			input_block.current_test_index = i
		
		# Устанавливаем Sel0 и Sel1 гейты
		for sel0 in sel0_gates:
			if sel0.has_method("set_test_index"):
				sel0.set_test_index(i)
		for sel1 in sel1_gates:
			if sel1.has_method("set_test_index"):
				sel1.set_test_index(i)
		
		propagate_signals_three_inputs()
		if has_node("OutputBlock"):
			player_outputs.append(int($OutputBlock.received_value))
	
	print("Test results - Actual: ", player_outputs)
	print("Expected: ", [0,1,1,0,0,0,1,1])

	if test_results_panel:
		if test_results_panel.has_method("update_current_outputs"):
			test_results_panel.update_current_outputs(player_outputs)

	if has_node("OutputBlock"):
		var expected = [0,1,1,0,0,0,1,1]
		if player_outputs == expected:
			$OutputBlock.set_correct_style()
			if not level_completed_this_session:
				save_level_progress()
				level_completed_this_session = true
			print("LEVEL COMPLETED!")
		else:
			$OutputBlock.set_default_style()
			level_completed_this_session = false
			print("LEVEL FAILED!")

	update_all_port_colors()
