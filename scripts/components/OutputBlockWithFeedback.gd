# OutputBlockWithFeedback.gd
extends Node2D
class_name OutputBlockWithFeedback

var received_value = 0
var output_value = 0
var expected = []
var test_results_panel: Node
var area: Area2D
var output_type: String = "Q"  # Для D-защелки

# Используем @onready для безопасного получения узлов
@onready var input_port = $InputPort
@onready var output_port = $Output
@onready var sprite = $Sprite2D  # Теперь получаем спрайт через @onready

func _ready():
	print("OutputBlockWithFeedback ready! Has set_input: ", has_method("set_input"))
	
	# Добавляем Area2D только для обнаружения наведения
	area = Area2D.new()
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	
	# Устанавливаем размер области равной размеру спрайта
	if sprite:
		var texture_size = sprite.texture.get_size()
		shape.size = texture_size
		collision.shape = shape
		area.position = sprite.position
		
	area.add_child(collision)
	add_child(area)
	
	# Настраиваем Area2D так, чтобы он обнаруживал мышь, но не мешал основной логике
	area.input_pickable = true
	area.collision_layer = 2
	area.collision_mask = 0
	
	# Подключаем сигналы Area2D
	area.mouse_entered.connect(_on_area_mouse_entered)
	area.mouse_exited.connect(_on_area_mouse_exited)

func set_input(port_name, value):
	print("OutputBlockWithFeedback set_input called with value: ", value)
	received_value = value
	# Немедленно обновляем выходное значение для обратной связи
	output_value = value

func get_output(port_name):
	return output_value

func get_current_output():
	return output_value

func reset_inputs():
	# Не сбрасываем output_value - это важно для памяти защелки!
	received_value = 0

func set_default_style():
	if sprite:
		sprite.texture = load("res://assets/q.png")

func set_correct_style():
	if sprite:
		sprite.texture = load("res://assets/output_cur_q.png")

func _on_area_mouse_entered():
	_highlight_desired_output()

func _on_area_mouse_exited():
	_reset_all_highlights()

func _highlight_desired_output():
	if not test_results_panel:
		test_results_panel = _find_dlatch_test_results_panel()
		if not test_results_panel:
			print("OutputBlockWithFeedback: TestResultsPanel not found")
			return
	
	# Сбрасываем все подсветки через метод панели, если он есть
	if test_results_panel.has_method("reset_all_highlights"):
		test_results_panel.reset_all_highlights()
	else:
		# Если метода нет, сбрасываем вручную
		_reset_all_highlights()
	
	# Определяем, какие заголовки искать в зависимости от типа вывода
	var labels_to_highlight = []
	
	match output_type:
		"Q":
			# Для D-защелки подсвечиваем и Desired Q и Current Q
			labels_to_highlight = ["Desired Q", "Current Q"]
		_:
			labels_to_highlight = ["Desired Output"]
	
	var grid = _find_dlatch_grid_container()
	if grid:
		var found = false
		# Ищем по всем возможным вариантам названий
		for label_text in labels_to_highlight:
			for child in grid.get_children():
				if child is Label and child.text.strip_edges() == label_text:
					child.modulate = Color.YELLOW
					found = true
					print("OutputBlockWithFeedback: Highlighted label: '", label_text, "'")
			if found:
				break
		
		if not found:
			print("OutputBlockWithFeedback: None of these labels found: ", labels_to_highlight)
	else:
		print("OutputBlockWithFeedback: GridContainer not found in test panel")

func _find_dlatch_test_results_panel():
	# Ищем панель для D-защелки
	var panel = get_tree().get_root().find_child("TestResultsPanelDLatch", true, false)
	if panel:
		return panel
	
	# Также можно попробовать найти по группам
	for node in get_tree().get_nodes_in_group("test_panel"):
		if "DLatch" in node.name:
			return node
	
	return null

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

func _reset_all_highlights():
	if test_results_panel:
		if test_results_panel.has_method("reset_all_highlights"):
			test_results_panel.reset_all_highlights()
		else:
			var grid = _find_dlatch_grid_container()
			if grid:
				for child in grid.get_children():
					if child is Label:
						child.modulate = Color.WHITE

# Также обновим InputBlockSingle.gd для более надежного поиска
