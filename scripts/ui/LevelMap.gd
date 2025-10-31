extends CanvasLayer

var screen_size = Vector2(1920, 1080)

var levels_data = [
	{"number": 1, "scene": "res://scenes/levels/Level1.tscn"},
	{"number": 2, "scene": "res://scenes/levels/Level2.tscn"},
	{"number": 3, "scene": "res://scenes/levels/Level3.tscn"},
	{"number": 4, "scene": "res://scenes/levels/Level4.tscn"},
	{"number": 5, "scene": "res://scenes/levels/Level5.tscn"},
	{"number": 6, "scene": "res://scenes/levels/Level6.tscn"},
	{"number": 7, "scene": "res://scenes/levels/Level7.tscn"}
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

	var positions = [
		center + Vector2(-200, -150),  # Уровень 1
		center + Vector2(0, -150),     # Уровень 2
		center + Vector2(200, -150),   # Уровень 3
		center + Vector2(-100, 0),     # Уровень 4
		center + Vector2(100, 0),      # Уровень 5
		center + Vector2(-100, 150),   # Уровень 6
		center + Vector2(100, 150)     # Уровень 7
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
	if ResourceLoader.exists(scene_path):
		get_tree().change_scene_to_file(scene_path)
	else:
		push_error("Scene not found: " + scene_path)

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
