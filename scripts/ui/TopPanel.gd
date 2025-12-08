extends ColorRect

@onready var level_name_label: Label = $MainContainer/CenterSection/LevelNameLabel
@onready var theory_button: TextureButton = $MainContainer/LeftSection/TheoryButton
@onready var menu_button: TextureButton = $MainContainer/LeftSection/MenuButton
@onready var map_button: TextureButton = $MainContainer/LeftSection/MapButton
@onready var run_button: TextureButton = $MainContainer/LeftSection/RunButton
@onready var gate_buttons_container = $MainContainer/RightSection/GateButtonsContainer
@onready var left_section: HBoxContainer = $MainContainer/LeftSection

var theory_window_instance: Window
var current_theory_text: String = ""
var hover_style: StyleBoxFlat
var current_level_number: int = 0
var glow_animation_tween: Tween
var is_tutorial: bool = false

func _ready():
	# Проверяем, находимся ли мы в обучалке
	var current_scene = get_tree().current_scene
	if current_scene and current_scene.name == "Tutorial":
		is_tutorial = true
		level_name_label.text = "Tutorial"
	
	# Устанавливаем фиксированную высоту панели
	custom_minimum_size = Vector2(0, 60)
	
	var viewport_size = get_viewport_rect().size
	size = Vector2(viewport_size.x, 60)
	
	# Создаем отступ слева другим способом
	_create_left_margin()
	
	# Подписываемся на изменение размера окна
	get_tree().root.connect("size_changed", _on_window_size_changed)
	
	# Инициализируем стили для кнопок
	_init_button_styles()
	
	hover_style = StyleBoxFlat.new()
	hover_style.bg_color = Color.YELLOW
	hover_style.corner_radius_top_left = 5
	hover_style.corner_radius_top_right = 5
	hover_style.corner_radius_bottom_right = 5
	hover_style.corner_radius_bottom_left = 5
	hover_style.border_width_left = 2
	hover_style.border_width_right = 2
	hover_style.border_width_top = 2
	hover_style.border_width_bottom = 2
	hover_style.border_color = Color.GOLD

	var theory_window_scene = load("res://scenes/ui/TheoryWindow.tscn")
	if theory_window_scene:
		theory_window_instance = theory_window_scene.instantiate()
		get_tree().root.add_child(theory_window_instance)
		theory_window_instance.visible = false
		
		if theory_window_instance.get_script() == null:
			push_error("TheoryWindow instance has no script assigned!")

	# Настройка кнопок
	_setup_buttons()
	
	# В обучалке скрываем кнопки ворот
	if is_tutorial and gate_buttons_container:
		for child in gate_buttons_container.get_children():
			child.visible = false
	
	# Определяем номер уровня только если не в обучалке
	if not is_tutorial:
		_determine_level_number()
		_check_theory_button_animation()

func _init_button_styles():
	# Создаем стили для кнопок, чтобы убрать белые линии при фокусе
	var focus_style = StyleBoxEmpty.new()
	
	# Применяем стили ко всем кнопкам в левой секции
	for child in left_section.get_children():
		if child is TextureButton:
			child.focus_mode = Control.FOCUS_NONE  # Отключаем фокус для кнопок
			# В Godot 4 используем add_theme_stylebox_override вместо theme_override_styles
			child.add_theme_stylebox_override("focus", focus_style)
			child.add_theme_stylebox_override("pressed", focus_style)
	
	# Также применяем к кнопкам ворот
	if gate_buttons_container:
		for child in gate_buttons_container.get_children():
			if child is Button:
				child.focus_mode = Control.FOCUS_NONE  # Отключаем фокус
				# В Godot 4 используем add_theme_stylebox_override для Button
				child.add_theme_stylebox_override("focus", focus_style)
				child.add_theme_stylebox_override("pressed", focus_style)

func _create_left_margin():
	# Вместо оборачивания в MarginContainer, просто добавляем отступ к левой секции
	# Изменяем минимальный размер левой секции и добавляем отступ через layout
	left_section.custom_minimum_size.x += 20  # Добавляем 20 пикселей к ширине
	
	# Создаем пустой Control для отступа
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(20, 0)
	
	# Добавляем его первым элементом в левую секцию
	left_section.add_child(spacer)
	left_section.move_child(spacer, 0)
	
	# Обновляем ссылки на кнопки, так как их индексы изменились
	_update_button_references()

func _update_button_references():
	# Обновляем ссылки на кнопки, так как мы добавили spacer первым элементом
	# Теперь кнопки находятся на позициях 1, 2, 3, 4 вместо 0, 1, 2, 3
	
	# Получаем все дочерние элементы левой секции
	var children = left_section.get_children()
	
	# Находим кнопки по их типу и текстуре
	for child in children:
		if child is TextureButton:
			# Проверяем, какая это кнопка по текстуре
			var texture_normal = child.texture_normal
			if texture_normal:
				var texture_path = texture_normal.resource_path
				
				if "menu.png" in texture_path:
					menu_button = child
				elif "teory.png" in texture_path:
					theory_button = child
				elif "map.png" in texture_path:
					map_button = child
				elif "run.png" in texture_path:
					run_button = child

func _setup_buttons():
	# Настройка кнопки меню
	if menu_button:
		menu_button.connect("mouse_entered", _on_button_mouse_entered.bind(menu_button))
		menu_button.connect("mouse_exited", _on_button_mouse_exited.bind(menu_button))
		# В обучалке кнопка меню возвращает в главное меню
		if is_tutorial:
			menu_button.connect("pressed", _on_tutorial_menu_pressed)
		else:
			menu_button.connect("pressed", _on_menu_pressed)
	
	# Настройка кнопки теории
	if theory_button:
		theory_button.connect("mouse_entered", _on_button_mouse_entered.bind(theory_button))
		theory_button.connect("mouse_exited", _on_button_mouse_exited.bind(theory_button))
		theory_button.connect("pressed", _on_theory_button_pressed)
	
	# Настройка кнопки карты
	if map_button:
		map_button.connect("mouse_entered", _on_button_mouse_entered.bind(map_button))
		map_button.connect("mouse_exited", _on_button_mouse_exited.bind(map_button))
		map_button.connect("pressed", _on_map_pressed)
		# В обучалке отключаем кнопку карты
		if is_tutorial:
			map_button.disabled = true
			map_button.modulate = Color(1, 1, 1, 0.5)
	
	# Настройка кнопки запуска
	if run_button:
		run_button.connect("mouse_entered", _on_button_mouse_entered.bind(run_button))
		run_button.connect("mouse_exited", _on_button_mouse_exited.bind(run_button))
		run_button.connect("pressed", _on_run_pressed)
		# В обучалке отключаем кнопку запуска
		if is_tutorial:
			run_button.disabled = true
			run_button.modulate = Color(1, 1, 1, 0.5)

func _on_tutorial_menu_pressed():
	# Возврат в главное меню из обучалки
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")

func _on_menu_pressed():
	# Обработка нажатия кнопки меню (для обычных уровней)
	print("Menu button pressed")
	# Здесь можно добавить логику для обычных уровней

func _on_map_pressed():
	# Обработка нажатия кнопки карты
	print("Map button pressed")
	# Здесь можно добавить логику перехода к карте

func _on_run_pressed():
	# Обработка нажатия кнопки запуска
	print("Run button pressed")
	# Здесь можно добавить логику запуска симуляции

func _on_window_size_changed():
	# Обновляем размер панели при изменении размера окна
	var window_size = get_viewport_rect().size
	size = Vector2(window_size.x, 60)
	
	# Принудительно обновляем layout
	queue_redraw()
	
	# Ждем следующего кадра для применения изменений
	await get_tree().process_frame
	
	# Принудительно обновляем контейнеры
	if has_node("MainContainer"):
		$MainContainer.queue_redraw()
		$MainContainer/LeftSection.queue_redraw()
		$MainContainer/CenterSection.queue_redraw()
		$MainContainer/RightSection.queue_redraw()

func _determine_level_number():
	var current_scene = get_tree().current_scene
	if current_scene:
		var scene_path = current_scene.scene_file_path
		if scene_path:
			var regex = RegEx.new()
			regex.compile("Level(\\d+)")
			var result = regex.search(scene_path)
			if result:
				current_level_number = result.get_string(1).to_int()
				print("Determined level number: ", current_level_number)
				return

		var scene_name = current_scene.name
		if "Level1" in scene_name: current_level_number = 1
		elif "Level2" in scene_name: current_level_number = 2
		elif "Level3" in scene_name: current_level_number = 3
		elif "Level4" in scene_name: current_level_number = 4
		elif "Level5" in scene_name: current_level_number = 5
		elif "Level6" in scene_name: current_level_number = 6
		elif "Level7" in scene_name: current_level_number = 7
		elif "Level8" in scene_name: current_level_number = 8
		elif "Level9" in scene_name: current_level_number = 9
		elif "Level10" in scene_name: current_level_number = 10
		elif "Level11" in scene_name: current_level_number = 11
		elif "Level12" in scene_name: current_level_number = 12
		elif "Level13" in scene_name: current_level_number = 13
		else: current_level_number = 0

func _check_theory_button_animation():
	if current_level_number > 0:
		var save_system = get_node_or_null("/root/SaveSystem")
		if save_system:
			var theory_viewed = save_system.is_theory_viewed(current_level_number)
			var failed_attempts = save_system.get_failed_attempts(current_level_number)
			
			if not theory_viewed or failed_attempts >= 5:
				print("Starting glow animation for level ", current_level_number)
				_start_glow_animation()
			else:
				_stop_glow_animation()
		else:
			print("SaveSystem not found")
	else:
		print("Could not determine level number")

func _start_glow_animation():
	if not theory_button:
		return

	if glow_animation_tween:
		glow_animation_tween.kill()
	
	glow_animation_tween = create_tween()
	glow_animation_tween.set_loops()

	var normal_color = Color.WHITE
	var glow_color = Color.ORANGE
	
	glow_animation_tween.tween_property(theory_button, "modulate", glow_color, 1.2)
	glow_animation_tween.tween_property(theory_button, "modulate", normal_color, 1.2)

func _stop_glow_animation():
	if glow_animation_tween:
		glow_animation_tween.kill()
		glow_animation_tween = null

	if theory_button:
		theory_button.modulate = Color.WHITE

func _on_theory_button_pressed():
	_stop_glow_animation()

	if current_level_number > 0:
		var save_system = get_node_or_null("/root/SaveSystem")
		if save_system:
			save_system.set_theory_viewed(current_level_number, true)
			print("Theory viewed flag saved for level ", current_level_number)

	if not theory_window_instance:
		push_error("Theory window instance is null")
		return
		
	if current_theory_text == "":
		push_error("No theory text set")
		return

	if theory_window_instance.has_method("set_theory_text"):
		theory_window_instance.set_theory_text(current_theory_text)
		theory_window_instance.popup_centered(Vector2(800, 600))
	else:
		push_error("TheoryWindow instance missing 'set_theory_text' method")
		create_fallback_theory_window()

func update_gate_buttons_state(gate_counts: Dictionary, gate_limits: Dictionary):
	for child in gate_buttons_container.get_children():
		var gate_type = child.name
		if gate_limits.has(gate_type):
			var current_count = gate_counts.get(gate_type, 0)
			var limit = gate_limits[gate_type]
			child.disabled = (current_count >= limit)

			if child.disabled:
				child.modulate = Color(1, 1, 1, 0.5) 
			else:
				child.modulate = Color(1, 1, 1, 1)

func _on_button_mouse_entered(button: TextureButton):
	if not button.disabled:
		button.modulate = Color.YELLOW

func _on_button_mouse_exited(button: TextureButton):
	if button.disabled:
		button.modulate = Color(1, 1, 1, 0.5)
	else:
		button.modulate = Color.WHITE

func set_level_name(name: String):
	if level_name_label:
		level_name_label.text = name

func set_theory_text(text: String):
	current_theory_text = text

func create_fallback_theory_window():
	var fallback_window = Window.new()
	fallback_window.title = "Theory"
	fallback_window.size = Vector2(800, 600)
	
	var rich_text = RichTextLabel.new()
	rich_text.bbcode_enabled = true
	rich_text.text = current_theory_text
	rich_text.scroll_active = true
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	margin.add_child(rich_text)
	
	fallback_window.add_child(margin)
	get_tree().root.add_child(fallback_window)
	fallback_window.popup_centered()
