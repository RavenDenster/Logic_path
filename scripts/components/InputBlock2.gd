# InputBlock2.gd (дополненный)
extends Node2D
class_name InputBlock2

var values_A = []
var values_B = []
var current_test_index = 0
var test_results_panel: Node
var area: Area2D
var input_labels = ["Input A", "Input B"]  # По умолчанию

func _ready():
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
	var result = 0
	if port_name == "OutputA": 
		result = values_A[current_test_index]
	elif port_name == "OutputB": 
		result = values_B[current_test_index]
	print("InputBlock2 output from ", port_name, ": ", result)
	return result

func reset_inputs(): 
	pass

func get_input_count() -> int:
	return 2

func _on_area_mouse_entered():
	# Запускаем подсветку при наведении
	_highlight_input_labels()

func _on_area_mouse_exited():
	# Сбрасываем подсветку при уходе мыши
	_reset_all_highlights()

func _highlight_input_labels():
	if not test_results_panel:
		# Ищем TestResultsPanel в дереве сцены
		test_results_panel = _find_test_results_panel()
		if not test_results_panel:
			print("InputBlock2: TestResultsPanel not found for labels: ", input_labels)
			return
	
	# Сбрасываем все подсветки
	_reset_all_highlights()
	
	# Находим GridContainer (обратная совместимость)
	var grid = _find_grid_container()
	if not grid:
		print("InputBlock2: GridContainer not found")
		return
	
	# Подсвечиваем заданные метки
	var found_count = 0
	for child in grid.get_children():
		if child is Label:
			# Обрезаем пробелы с обеих сторон для сравнения
			var child_text = child.text.strip_edges()
			
			# Проверяем все варианты меток
			for label in input_labels:
				var stripped_label = label.strip_edges()
				
				# Прямое совпадение
				if child_text == stripped_label:
					child.modulate = Color.YELLOW
					found_count += 1
					print("InputBlock2: Highlighted label (exact match): '", child_text, "'")
					break
				
				# Совпадение без префикса "Input " (для обратной совместимости)
				var label_without_input = stripped_label.replace("Input ", "")
				if child_text == label_without_input:
					child.modulate = Color.YELLOW
					found_count += 1
					print("InputBlock2: Highlighted label (without 'Input' prefix): '", child_text, "'")
					break
				
				# Совпадение по последней части (для A, B, I0, I1, I2, I3)
				var label_parts = stripped_label.split(" ")
				if label_parts.size() > 1:
					var last_part = label_parts[-1]
					if child_text == last_part:
						child.modulate = Color.YELLOW
						found_count += 1
						print("InputBlock2: Highlighted label (last part match): '", child_text, "'")
						break
	
	if found_count == 0:
		print("InputBlock2: None of the labels found: ", input_labels)
		# Выведем все доступные метки для отладки
		print("Available labels:")
		for child in grid.get_children():
			if child is Label:
				print("  - '", child.text, "'")

func _find_test_results_panel():
	# Сначала ищем панель для декодера
	var panel = get_tree().get_root().find_child("TestResultsPanelDecoder", true, false)
	if panel:
		return panel
	
	# Затем ищем панель для приоритетного энкодера
	panel = get_tree().get_root().find_child("TestResultsPanelEncoderPriority", true, false)
	if panel:
		return panel
	
	# Затем ищем панель для обычного энкодера
	panel = get_tree().get_root().find_child("TestResultsPanelEncoder", true, false)
	if panel:
		return panel
	
	# Затем ищем панель для 2-битного компаратора
	panel = get_tree().get_root().find_child("TestResultsPanel2BitComparator", true, false)
	if panel:
		return panel
	
	# Затем ищем панель для обычного компаратора
	panel = get_tree().get_root().find_child("TestResultsPanelComparator", true, false)
	if panel:
		return panel
	
	# Затем ищем другие возможные панели
	panel = get_tree().get_root().find_child("TestResultsPanel2BitAdder", true, false)
	if panel:
		return panel
	
	panel = get_tree().get_root().find_child("TestResultsPanelFullAdder", true, false)
	if panel:
		return panel
	
	panel = get_tree().get_root().find_child("TestResultsPanelHalfAdder", true, false)
	if panel:
		return panel
	
	panel = get_tree().get_root().find_child("TestResultsPanel3Inputs", true, false)
	if panel:
		return panel
	
	# Если не нашли, ищем обычную панель
	panel = get_tree().get_root().find_child("TestResultsPanel", true, false)
	return panel

# Новая функция для поиска GridContainer с обратной совместимостью
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
			print("InputBlock2: GridContainer not found for reset")
