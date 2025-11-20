# InputBlock2.gd
extends Node2D
class_name InputBlock2

var values_A = []
var values_B = []
var current_test_index = 0
var test_results_panel: Node
var highlight_timer: Timer
var area: Area2D

func _ready():
	# Создаем таймер для подсветки
	highlight_timer = Timer.new()
	add_child(highlight_timer)
	highlight_timer.timeout.connect(_on_highlight_timeout)
	
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
		test_results_panel = get_tree().get_root().find_child("TestResultsPanel", true, false)
		if not test_results_panel:
			return
	
	# Останавливаем предыдущий таймер
	highlight_timer.stop()
	
	# Сбрасываем все подсветки
	_reset_all_highlights()
	
	# Находим и подсвечиваем метки Input 1 и Input 2
	var grid = test_results_panel.get_node("Background/GridContainer")
	for child in grid.get_children():
		if child is Label:
			if child.text == "Input 1" or child.text == "Input 2":
				child.modulate = Color.YELLOW
	
	# Запускаем таймер на 3 секунды
	highlight_timer.start(4.0)

func _on_highlight_timeout():
	_reset_all_highlights()

func _reset_all_highlights():
	if test_results_panel:
		var grid = test_results_panel.get_node("Background/GridContainer")
		for child in grid.get_children():
			if child is Label:
				child.modulate = Color.WHITE
