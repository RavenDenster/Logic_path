extends Control

var input1_textures = []
var input2_textures = []
var desired_textures = []
var current_textures = []

func _ready():
	anchor_left = 0.0
	anchor_right = 1.0
	anchor_top = 1.0
	anchor_bottom = 1.0
	
	_update_panel_position()

	# Устанавливаем фиксированную высоту панели
	custom_minimum_size = Vector2(0, 160)
	
	var viewport_size = get_viewport_rect().size
	size = Vector2(viewport_size.x, 160)
	
	# Подписываемся на изменение размера окна
	get_tree().root.connect("size_changed", _on_window_size_changed)
	
	# Инициализируем текстуры на следующем кадре
	call_deferred("initialize_textures")

func initialize_textures():
	# Ждем один кадр для полной инициализации
	await get_tree().process_frame
	
	if not has_node("Background/GridContainer"):
		print("WARNING: Background/GridContainer not found! Creating fallback...")
		create_fallback_panel()
		return
	
	var grid_container = $Background/GridContainer
	
	if grid_container.get_child_count() < 24:
		print("WARNING: GridContainer has only ", grid_container.get_child_count(), " children, expected 24")
		create_fallback_panel()
		return

	# Инициализируем массивы текстур
	input1_textures = []
	input2_textures = []
	desired_textures = []
	current_textures = []
	
	# Собираем текстуры из GridContainer
	for i in range(4):
		if i+1 < grid_container.get_child_count():
			input1_textures.append(grid_container.get_child(i+1))
	
	for i in range(4):
		if i+7 < grid_container.get_child_count():
			input2_textures.append(grid_container.get_child(i+7))
	
	for i in range(4):
		if i+13 < grid_container.get_child_count():
			desired_textures.append(grid_container.get_child(i+13))
	
	for i in range(4):
		if i+19 < grid_container.get_child_count():
			current_textures.append(grid_container.get_child(i+19))
	
	print("TestResultsPanel: Successfully initialized with ", input1_textures.size(), " textures per category")

func create_fallback_panel():
	print("Creating fallback panel for tutorial")
	# Создаем простую панель для обучалки
	var background = ColorRect.new()
	background.color = Color(0.1, 0.1, 0.15, 0.8)
	background.size = size
	add_child(background)
	
	var label = Label.new()
	label.text = "Tutorial Mode - Test Panel"
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_font_size_override("font_size", 24)
	label.position = Vector2(20, 20)
	add_child(label)

func load_initial_data(inputs_a, inputs_b, expected_outputs):
	# Ждем инициализации текстур
	if input1_textures.is_empty():
		await initialize_textures()
	
	if input1_textures.is_empty():
		print("ERROR: Still no textures after initialization!")
		return

	# Загружаем данные
	for i in range(min(4, inputs_a.size())):
		if i < input1_textures.size() and input1_textures[i]:
			var texture = load("res://assets/pointGreen.png") if inputs_a[i] == 1 else load("res://assets/point.png")
			if texture:
				input1_textures[i].texture = texture

	for i in range(min(4, inputs_b.size())):
		if i < input2_textures.size() and input2_textures[i]:
			var texture = load("res://assets/pointGreen.png") if inputs_b[i] == 1 else load("res://assets/point.png")
			if texture:
				input2_textures[i].texture = texture

	for i in range(min(4, expected_outputs.size())):
		if i < desired_textures.size() and desired_textures[i]:
			var texture = load("res://assets/pointGreen.png") if expected_outputs[i] == 1 else load("res://assets/point.png")
			if texture:
				desired_textures[i].texture = texture

	print("TestResultsPanel: Initial data loaded for tutorial")

func update_results(inputs_a, inputs_b, expected_outputs, actual_outputs):
	load_initial_data(inputs_a, inputs_b, expected_outputs)

	for i in range(min(4, actual_outputs.size())):
		if i < current_textures.size() and current_textures[i]:
			var texture = load("res://assets/pointGreen.png") if actual_outputs[i] == 1 else load("res://assets/point.png")
			if texture:
				current_textures[i].texture = texture
	
	print("TestResultsPanel: Results updated with current outputs")

func update_current_outputs(actual_outputs):
	if current_textures.is_empty():
		print("WARNING: Textures arrays are empty!")
		return
	
	for i in range(min(4, actual_outputs.size())):
		if i < current_textures.size() and current_textures[i]:
			var texture = load("res://assets/pointGreen.png") if actual_outputs[i] == 1 else load("res://assets/point.png")
			if texture:
				current_textures[i].texture = texture
	
	print("TestResultsPanel: Current outputs updated")

func _update_panel_position():
	var window_size = get_viewport_rect().size
	custom_minimum_size = Vector2(window_size.x, 160)
	size = Vector2(window_size.x, 160)
	position = Vector2(0, window_size.y - 160)
	queue_redraw()

func _on_window_size_changed():
	var window_size = get_viewport_rect().size
	custom_minimum_size = Vector2(window_size.x, 160)
	size = Vector2(window_size.x, 160)
	position = Vector2(0, window_size.y - 160)
	queue_redraw()
