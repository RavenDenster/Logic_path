# InputBlockS.gd
extends Node2D

var values = []
var current_test_index = 0
var area: Area2D

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

func get_output(port_name: String) -> int:
	var result = values[current_test_index]
	print("InputBlock output: ", result)
	return result

func reset_inputs():
	pass

func get_input_count() -> int:
	return 1

func _on_area_mouse_entered():
	print("InputBlockS mouse entered")
	_highlight_input_label()

func _on_area_mouse_exited():
	print("InputBlockS mouse exited")
	_reset_all_highlights()

func _highlight_input_label():
	# Ищем TestResultsPanelRS в дереве сцены
	var panel = get_tree().get_root().find_child("TestResultsPanelRS", true, false)
	if panel and panel.has_method("highlight_labels"):
		print("Found TestResultsPanelRS, highlighting label 1 (Input S)")
		panel.highlight_labels([1])  # Индекс 1 = "Input S"
	else:
		print("TestResultsPanelRS not found or missing highlight_labels method")

func _reset_all_highlights():
	# Ищем TestResultsPanelRS в дереве сцены
	var panel = get_tree().get_root().find_child("TestResultsPanelRS", true, false)
	if panel and panel.has_method("reset_all_highlights"):
		panel.reset_all_highlights()
