# LevelHalfAdder.gd
extends "res://scripts/levels/LevelBase.gd"

var output_block_sum
var output_block_carry

func setup_half_adder_level():
	print("Setting up Half Adder level with two outputs")
	
	# Очищаем movable_objects и добавляем наши блоки
	movable_objects = []
	
	if has_node("InputBlock"):
		$InputBlock.values_A = level_data.input_values_a.duplicate()
		$InputBlock.values_B = level_data.input_values_b.duplicate()
		movable_objects.append($InputBlock)
		print("InputBlock initialized with values A: ", $InputBlock.values_A, " B: ", $InputBlock.values_B)
	else:
		push_error("InputBlock not found!")
	
	# Находим оба выходных блока
	output_block_sum = get_node_or_null("OutputBlockSum")
	output_block_carry = get_node_or_null("OutputBlockCarry")
	
	if output_block_sum and output_block_carry:
		output_block_sum.expected = level_data.expected_sum.duplicate()
		output_block_carry.expected = level_data.expected_carry.duplicate()
		movable_objects.append(output_block_sum)
		movable_objects.append(output_block_carry)
		print("Half Adder output blocks initialized")
	else:
		push_error("Output blocks not found in Half Adder level!")
	
	# Используем специальную панель результатов для полусумматора
	test_results_panel = get_node_or_null("TestResultsPanelHalfAdder")
	if test_results_panel:
		print("Half Adder test panel found")
		# Ждем следующего кадра, чтобы панель успела инициализироваться
		await get_tree().process_frame
		if test_results_panel.has_method("load_initial_data"):
			test_results_panel.load_initial_data(
				level_data.input_values_a, 
				level_data.input_values_b,
				level_data.expected_sum,
				level_data.expected_carry
			)
			print("Half Adder test panel initialized")
	else:
		print("WARNING: TestResultsPanelHalfAdder not found")
	
	# Обновляем список логических объектов
	update_all_logic_objects()
	print("Movable objects: ", movable_objects.size())
	print("All logic objects: ", all_logic_objects.size())

func _on_test_pressed():
	print("=== Testing Half Adder level ===")
	reset_all_port_sprites()
	
	# Сбрасываем стили выходных блоков
	if output_block_sum:
		output_block_sum.set_default_style()
	if output_block_carry:
		output_block_carry.set_default_style()
	
	var player_sum_outputs = []
	var player_carry_outputs = []
	
	# Проверяем, что у нас есть InputBlock
	if not has_node("InputBlock"):
		push_error("InputBlock not found!")
		return
	
	# Проверяем, что массивы входных данных корректны
	if $InputBlock.values_A.size() < 4 or $InputBlock.values_B.size() < 4:
		print("InputBlock values_A size: ", $InputBlock.values_A.size())
		print("InputBlock values_B size: ", $InputBlock.values_B.size())
		push_error("Input arrays are too small!")
		return
	
	# Тестируем все 4 комбинации
	for i in range(4):
		print("--- Test case ", i, " ---")
		$InputBlock.current_test_index = i
		print("InputBlock values: A=", $InputBlock.values_A[i], " B=", $InputBlock.values_B[i])
		
		# Сбрасываем значения перед каждым тестом
		for obj in all_logic_objects:
			if obj and obj.has_method("reset_inputs"):
				obj.reset_inputs()
		
		# Сбрасываем значения выходных блоков
		if output_block_sum:
			output_block_sum.received_value = 0
		if output_block_carry:
			output_block_carry.received_value = 0
			
		propagate_signals()
		
		if output_block_sum:
			player_sum_outputs.append(int(output_block_sum.received_value))
			print("Sum output: ", output_block_sum.received_value)
		else:
			player_sum_outputs.append(0)
			print("WARNING: output_block_sum is null")
		
		if output_block_carry:
			player_carry_outputs.append(int(output_block_carry.received_value))
			print("Carry output: ", output_block_carry.received_value)
		else:
			player_carry_outputs.append(0)
			print("WARNING: output_block_carry is null")
	
	print("=== Test results ===")
	print("Player Sum: ", player_sum_outputs)
	print("Expected Sum: ", level_data.expected_sum)
	print("Player Carry: ", player_carry_outputs)
	print("Expected Carry: ", level_data.expected_carry)
	
	# Проверяем, что массивы результатов имеют правильную длину
	if player_sum_outputs.size() != 4:
		push_error("player_sum_outputs has wrong size: " + str(player_sum_outputs.size()))
		return
	if player_carry_outputs.size() != 4:
		push_error("player_carry_outputs has wrong size: " + str(player_carry_outputs.size()))
		return
	
	# Обновляем панель результатов
	if test_results_panel and test_results_panel.has_method("update_current_outputs"):
		test_results_panel.update_current_outputs(player_sum_outputs, player_carry_outputs)
		print("Test panel updated")
	else:
		print("WARNING: Could not update test panel")
	
	# Проверяем правильность обоих выходов
	var sum_correct = player_sum_outputs == level_data.expected_sum
	var carry_correct = player_carry_outputs == level_data.expected_carry
	
	print("Sum correct: ", sum_correct, " Carry correct: ", carry_correct)
	
	if sum_correct and carry_correct:
		if output_block_sum:
			output_block_sum.set_correct_style()
		if output_block_carry:
			output_block_carry.set_correct_style()
		if not level_completed_this_session:
			save_level_progress()
			level_completed_this_session = true
		print("Level completed successfully!")
	else:
		if output_block_sum:
			output_block_sum.set_default_style()
		if output_block_carry:
			output_block_carry.set_default_style()
		level_completed_this_session = false
		print("Level not completed - outputs don't match")
	
	update_all_port_colors()

func propagate_signals():
	print("=== Starting signal propagation for Half Adder ===")
	print("All logic objects count: ", all_logic_objects.size())
	
	# Сбрасываем входы всех объектов
	for obj in all_logic_objects:
		if obj and obj.has_method("reset_inputs"):
			obj.reset_inputs()
			print("Reset inputs for: ", obj.name)
	
	# Построение графа зависимостей
	var dependencies = {}
	var dependents = {}
	
	# Инициализация словарей с проверкой валидности объектов
	for obj in all_logic_objects:
		if not obj or not is_instance_valid(obj):
			continue
		dependencies[obj] = []
		dependents[obj] = []
		print("Added to graph: ", obj.name)
	
	# Построение связей
	for wire in wires:
		if not wire or not is_instance_valid(wire):
			continue
		if not wire.start_port or not is_instance_valid(wire.start_port):
			continue
		if not wire.end_port or not is_instance_valid(wire.end_port):
			continue
			
		var start_gate = wire.start_port.get_parent()
		var end_gate = wire.end_port.get_parent()
		
		if not start_gate or not is_instance_valid(start_gate) or not end_gate or not is_instance_valid(end_gate):
			continue
		
		if start_gate != end_gate:
			if dependencies.has(end_gate) and not dependencies[end_gate].has(start_gate):
				dependencies[end_gate].append(start_gate)
			if dependents.has(start_gate) and not dependents[start_gate].has(end_gate):
				dependents[start_gate].append(end_gate)
			print("Wire: ", start_gate.name, " -> ", end_gate.name)
	
	# Топологическая сортировка
	var queue = []
	var in_degree = {}
	
	for obj in all_logic_objects:
		if not obj or not is_instance_valid(obj):
			continue
		in_degree[obj] = dependencies[obj].size() if dependencies.has(obj) else 0
		if in_degree[obj] == 0:
			queue.append(obj)
	
	var processed_order = []
	
	while queue.size() > 0:
		var current = queue.pop_front()
		if not current or not is_instance_valid(current):
			continue
		processed_order.append(current)
		
		if dependents.has(current):
			for dependent in dependents[current]:
				if not dependent or not is_instance_valid(dependent):
					continue
				if in_degree.has(dependent):
					in_degree[dependent] -= 1
					if in_degree[dependent] == 0:
						queue.append(dependent)
	
	print("Processing order: ", processed_order.size(), " objects")
	for obj in processed_order:
		print("  - ", obj.name)
	
	# Обработка объектов в порядке сортировки
	for current in processed_order:
		if not current or not is_instance_valid(current):
			continue
			
		print("Processing: ", current.name)
		
		# Обработка InputBlock
		if current == $InputBlock:
			print("InputBlock processing - values_A: ", current.values_A, " values_B: ", current.values_B)
			for port_name in ["OutputA", "OutputB"]:
				var port = current.get_node_or_null(port_name)
				if port and is_instance_valid(port):
					for wire in wires:
						if not wire or not is_instance_valid(wire):
							continue
						if wire.start_port == port:
							var end_gate = wire.end_port.get_parent()
							var end_port_name = wire.end_port.name
							var val = int(current.get_output(port_name))
							
							print("  Sending value ", val, " from ", current.name, ".", port_name, " to ", end_gate.name, ".", end_port_name)
							
							if end_gate and end_gate.has_method("set_input"):
								var port_num = 1
								if end_port_name == "Input2":
									port_num = 2
								elif end_port_name == "InputPort":
									port_num = 1
								elif end_port_name == "Input":
									port_num = 1
								
								print("  Setting input for ", end_gate.name, " port ", port_num, " to ", val)
								end_gate.set_input(port_num, val)
		
		# Обработка логических вентилей
		elif current.has_method("get_output"):
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
						
						print("  Setting input for ", end_gate.name, " port ", port_num, " to ", output_value)
						end_gate.set_input(port_num, output_value)
	
	print("Final OutputBlockSum value: ", output_block_sum.received_value if output_block_sum else "N/A")
	print("Final OutputBlockCarry value: ", output_block_carry.received_value if output_block_carry else "N/A")
	print("=== Signal propagation complete ===")
