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
	if not test_results_panel:
		# Ищем TestResultsPanel в дереве сцены
		test_results_panel = _find_test_results_panel()
		if not test_results_panel:
			print("InputBlockSingle: TestResultsPanel not found for label: ", input_label)
			return
		else:
			print("InputBlockSingle: Found test panel: ", test_results_panel.name)
	
	# Сбрасываем все подсветки
	_reset_all_highlights()
	
	# Находим и подсвечиваем соответствующую метку
	if input_label != "":
		var grid = _find_grid_container()
		if grid:
			var found = false
			for child in grid.get_children():
				if child is Label and child.text.strip_edges() == input_label:
					child.modulate = Color.YELLOW
					found = true
					print("InputBlockSingle: Highlighted label: '", input_label, "'")
					break
			
			if not found:
				print("InputBlockSingle: Label not found in grid: '", input_label, "'")
				# Выведем все доступные метки для отладки
				print("Available labels:")
				for child in grid.get_children():
					if child is Label:
						print("  - '", child.text.strip_edges(), "'")
		else:
			print("InputBlockSingle: GridContainer not found in test panel")

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
	
	# НОВАЯ СТРУКТУРА: сначала ищем левую панель (Inputs & Expected)
	var grid = test_results_panel.get_node_or_null("Background/HBoxContainer/GridContainer")
	if grid:
		return grid
	
	# Затем ищем правую панель (Current Outputs)
	grid = test_results_panel.get_node_or_null("Background/HBoxContainer2/GridContainer")
	if grid:
		return grid
	
	# Старые пути для обратной совместимости
	grid = test_results_panel.get_node_or_null("Background/GridContainer")
	if grid:
		return grid
	
	grid = test_results_panel.get_node_or_null("Background/VBoxContainer/GridContainer")
	if grid:
		return grid
		
	grid = test_results_panel.get_node_or_null("Background/VBoxContainer2/GridContainer")
	if grid:
		return grid
		
	grid = test_results_panel.get_node_or_null("Background/HBoxContainer/LeftColumn/LeftGridContainer")
	if grid:
		return grid
		
	grid = test_results_panel.get_node_or_null("Background/HBoxContainer/RightColumn/RightGridContainer")
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
