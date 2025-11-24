# OutputBlock.gd (добавляем поддержку типа EXPECTED)
extends Node2D

var received_value: int = 0
var expected = []
var main_sprite: Sprite2D
var test_results_panel: Node
var area: Area2D
var output_type: String = "DEFAULT"  # "DEFAULT", "SUM", "CARRY", "COUT", "S1", "S0", "RESULT", "EXPECTED"

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
	area.collision_layer = 2  # Используем отдельный слой для обнаружения наведения
	area.collision_mask = 0   # Не обнаруживаем другие объекты
	
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
	# Запускаем подсветку при наведении
	_highlight_desired_output()

func _on_area_mouse_exited():
	# Сбрасываем подсветку при уходе мыши
	_reset_all_highlights()

func _highlight_desired_output():
	if not test_results_panel:
		# Ищем TestResultsPanel в дереве сцены
		test_results_panel = _find_test_results_panel()
		if not test_results_panel:
			return
	
	# Сбрасываем все подсветки
	_reset_all_highlights()
	
	# Определяем, какую метку подсвечивать в зависимости от типа выхода
	var label_to_highlight = "Desired Output"  # По умолчанию
	
	match output_type:
		"SUM":
			label_to_highlight = "Desired Sum"
		"CARRY":
			label_to_highlight = "Desired Carry"
		"COUT":
			label_to_highlight = "Desired Cout"
		"S1":
			label_to_highlight = "Desired S1"
		"S0":
			label_to_highlight = "Desired S0"
		"RESULT":
			label_to_highlight = "Desired Result"
		"EXPECTED":
			label_to_highlight = "Expected"  # Для ALU уровня
	
	# Находим и подсвечиваем соответствующую метку
	var grid = test_results_panel.get_node("Background/GridContainer")
	if grid:
		var found = false
		for child in grid.get_children():
			if child is Label and child.text.strip_edges() == label_to_highlight:
				child.modulate = Color.YELLOW
				found = true
				print("OutputBlock: Highlighted label: '", label_to_highlight, "'")
				break
		
		if not found:
			print("OutputBlock: Label not found: '", label_to_highlight, "'")
			# Выведем все доступные метки для отладки
			print("Available labels:")
			for child in grid.get_children():
				if child is Label:
					print("  - '", child.text, "'")
	else:
		print("OutputBlock: GridContainer not found in test panel")

func _find_test_results_panel():
	# Сначала ищем панель для ALU
	var panel = get_tree().get_root().find_child("TestResultsPanelAlu", true, false)
	if panel:
		return panel
	
	# Если не нашли, ищем панель для 2-Bit Adder
	panel = get_tree().get_root().find_child("TestResultsPanel2BitAdder", true, false)
	if panel:
		return panel
	
	# Если не нашли, ищем панель для Full Adder
	panel = get_tree().get_root().find_child("TestResultsPanelFullAdder", true, false)
	if panel:
		return panel
	
	# Если не нашли, ищем панель для Half Adder
	panel = get_tree().get_root().find_child("TestResultsPanelHalfAdder", true, false)
	if panel:
		return panel
	
	# Если не нашли, ищем панель для трех входов
	panel = get_tree().get_root().find_child("TestResultsPanel3Inputs", true, false)
	if panel:
		return panel
	
	# Если не нашли, ищем обычную панель
	panel = get_tree().get_root().find_child("TestResultsPanel", true, false)
	return panel

func _reset_all_highlights():
	if test_results_panel:
		var grid = test_results_panel.get_node("Background/GridContainer")
		for child in grid.get_children():
			if child is Label:
				child.modulate = Color.WHITE
