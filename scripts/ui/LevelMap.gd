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
	{"number": 21, "scene": "res://scenes/levels/Level21.tscn"}
]

func _ready():
	screen_size = get_viewport().get_visible_rect().size
	
	setup_back_button()
	create_level_buttons()

func setup_back_button():
	var back_button = get_node_or_null("BackButton")
	if back_button:
		back_button.connect("pressed", _on_back_button_pressed)
		back_button.position = Vector2(50, 50)
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

func create_level_buttons():
	var center = screen_size / 2

	# Обновляем позиции для 9 уровней (3 ряда по 3)
	var positions = [
		# Первый ряд
		center + Vector2(-200, -300),  # Уровень 1
		center + Vector2(0, -300),     # Уровень 2  
		center + Vector2(200, -300),   # Уровень 3
		# Второй ряд
		center + Vector2(-200, -100),  # Уровень 4
		center + Vector2(0, -100),     # Уровень 5
		center + Vector2(200, -100),   # Уровень 6
		# Третий ряд  
		center + Vector2(-200, 100),   # Уровень 7
		center + Vector2(0, 100),      # Уровень 8
		center + Vector2(200, 100),    # Уровень 9
		# Четвертый ряд
		center + Vector2(-200, 300),   # Уровень 10
		center + Vector2(0, 300),      # Уровень 11 
		center + Vector2(200, 300),    # Уровень 12
		# Пятый ряд
		center + Vector2(-200, 400),   # Уровень 13
		center + Vector2(0, 400),      # Уровень 14
		center + Vector2(200, 400),    # Уровень 15
		# Шестой ряд
		center + Vector2(400, 400),    # Уровень 16
		center + Vector2(600, 400),    # Уровень 17
		center + Vector2(800, 400),    # Уровень 18
		# Седьмой ряд
		center + Vector2(400, 200),    # Уровень 19
		center + Vector2(600, 200),    # Уровень 20
		center + Vector2(800, 200)     # Уровень 21
	]
	
	var save_system = get_node_or_null("/root/SaveSystem")
	if not save_system:
		push_error("LevelMap: Cannot create buttons - SaveSystem not found!")
		return
	
	var completed_levels = save_system.get_completed_levels()
	print("LevelMap: Creating buttons with save data: ", completed_levels)
	
	for i in range(levels_data.size()):
		var level = levels_data[i]
		var btn_position = positions[i]
		
		var is_completed = save_system.is_level_completed(level.number)
		print("LevelMap: Level ", level.number, " completed: ", is_completed)
		
		var button = TextureButton.new()
		button.name = "Level%dButton" % level.number
		button.position = btn_position - Vector2(40, 40)
		button.custom_minimum_size = Vector2(80, 80)
		
		var completed_texture = preload("res://assets/checkmark.png") if ResourceLoader.exists("res://assets/checkmark.png") else null
		var normal_texture = preload("res://assets/in_progress.png") if ResourceLoader.exists("res://assets/in_progress.png") else null
		
		if is_completed and completed_texture:
			button.texture_normal = completed_texture
		elif normal_texture:
			button.texture_normal = normal_texture
			
		button.stretch_mode = TextureButton.STRETCH_SCALE
		
		var label = Label.new()
		label.text = str(level.number)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.size = Vector2(80, 80)
		label.add_theme_color_override("font_color", Color.WHITE)
		button.add_child(label)
		
		button.connect("pressed", _on_level_button_pressed.bind(level.scene))
		add_child(button)

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
