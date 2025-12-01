extends Control

@onready var rows_container = $TableContainer/VBoxContainer/RowsContainer/RowsVBox
@onready var back_button = $BackButton

var level_template = preload("res://scenes/ui/LevelStatRow.tscn")

func _ready():
	back_button.pressed.connect(_on_back_button_pressed)
	load_statistics()
	
	# Устанавливаем фокус на кнопку назад для удобства клавиатуры
	back_button.grab_focus()

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")

func load_statistics():
	# Очищаем контейнер с данными (оставляем только заголовки)
	for child in rows_container.get_children():
		child.queue_free()
	
	var save_system = get_node_or_null("/root/SaveSystem")
	if not save_system:
		print("SaveSystem not found!")
		show_error_message("Save system not found")
		return
	
	var total_levels = 30  # ИСПРАВЛЕНО: было 23, теперь 30
	
	# Получаем все статистики
	var all_stats = save_system.get_all_level_stats()
	
	# Создаем строки для каждого уровня
	for level_num in range(1, total_levels + 1):
		var level_str = str(level_num)
		var stats = all_stats.get(level_str, {})
		
		var row = level_template.instantiate()
		rows_container.add_child(row)
		
		# Заполняем данные
		var level_name = "Level %d" % level_num
		var completed = stats.get("completed", false)
		var attempts = stats.get("attempts", 0)
		var best_time = stats.get("best_time", 0)
		
		row.set_data(level_num, level_name, completed, best_time, attempts)
	
	# Добавляем отступ снизу
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	rows_container.add_child(spacer)

func show_error_message(message: String):
	var error_label = Label.new()
	error_label.text = message
	error_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	error_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	error_label.add_theme_color_override("font_color", Color.RED)
	rows_container.add_child(error_label)

func _input(event):
	# Добавляем обработку клавиши Escape для возврата в меню
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			_on_back_button_pressed()
