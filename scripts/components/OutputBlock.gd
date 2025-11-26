extends Node2D

var received_value: int = 0
var expected = []
var main_sprite: Sprite2D
var test_results_panel: Node
var area: Area2D
var output_type: String = "DEFAULT"

func _ready():
	print("OutputBlock ready! Has set_input: ", has_method("set_input"))
	main_sprite = $Sprite2D
	
	# Добавляем Area2D только для обнаружения наведения
	area = Area2D.new()
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	
	# Устанавливаем размер области равной размеру спрайта
	if main_sprite:
		var texture_size = main_sprite.texture.get_size()
		shape.size = texture_size
		collision.shape = shape
		area.position = main_sprite.position
		
	area.add_child(collision)
	add_child(area)
	
	# Настраиваем Area2D так, чтобы он обнаруживал мышь, но не мешал основной логике
	area.input_pickable = true
	area.collision_layer = 2
	area.collision_mask = 0
	
	# Подключаем сигналы Area2D
	area.mouse_entered.connect(_on_area_mouse_entered)
	area.mouse_exited.connect(_on_area_mouse_exited)

func set_input(_port: int, val: int):
	print("OutputBlock set_input: ", val)
	received_value = val

func reset_inputs():
	print("OutputBlock reset_inputs")
	received_value = 0

func set_correct_style():
	if main_sprite:
		main_sprite.texture = preload("res://assets/outputGreen.png")

func set_default_style():
	if main_sprite:
		main_sprite.texture = preload("res://assets/output.png")

func _on_area_mouse_entered():
	_highlight_desired_output()

func _on_area_mouse_exited():
	_reset_all_highlights()

func _highlight_desired_output():
	if not test_results_panel:
		test_results_panel = _find_test_results_panel()
		if not test_results_panel:
			return
	
	_reset_all_highlights()
	
	# Определяем, какие заголовки искать в зависимости от типа вывода
	var labels_to_highlight = []
	
	match output_type:
		"SUM":
			labels_to_highlight = ["Desired SUM", "Desired Sum", "Desired Output"]
		"CARRY":
			labels_to_highlight = ["Desired CARRY", "Desired Carry", "Desired Output"]
		"DIFFERENCE":
			labels_to_highlight = ["Desired DIFFERENCE", "Desired Difference", "Desired Output"]
		"BORROW":
			labels_to_highlight = ["Desired BORROW", "Desired Borrow", "Desired Output"]
		"BOUT":
			labels_to_highlight = ["Desired BOUT", "Desired Bout", "Desired Output"]
		"COUT":
			labels_to_highlight = ["Desired Cout", "Desired Output"]
		"S1":
			labels_to_highlight = ["Desired S1", "Desired Output"]
		"S0":
			labels_to_highlight = ["Desired S0", "Desired Output"]
		"RESULT":
			labels_to_highlight = ["Desired Result", "Desired Output"]
		"EXPECTED":
			labels_to_highlight = ["Expected", "Desired Output"]
		_:
			labels_to_highlight = ["Desired Output"]
	
	var grid = _find_grid_container()
	if grid:
		var found = false
		# Ищем по всем возможным вариантам названий
		for label_text in labels_to_highlight:
			for child in grid.get_children():
				if child is Label and child.text.strip_edges() == label_text:
					child.modulate = Color.YELLOW
					found = true
					print("OutputBlock: Highlighted label: '", label_text, "'")
					break
			if found:
				break
		
		if not found:
			print("OutputBlock: None of these labels found: ", labels_to_highlight)
			# Для отладки выведем все доступные Label
			print("Available labels in grid:")
			for child in grid.get_children():
				if child is Label:
					print("  - '", child.text.strip_edges(), "'")
	else:
		print("OutputBlock: GridContainer not found in test panel")

func _find_test_results_panel():
	var panel = get_tree().get_root().find_child("TestResultsPanelAlu", true, false)
	if panel:
		return panel
	
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
	
	panel = get_tree().get_root().find_child("TestResultsPanel", true, false)
	return panel

# Новая функция для поиска GridContainer с обратной совместимостью
func _find_grid_container():
	if not test_results_panel:
		return null
	
	# Пробуем разные пути для обратной совместимости
	var grid = test_results_panel.get_node_or_null("Background/GridContainer")
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
			print("OutputBlock: GridContainer not found for reset")
