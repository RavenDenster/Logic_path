
extends CanvasLayer

var screen_size = Vector2(1920, 1080)

var levels_data = [
	{"number": 1, "scene": "res://scenes/levels/Level1.tscn"},
	{"number": 2, "scene": "res://scenes/levels/Level2.tscn"},
	{"number": 3, "scene": "res://scenes/levels/Level3.tscn"},
	{"number": 4, "scene": "res://scenes/levels/Level4.tscn"},  
	{"number": 5, "scene": "res://scenes/levels/Level5.tscn"},  
	{"number": 6, "scene": "res://scenes/levels/Level6.tscn"},  
	{"number": 7, "scene": "res://scenes/levels/Level7.tscn"}, 
	{"number": 8, "scene": "res://scenes/levels/Level8.tscn"}, 
	{"number": 9, "scene": "res://scenes/levels/Level9.tscn"}, 
	{"number": 10, "scene": "res://scenes/levels/Level10.tscn"}, 
	{"number": 11, "scene": "res://scenes/levels/Level11.tscn"}, 
	{"number": 12, "scene": "res://scenes/levels/Level12.tscn"},
	{"number": 13, "scene": "res://scenes/levels/Level13.tscn"},
	{"number": 14, "scene": "res://scenes/levels/Level14.tscn"},
	{"number": 15, "scene": "res://scenes/levels/Level15.tscn"},
	{"number": 16, "scene": "res://scenes/levels/Level16.tscn"},
	{"number": 17, "scene": "res://scenes/levels/Level17.tscn"},
	{"number": 18, "scene": "res://scenes/levels/Level18.tscn"},
	{"number": 19, "scene": "res://scenes/levels/Level19.tscn"},
	{"number": 20, "scene": "res://scenes/levels/Level20.tscn"},
	{"number": 21, "scene": "res://scenes/levels/Level21.tscn"},
	{"number": 22, "scene": "res://scenes/levels/Level22.tscn"},
	{"number": 23, "scene": "res://scenes/levels/Level23.tscn"},
	{"number": 24, "scene": "res://scenes/levels/Level24.tscn"},
	{"number": 25, "scene": "res://scenes/levels/Level25.tscn"},
	{"number": 26, "scene": "res://scenes/levels/Level26.tscn"},
	{"number": 27, "scene": "res://scenes/levels/Level27.tscn"},
	{"number": 28, "scene": "res://scenes/levels/Level30.tscn"},
	{"number": 29, "scene": "res://scenes/levels/Level29.tscn"},
	{"number": 30, "scene": "res://scenes/levels/Level30.tscn"}
]

var current_scroll = 0
var max_scroll = 0
var level_groups = []
var level_container
var scroll_speed = 300  # Скорость прокрутки в пикселях в секунду
var level_name_label
var section_separators = []  # Массив для хранения разделителей

func _ready():
	screen_size = get_viewport().get_visible_rect().size
	
	# Создаем контейнер для всех кнопок уровней
	level_container = Node2D.new()
	add_child(level_container)
	
	setup_back_button()
	setup_level_name_label()
	group_levels()
	create_level_buttons()
	create_section_separators()  # Создаем разделители до установки лимитов прокрутки
	setup_scroll_limits()
	
	# Отладочная информация
	var save_system = get_node_or_null("/root/SaveSystem")
	if save_system:
		print("LevelMap: Unlocked levels from save: ", save_system.game_data.get("unlocked_levels", []))
	
	# Начинаем с самого низа
	current_scroll = max_scroll
	update_level_positions()  # Обновляем позиции после установки скролла

func setup_level_name_label():
	# Создаем метку для отображения названия уровня
	level_name_label = Label.new()
	level_name_label.name = "LevelNameLabel"
	level_name_label.visible = false  # Сначала скрыта
	level_name_label.position = Vector2(screen_size.x - 400, 20)  # Правый верхний угол
	level_name_label.add_theme_font_size_override("font_size", 20)
	level_name_label.modulate = Color.WHITE
	level_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(level_name_label)

func group_levels():
	# Группируем уровни по тематическим группам
	level_groups = [
		# Основы логических элементов (7 уровней)
		[
			{"number": 1, "scene": "res://scenes/levels/Level1.tscn"},
			{"number": 2, "scene": "res://scenes/levels/Level2.tscn"},
			{"number": 3, "scene": "res://scenes/levels/Level3.tscn"}
		],
		[
			{"number": 4, "scene": "res://scenes/levels/Level4.tscn"},
			{"number": 5, "scene": "res://scenes/levels/Level5.tscn"},
			{"number": 6, "scene": "res://scenes/levels/Level6.tscn"}
		],
		[
			{"number": 7, "scene": "res://scenes/levels/Level7.tscn"}
		],
		# Трехвходовые схемы (5 уровней)
		[
			{"number": 8, "scene": "res://scenes/levels/Level8.tscn"},
			{"number": 9, "scene": "res://scenes/levels/Level9.tscn"},
			{"number": 10, "scene": "res://scenes/levels/Level10.tscn"}
		],
		[
			{"number": 11, "scene": "res://scenes/levels/Level11.tscn"},
			{"number": 12, "scene": "res://scenes/levels/Level12.tscn"}
		],
		# Арифметические схемы (6 уровней)
		[
			{"number": 13, "scene": "res://scenes/levels/Level13.tscn"},
			{"number": 14, "scene": "res://scenes/levels/Level14.tscn"},
			{"number": 15, "scene": "res://scenes/levels/Level15.tscn"}
		],
		[
			{"number": 16, "scene": "res://scenes/levels/Level16.tscn"},
			{"number": 17, "scene": "res://scenes/levels/Level17.tscn"},
			{"number": 18, "scene": "res://scenes/levels/Level18.tscn"}
		],
		# Компараторы и кодеры (6 уровней)
		[
			{"number": 19, "scene": "res://scenes/levels/Level19.tscn"},
			{"number": 20, "scene": "res://scenes/levels/Level20.tscn"},
			{"number": 21, "scene": "res://scenes/levels/Level21.tscn"}
		],
		[
			{"number": 22, "scene": "res://scenes/levels/Level22.tscn"},
			{"number": 23, "scene": "res://scenes/levels/Level23.tscn"},
			{"number": 24, "scene": "res://scenes/levels/Level24.tscn"}
		],
		# Последовательностная логика (6 уровней)
		[
			{"number": 25, "scene": "res://scenes/levels/Level25.tscn"},
			{"number": 26, "scene": "res://scenes/levels/Level26.tscn"},
			{"number": 27, "scene": "res://scenes/levels/Level27.tscn"}
		],
		[
			{"number": 28, "scene": "res://scenes/levels/Level30.tscn"},
			{"number": 29, "scene": "res://scenes/levels/Level29.tscn"},
			{"number": 30, "scene": "res://scenes/levels/Level30.tscn"}
		]
	]

func create_section_separators():
	# Определяем позиции и названия разделов
	var sections = [
		{"name": "BASICS LIGICAL ELEMENTS", "position": 2.5},  # После 7 уровней (группы 0,1,2)
		{"name": "THREE-INPUT CIRCUITS", "position": 4.5},           # После 5 уровней (группы 3,4)
		{"name": "ARITHMETIC SCHEMES", "position": 6.5},        # После 6 уровней (группы 5,6)
		{"name": "COMPARATORS AND ENCODERS", "position": 8.5},        # После 6 уровней (группы 7,8)
		{"name": "SEQUENTIAL LOGIC", "position": 10.5} # После 6 уровней (группы 9,10) - ДОБАВЛЕН ПЯТЫЙ РАЗДЕЛ
	]
	
	for section in sections:
		create_section_separator(section.name, section.position)

func create_section_separator(section_name, group_position):
	# Создаем контейнер для разделителя
	var separator = Node2D.new()
	separator.name = "Separator_" + section_name
	level_container.add_child(separator)
	section_separators.append(separator)
	
	# Создаем текст раздела - сдвигаем ниже линии
	var label = Label.new()
	label.name = "Label"
	label.text = section_name
	label.add_theme_font_size_override("font_size", 24)
	label.modulate = Color(1, 1, 1, 0.5)  # Полупрозрачный текст
	label.position = Vector2(100, 15)  # Текст ниже линии
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	separator.add_child(label)
	
	# Создаем пунктирную линию из множества маленьких линий
	create_dashed_line_with_segments(separator, section_name)

func create_dashed_line_with_segments(separator, section_name):
	# Линия почти на весь экран с небольшими отступами
	var line_start = 50  # Отступ слева
	var line_end = screen_size.x - 50  # Отступ справа
	
	# Параметры пунктира - меньше черточек, но крупнее
	var dash_length = 40  # Длина черточки
	var gap_length = 20   # Длина промежутка
	var line_width = 3    # Толщина линии
	
	# Создаем пунктирную линию из отдельных сегментов
	var current_x = line_start
	while current_x < line_end:
		var dash_end = min(current_x + dash_length, line_end)
		
		# Создаем отдельный сегмент линии
		var segment = Line2D.new()
		segment.width = line_width
		segment.default_color = Color(1, 1, 1, 0.3)  # Полупрозрачный белый
		
		# Устанавливаем точки для сегмента
		segment.add_point(Vector2(current_x, 0))
		segment.add_point(Vector2(dash_end, 0))
		
		# Добавляем сегмент к разделителю
		separator.add_child(segment)
		
		# Переходим к следующему сегменту
		current_x = dash_end + gap_length

func setup_scroll_limits():
	# Вычисляем максимальное смещение для прокрутки
	var group_count = level_groups.size()
	var visible_groups = 4  # Количество групп, видимых одновременно
	max_scroll = max(0, (group_count - visible_groups) * 180)
	current_scroll = max_scroll  # Начинаем с самого низа

func setup_back_button():
	var back_button = get_node_or_null("BackButton")
	if back_button:
		back_button.connect("pressed", _on_back_button_pressed)
		back_button.position = Vector2(50, 50)
		# Добавляем обработчики событий мыши для подсветки
		back_button.connect("mouse_entered", _on_back_button_mouse_entered.bind(back_button))
		back_button.connect("mouse_exited", _on_back_button_mouse_exited.bind(back_button))
	else:
		back_button = TextureButton.new()
		back_button.name = "BackButton"
		back_button.position = Vector2(20, 20)
		var texture = preload("res://assets/menu.png") if ResourceLoader.exists("res://assets/menu.png") else null
		if texture:
			back_button.texture_normal = texture
		back_button.custom_minimum_size = Vector2(80, 80)
		add_child(back_button)
		back_button.connect("pressed", _on_back_button_pressed)
		# Добавляем обработчики событий мыши для подсветки
		back_button.connect("mouse_entered", _on_back_button_mouse_entered.bind(back_button))
		back_button.connect("mouse_exited", _on_back_button_mouse_exited.bind(back_button))

func _on_back_button_mouse_entered(button: TextureButton):
	if not button.disabled:
		button.modulate = Color.YELLOW

func _on_back_button_mouse_exited(button: TextureButton):
	if button.disabled:
		button.modulate = Color(1, 1, 1, 0.5)
	else:
		button.modulate = Color.WHITE

func is_group_unlocked(group_index):
	if group_index == 0:
		return true  # Первая группа всегда разблокирована
	
	var previous_group = level_groups[group_index - 1]
	var save_system = get_node_or_null("/root/SaveSystem")
	if not save_system:
		return false
	
	# Считаем количество пройденных уровней в предыдущей группе
	var completed_count = 0
	for level in previous_group:
		if save_system.is_level_completed(level.number):
			completed_count += 1
	
	# Если в группе 3 уровня, нужно пройти 2
	# Если в группе меньше 3 уровней, нужно пройти все
	var required_count = previous_group.size()
	if previous_group.size() == 3:
		required_count = 2
	
	return completed_count >= required_count

func create_level_buttons():
	var save_system = get_node_or_null("/root/SaveSystem")
	if not save_system:
		push_error("LevelMap: Cannot create buttons - SaveSystem not found!")
		return
	
	var completed_levels = save_system.get_completed_levels()
	print("LevelMap: Creating buttons with save data: ", completed_levels)
	print("LevelMap: Unlocked levels: ", save_system.game_data.get("unlocked_levels", []))
	
	for group_index in level_groups.size():
		var group = level_groups[group_index]
		var group_unlocked = is_group_unlocked(group_index)
		
		for level_index in group.size():
			var level = group[level_index]
			var is_completed = save_system.is_level_completed(level.number)
			
			# Проверяем, разблокирован ли уровень через чит
			var is_unlocked = false
			if save_system.game_data.has("unlocked_levels"):
				is_unlocked = level.number in save_system.game_data["unlocked_levels"]
			
			print("LevelMap: Level ", level.number, " completed: ", is_completed, ", group unlocked: ", group_unlocked, ", is_unlocked: ", is_unlocked)
			
			var button = TextureButton.new()
			button.name = "Level%dButton" % level.number
			button.custom_minimum_size = Vector2(80, 80)
			
			var completed_texture = preload("res://assets/checkmark.png") if ResourceLoader.exists("res://assets/checkmark.png") else null
			var normal_texture = preload("res://assets/in_progress.png") if ResourceLoader.exists("res://assets/in_progress.png") else null
			var locked_texture = preload("res://assets/checkmark_block.png") if ResourceLoader.exists("res://assets/checkmark_block.png") else null
			
			# Уровень разблокирован, если разблокирована группа или через чит
			var level_unlocked = group_unlocked or is_unlocked
			
			if level_unlocked:
				if is_completed and completed_texture:
					button.texture_normal = completed_texture
				elif normal_texture:
					button.texture_normal = normal_texture
					
				button.connect("pressed", _on_level_button_pressed.bind(level.scene))
				# ДОБАВЛЯЕМ ОБРАБОТЧИКИ НАВЕДЕНИЯ ДЛЯ РАЗБЛОКИРОВАННЫХ УРОВНЕЙ
				button.connect("mouse_entered", _on_level_button_mouse_entered.bind(level.number))
				button.connect("mouse_exited", _on_level_button_mouse_exited)
			else:
				if locked_texture:
					button.texture_normal = locked_texture
				# Для заблокированных уровней не подключаем обработчики наведения
				
			button.stretch_mode = TextureButton.STRETCH_SCALE
			
			# УБИРАЕМ СОЗДАНИЕ И ДОБАВЛЕНИЕ LABEL С ЦИФРАМИ
			level_container.add_child(button)

func _on_level_button_mouse_entered(level_number: int):
	# Получаем название уровня из данных уровня
	var level_name = get_level_name(level_number)
	if level_name:
		level_name_label.text = level_name
		level_name_label.visible = true

func _on_level_button_mouse_exited():
	# Скрываем метку при уходе мыши
	level_name_label.visible = false

func get_level_name(level_number: int) -> String:
	# Функция для получения названия уровня по его номеру
	# Можно расширить этот словарь для всех 30 уровней
	var level_names = {
		1: "Level 1: OR Gate",
		2: "Level 2: AND Gate", 
		3: "Level 3: NAND Gate",
		4: "Level 4: NOR Gate",
		5: "Level 5: XOR Gate",
		6: "Level 6: Implication",
		7: "Level 7: XNOR Gate",
		8: "Level 8: Majority Gate",
		9: "Level 9: Parity Check (XOR Cascade)",
		10: "Level 10: Conditional Selector",
		11: "Level 11: Pattern Detector",
		12: "Level 12: 3-input Multiplexer",
		13: "Level 13: Half Adder",
		14: "Level 14: Full Adder",
		15: "Level 15: 2-Bit Adder",
		16: "Level 16: Half Subtractor",
		17: "Level 17: Full Subtractor",
		18: "Level 18: Simple ALU",
		19: "Level 19: 1-bit Comparator",
		20: "Level 20: 2-bit Comparator",
		21: "Level 21: 4-to-2 Encoder",
		22: "Level 22: Priority Encoder",
		23: "Level 23: 2->4 Decoder",
		24: "Level 24: 3->8 Decoder",
		25: "Level 25: RS-триггер на NOR",
		26: "Level 26: D-защелка",
		27: "Level 27: Clocked D-Flip-Flop",
		28: "Level 28:",
		29: "Level 29: 2-bit Counter",
		30: "Level 30: 4-bit Shift Register"
	}
	
	return level_names.get(level_number, "Level " + str(level_number))

func update_level_positions():
	var center = screen_size / 2
	
	for group_index in level_groups.size():
		var group = level_groups[group_index]
		# Уровни идут снизу вверх, поэтому инвертируем групповой индекс
		var group_y = center.y + 300 - group_index * 180 + current_scroll
		
		# Центрируем группу по горизонтали с отступами
		var group_width = group.size() * 160  # 80 + 40 отступ
		var start_x = center.x - (group_width - 120) / 2
		
		for level_index in group.size():
			var level = group[level_index]
			var button = level_container.get_node_or_null("Level%dButton" % level.number)
			if button:
				var x = start_x + level_index * 160  # 80 + 40 отступ
				button.position = Vector2(x - 40, group_y - 40)
	
	# Обновляем позиции разделителей
	update_separator_positions()

func update_separator_positions():
	var center = screen_size / 2
	
	# Позиции разделителей (после групп 2, 4, 6, 8, 10)
	var separator_positions = [2.5, 4.5, 6.5, 8.5, 10.5]  # Добавлена позиция 10.5 для пятого раздела
	
	for i in range(separator_positions.size()):
		var group_position = separator_positions[i]
		if i < section_separators.size():
			var separator = section_separators[i]
			# Размещаем разделитель между группами
			var separator_y = center.y + 300 - (group_position) * 180 + current_scroll
			separator.position = Vector2(0, separator_y)

func _process(delta):
	# Обработка непрерывной прокрутки при зажатых клавишах
	if Input.is_action_pressed("ui_up"):  # W - вверх
		current_scroll = min(max_scroll, current_scroll + scroll_speed * delta)
		update_level_positions()
	elif Input.is_action_pressed("ui_down"):  # S - вниз
		current_scroll = max(0, current_scroll - scroll_speed * delta)
		update_level_positions()

func _input(event):
	# Также обрабатываем колесо мыши
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			current_scroll = min(max_scroll, current_scroll + 50)
			update_level_positions()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			current_scroll = max(0, current_scroll - 50)
			update_level_positions()

func _on_level_button_pressed(scene_path):
	print("Attempting to load scene: ", scene_path)
	
	if ResourceLoader.exists(scene_path):
		print("Scene exists, loading...")
		get_tree().change_scene_to_file(scene_path)
	else:
		push_error("Scene not found: " + scene_path)
		var error_label = Label.new()
		error_label.text = "ERROR: Scene not found: " + scene_path
		error_label.add_theme_color_override("font_color", Color.RED)
		error_label.position = Vector2(100, 100)
		add_child(error_label)

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
