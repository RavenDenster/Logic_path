# OutputBlockQ.gd (обновленный)
extends Node2D

var received_value: int = 0
var expected = []
var area: Area2D
var test_results_panel: Node  # Добавляем ссылку на панель
var output_label: String = "Current Q"  # Добавляем метку для поиска

func _ready():
	# Добавляем Area2D для обнаружения наведения
	area = Area2D.new()
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	
	# Устанавливаем размер области равной размеру спрайта
	var sprite = $Sprite2D
	if sprite:
		var texture_size = sprite.texture.get_size()
		shape.size = texture_size
		collision.shape = shape
		area.position = sprite.position
		
	area.add_child(collision)
	add_child(area)
	
	# Настраиваем Area2D так, чтобы он обнаруживал мышь, но не мешал основной логике
	area.input_pickable = true
	area.collision_layer = 2  # Используем отдельный слой для обнаружения наведения
	area.collision_mask = 0   # Не обнаруживаем другие объекты
	
	# Подключаем сигналы Area2D
	area.mouse_entered.connect(_on_area_mouse_entered)
	area.mouse_exited.connect(_on_area_mouse_exited)

func set_input(port: int, val: int):
	print("OutputBlock set_input: ", val)
	received_value = val

func get_input(port: int) -> int:
	if port == 1:
		return received_value
	return 0

func reset_inputs():
	received_value = 0

func set_default_style():
	if has_node("Sprite2D"):
		var texture = load("res://assets/q.png")
		if texture:
			$Sprite2D.texture = texture
		else:
			print("ERROR: Cannot load output.png")

func set_correct_style():
	if has_node("Sprite2D"):
		var texture = load("res://assets/output_cur_q.png")
		if texture:
			$Sprite2D.texture = texture
		else:
			print("ERROR: Cannot load output_correct.png")

func _on_area_mouse_entered():
	print("OutputBlockQ mouse entered")
	_highlight_output_labels()

func _on_area_mouse_exited():
	print("OutputBlockQ mouse exited")
	_reset_all_highlights()

func _highlight_output_labels():
	print("=== OutputBlockQ._highlight_output_labels() called ===")
	print("  This block label: '", output_label, "'")
	print("  Has test_results_panel: ", test_results_panel != null)
	
	# Если test_results_panel не установлен, пытаемся найти его
	if not test_results_panel:
		test_results_panel = _find_dtrigger_test_results_panel()
		if not test_results_panel:
			print("  ERROR: TestResultsPanel not found")
			return
		else:
			print("  Found test panel: ", test_results_panel.name)
	
	# Сбрасываем все подсветки через метод панели, если он есть
	if test_results_panel.has_method("reset_all_highlights"):
		test_results_panel.reset_all_highlights()
	else:
		print("  WARNING: test_results_panel doesn't have reset_all_highlights method")
	
	# Находим и подсвечиваем соответствующую метку
	if output_label != "":
		var grid = _find_dtrigger_grid_container()
		if grid:
			# Для отладки выведем все доступные Label
			print("  Available labels in grid (", grid.get_child_count(), " children):")
			var all_labels = []
			for i in range(grid.get_child_count()):
				var child = grid.get_child(i)
				if child is Label:
					var text = child.text.strip_edges()
					all_labels.append(text)
					print("    [", i, "] '", text, "'")
			
			var found = false
			for i in range(grid.get_child_count()):
				var child = grid.get_child(i)
				if child is Label and child.text.strip_edges() == output_label:
					child.modulate = Color.YELLOW
					found = true
					print("  SUCCESS: Highlighted label: '", output_label, "' at index ", i)
					break
			
			if not found:
				print("  ERROR: Label not found in grid: '", output_label, "'")
				print("  Looking for exact match among: ", all_labels)
		else:
			print("  ERROR: GridContainer not found in test panel")
	else:
		print("  WARNING: output_label is empty!")

func _find_dtrigger_test_results_panel():
	# Ищем панель для D-триггера
	var panel = get_tree().get_root().find_child("TestResultsPanelDTrigger", true, false)
	if panel:
		return panel
	
	# Также можно попробовать найти по группам
	for node in get_tree().get_nodes_in_group("test_panel"):
		if "DTrigger" in node.name:
			return node
	
	# Если не нашли, ищем любую тестовую панель
	panel = get_tree().get_root().find_child("TestResultsPanel", true, false)
	return panel

func _find_dtrigger_grid_container():
	if not test_results_panel:
		return null
	
	# Пробуем разные пути к GridContainer для D-триггера
	var paths_to_try = [
		"Background/GridContainer",
		"GridContainer",
		"Container/GridContainer",
		"VBoxContainer/GridContainer"
	]
	
	for path in paths_to_try:
		var grid = test_results_panel.get_node_or_null(path)
		if grid:
			return grid
	
	return null

func _reset_all_highlights():
	if test_results_panel:
		var grid = _find_dtrigger_grid_container()
		if grid:
			for child in grid.get_children():
				if child is Label:
					child.modulate = Color.WHITE
		else:
			print("OutputBlockQ: GridContainer not found for reset")
