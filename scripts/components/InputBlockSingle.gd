# InputBlockSingle.gd (исправленный)
extends Node2D

var values = []
var current_test_index = 0
var test_results_panel: Node
var area: Area2D
var input_label: String = ""

func _ready():
	add_to_group("InputBlockSingle")
	print("InputBlockSingle ready! Has get_output: ", has_method("get_output"))
	
	# Добавляем Area2D только для обнаружения наведения
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

func get_output(port_name: String) -> int:
	var result = values[current_test_index]
	print("InputBlockSingle output from ", port_name, ": ", result)
	return result

func reset_inputs(): 
	pass

func _on_area_mouse_entered():
	# Запускаем подсветку при наведении
	_highlight_input_label()

func _on_area_mouse_exited():
	# Сбрасываем подсветку при уходе мыши
	_reset_all_highlights()

func _highlight_input_label():
	# Перед началом выводим отладочную информацию
	print("=== InputBlockSingle._highlight_input_label() called ===")
	print("  This block label: '", input_label, "'")
	print("  Has test_results_panel: ", test_results_panel != null)
	
	if not test_results_panel:
		# Ищем TestResultsPanel в дереве сцены для DLatch
		test_results_panel = _find_dlatch_test_results_panel()
		if not test_results_panel:
			print("  ERROR: TestResultsPanel not found for DLatch")
			return
		else:
			print("  Found DLatch test panel: ", test_results_panel.name)
	
	# Сбрасываем все подсветки через метод панели, если он есть
	if test_results_panel.has_method("reset_all_highlights"):
		test_results_panel.reset_all_highlights()
	else:
		print("  WARNING: test_results_panel doesn't have reset_all_highlights method")
	
	# Находим и подсвечиваем соответствующую метку
	if input_label != "":
		var grid = _find_dlatch_grid_container()
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
				if child is Label and child.text.strip_edges() == input_label:
					child.modulate = Color.YELLOW
					found = true
					print("  SUCCESS: Highlighted label: '", input_label, "' at index ", i)
					break
			
			if not found:
				print("  ERROR: Label not found in grid: '", input_label, "'")
				print("  Looking for exact match among: ", all_labels)
		else:
			print("  ERROR: GridContainer not found in test panel")
	else:
		print("  WARNING: input_label is empty!")

func _find_dlatch_test_results_panel():
	# Ищем панель для D-защелки
	var panel = get_tree().get_root().find_child("TestResultsPanelDLatch", true, false)
	if panel:
		return panel
	
	# Также можно попробовать найти по группам
	for node in get_tree().get_nodes_in_group("test_panel"):
		if "DLatch" in node.name:
			return node
	
	# Если не нашли, ищем любую тестовую панель
	panel = get_tree().get_root().find_child("TestResultsPanel", true, false)
	return panel

func _find_dlatch_grid_container():
	if not test_results_panel:
		return null
	
	# Пробуем разные пути к GridContainer
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

func _find_test_results_panel():
	# Сначала ищем панель для декодера
	var panel = get_tree().get_root().find_child("TestResultsPanelDecoder8", true, false)
	if panel:
		return panel
	
	# Если не нашли, ищем другие возможные панели
	panel = get_tree().get_root().find_child("TestResultsPanel", true, false)
	return panel

func _find_grid_container():
	if not test_results_panel:
		return null
	
	# Новая структура для TestResultsPanelDecoder8
	var grid = test_results_panel.get_node_or_null("Background/MainContainer/LeftColumn/GridContainer")
	if grid:
		return grid
	
	# Старые пути для обратной совместимости
	grid = test_results_panel.get_node_or_null("Background/HBoxContainer/GridContainer")
	if grid:
		return grid
	
	grid = test_results_panel.get_node_or_null("Background/HBoxContainer2/GridContainer")
	if grid:
		return grid
	
	grid = test_results_panel.get_node_or_null("Background/GridContainer")
	if grid:
		return grid
	
	grid = test_results_panel.get_node_or_null("Background/HBoxContainer/LeftColumn/LeftGridContainer")
	if grid:
		return grid
		
	grid = test_results_panel.get_node_or_null("Background/VBoxContainer/GridContainer")
	if grid:
		return grid
		
	grid = test_results_panel.get_node_or_null("Background/VBoxContainer2/GridContainer")
	if grid:
		return grid
	
	return null

func _reset_all_highlights():
	if test_results_panel:
		var grid = _find_grid_container()
		if grid:
			for child in grid.get_children():
				if child is Label:
					child.modulate = Color.WHITE
		else:
			print("InputBlockSingle: GridContainer not found for reset")
			
func get_current_output():
	if current_test_index >= 0 and current_test_index < values.size():
		return values[current_test_index]
	return 0
	
