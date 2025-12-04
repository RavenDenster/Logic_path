# OutputBlockNotQ.gd
extends Node2D

var received_value: int = 0
var expected = []
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
		var texture = load("res://assets/!q.png")
		if texture:
			$Sprite2D.texture = texture
		else:
			print("ERROR: Cannot load output.png")

func set_correct_style():
	if has_node("Sprite2D"):
		var texture = load("res://assets/output_cur_notq.png")
		if texture:
			$Sprite2D.texture = texture
		else:
			print("ERROR: Cannot load output_correct.png")

func _on_area_mouse_entered():
	print("OutputBlockNotQ mouse entered")
	_highlight_output_labels()

func _on_area_mouse_exited():
	print("OutputBlockNotQ mouse exited")
	_reset_all_highlights()

func _highlight_output_labels():
	# Ищем TestResultsPanelRS в дереве сцены
	var panel = get_tree().get_root().find_child("TestResultsPanelRS", true, false)
	if panel and panel.has_method("highlight_labels"):
		print("Found TestResultsPanelRS, highlighting labels 3 and 5 (Desired !Q and Current !Q)")
		panel.highlight_labels([3, 5])  # Индекс 3 = "Desired !Q", 5 = "Current !Q"
	else:
		print("TestResultsPanelRS not found or missing highlight_labels method")

func _reset_all_highlights():
	# Ищем TestResultsPanelRS в дереве сцены
	var panel = get_tree().get_root().find_child("TestResultsPanelRS", true, false)
	if panel and panel.has_method("reset_all_highlights"):
		panel.reset_all_highlights()
