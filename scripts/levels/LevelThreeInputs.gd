# LevelThreeInputs.gd
extends "res://scripts/levels/LevelBase.gd"

func setup_three_input_level():
	print("Setting up three-input level")

	if has_node("InputBlock"):
		$InputBlock.hide()

	input_blocks = []

	var input_block_a = get_node_or_null("InputBlockA")
	var input_block_b = get_node_or_null("InputBlockB") 
	var input_block_c = get_node_or_null("InputBlockC")

	if input_block_a and input_block_b and input_block_c:
		print("Using existing InputBlocks")
		input_blocks = [input_block_a, input_block_b, input_block_c]

		if input_block_a.values.is_empty():
			input_block_a.values = level_data.input_values_a.duplicate()
			print("Set values for InputBlockA")
		if input_block_b.values.is_empty():
			input_block_b.values = level_data.input_values_b.duplicate()
			print("Set values for InputBlockB")
		if input_block_c.values.is_empty():
			input_block_c.values = level_data.input_values_c.duplicate()
			print("Set values for InputBlockC")
	else:
		print("Creating InputBlocks programmatically")
		var input_block_scene = preload("res://scenes/components/SingleInputBlock.tscn")

		input_block_a = input_block_scene.instantiate()
		input_block_a.name = "InputBlockA"
		input_block_a.position = Vector2(200, 300)
		input_block_a.values = level_data.input_values_a.duplicate()
		add_child(input_block_a)
 
		input_block_b = input_block_scene.instantiate()
		input_block_b.name = "InputBlockB"
		input_block_b.position = Vector2(200, 500)
		input_block_b.values = level_data.input_values_b.duplicate()
		add_child(input_block_b)

		input_block_c = input_block_scene.instantiate()
		input_block_c.name = "InputBlockC"
		input_block_c.position = Vector2(200, 700)
		input_block_c.values = level_data.input_values_c.duplicate()
		add_child(input_block_c)
		
		input_blocks = [input_block_a, input_block_b, input_block_c]

	for input_block in input_blocks:
		if not input_block in movable_objects:
			movable_objects.append(input_block)
			print("Added to movable_objects: ", input_block.name)
	
	if not $OutputBlock in movable_objects:
		movable_objects.append($OutputBlock)
		print("Added OutputBlock to movable_objects")

	test_results_panel = get_node_or_null("TestResultsPanel3Inputs")
	
	if not test_results_panel:
		print("Creating TestResultsPanel3Inputs programmatically")
		var new_panel_scene = preload("res://scenes/ui/TestResultsPanel3Inputs.tscn")
		if ResourceLoader.exists(new_panel_scene.resource_path):
			var new_panel = new_panel_scene.instantiate()

			new_panel.position = Vector2(1200, 200)
			add_child(new_panel)

			test_results_panel = new_panel
			print("Created TestResultsPanel3Inputs")
		else:
			push_error("TestResultsPanel3Inputs scene not found")
	else:
		print("Using existing TestResultsPanel3Inputs")
	
	print("Three-input level setup completed with ", input_blocks.size(), " input blocks")

func propagate_signals_three_inputs():
	for obj in all_logic_objects:
		if obj.has_method("reset_inputs") and not (obj in input_blocks):
			obj.reset_inputs()
	
	print("=== Starting signal propagation for three inputs ===")

	var dependencies = {}
	var dependents = {}
	
	for obj in all_logic_objects:
		dependencies[obj] = []
		dependents[obj] = []

	for wire in wires:
		if not wire or not is_instance_valid(wire):
			continue
		if not wire.start_port or not is_instance_valid(wire.start_port):
			continue
		if not wire.end_port or not is_instance_valid(wire.end_port):
			continue
			
		var start_gate = wire.start_port.get_parent()
		var end_gate = wire.end_port.get_parent()
		
		if start_gate != end_gate:
			if not dependencies[end_gate].has(start_gate):
				dependencies[end_gate].append(start_gate)
			if not dependents[start_gate].has(end_gate):
				dependents[start_gate].append(end_gate)

	var queue = []
	var in_degree = {}
	
	for obj in all_logic_objects:
		in_degree[obj] = dependencies[obj].size()
		if in_degree[obj] == 0:
			queue.append(obj)
	
	var processed_order = []
	
	while queue.size() > 0:
		var current = queue.pop_front()
		processed_order.append(current)
		
		for dependent in dependents[current]:
			in_degree[dependent] -= 1
			if in_degree[dependent] == 0:
				queue.append(dependent)
	
	print("Processing order for three inputs: ", processed_order)

	for current in processed_order:
		if not current or not is_instance_valid(current):
			continue
			
		print("Processing: ", current.name)

		if current in input_blocks and current.has_method("get_output"):
			var output_value = int(current.get_output("Output"))
			print(current.name, " output value: ", output_value)

			for wire in wires:
				if not wire or not is_instance_valid(wire):
					continue
				if not wire.start_port or not is_instance_valid(wire.start_port):
					continue
					
				if wire.start_port.get_parent() == current:
					var end_gate = wire.end_port.get_parent()
					if not end_gate or not is_instance_valid(end_gate):
						continue
						
					var end_port_name = wire.end_port.name
					
					if end_gate.has_method("set_input"):
						var port_num = 1
						if end_port_name == "Input2":
							port_num = 2
						elif end_port_name == "InputPort":
							port_num = 1
						elif end_port_name == "Input":
							port_num = 1
						
						print("Setting input for ", end_gate.name, " port ", port_num, " to ", output_value)
						end_gate.set_input(port_num, output_value)

		elif current.has_method("get_output") and current != $OutputBlock:
			var output_value = int(current.get_output("Output"))
			print(current.name, " output value: ", output_value)

			for wire in wires:
				if not wire or not is_instance_valid(wire):
					continue
				if not wire.start_port or not is_instance_valid(wire.start_port):
					continue
					
				if wire.start_port.get_parent() == current:
					var end_gate = wire.end_port.get_parent()
					if not end_gate or not is_instance_valid(end_gate):
						continue
						
					var end_port_name = wire.end_port.name
					
					if end_gate.has_method("set_input"):
						var port_num = 1
						if end_port_name == "Input2":
							port_num = 2
						elif end_port_name == "InputPort":
							port_num = 1
						elif end_port_name == "Input":
							port_num = 1
						
						print("Setting input for ", end_gate.name, " port ", port_num, " to ", output_value)
						end_gate.set_input(port_num, output_value)
	
	if has_node("OutputBlock"):
		print("Final OutputBlock value: ", $OutputBlock.received_value)
	print("=== Signal propagation for three inputs complete ===")

func _on_test_pressed():
	reset_all_port_sprites()
	if has_node("OutputBlock"):
		$OutputBlock.set_default_style()
	
	var player_outputs = []
	
	# Для трехвходовых уровней - 8 тестов
	for i in range(8):
		# Устанавливаем текущий индекс теста для всех входных блоков
		for input_block in input_blocks:
			input_block.current_test_index = i
		
		propagate_signals_three_inputs()
		if has_node("OutputBlock"):
			player_outputs.append(int($OutputBlock.received_value))
	
	print("Test results - Actual: ", player_outputs)

	if test_results_panel and test_results_panel.has_method("update_current_outputs"):
		test_results_panel.update_current_outputs(player_outputs)

	if has_node("OutputBlock"):
		var expected = $OutputBlock.expected
		if player_outputs == expected:
			$OutputBlock.set_correct_style()
			if not level_completed_this_session:
				save_level_progress()
				level_completed_this_session = true
		else:
			$OutputBlock.set_default_style()
			level_completed_this_session = false
	
	update_all_port_colors()
