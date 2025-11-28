extends Control

@onready var confirmation_dialog = get_node_or_null("ConfirmationDialog")
var f_press_count = 0
var cheat_active = false

func _ready():
	var play_campaign_btn = get_node_or_null("VBoxContainer/PlayCampaignButton")
	var open_map_btn = get_node_or_null("VBoxContainer/OpenMapButton")
	var new_game_btn = get_node_or_null("VBoxContainer/NewGameButton")
	var quit_btn = get_node_or_null("VBoxContainer/QuitButton")
	
	if play_campaign_btn:
		play_campaign_btn.pressed.connect(_on_play_campaign_pressed)
	if open_map_btn:
		open_map_btn.pressed.connect(_on_open_map_pressed)
	if new_game_btn:
		new_game_btn.pressed.connect(_on_new_game_pressed)
	if quit_btn:
		quit_btn.pressed.connect(_on_quit_button_pressed)
	
	if confirmation_dialog:
		confirmation_dialog.dialog_text = "Are you sure you want to reset all progress? This cannot be undone."
		confirmation_dialog.confirmed.connect(_on_confirmation_confirmed)
	
	

func _input(event):
	# Обработка чит-кода по нажатию F
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F:
			var save_system = get_node_or_null("/root/SaveSystem")
			
			# Проверяем, прошел ли игрок хотя бы 1 уровень
			var has_completed_levels = false
			if save_system:
				has_completed_levels = save_system.get_completed_levels().size() > 0
			
			# Если нет пройденных уровней и чит не активирован, игнорируем нажатия
			if not has_completed_levels and not cheat_active:
				f_press_count = 0  # Сбрасываем счетчик
				return
			
			# Если чит уже активирован, игнорируем нажатия
			if cheat_active:
				return
			
			f_press_count += 1
			print("F pressed: ", f_press_count, " times")
			
			# Активируем чит после 15 нажатий
			if f_press_count >= 15:
				activate_cheat()

func activate_cheat():
	cheat_active = true
	print("Cheat activated! All levels unlocked.")
	
	var save_system = get_node_or_null("/root/SaveSystem")
	if save_system:
		# Отмечаем все уровни как открытые (но не пройденные)
		unlock_all_levels(save_system)
		
		print("All levels have been unlocked!")
		
		# Показываем серое сообщение об активации чеата
		show_cheat_message("All levels unlocked!", Color.GRAY)
	else:
		push_error("SaveSystem not found!")

func unlock_all_levels(save_system):
	# Создаем массив всех номеров уровней
	var all_levels = []
	for i in range(1, 31):
		all_levels.append(i)
	
	# Используем новый метод unlock_levels в SaveSystem
	if save_system.has_method("unlock_levels"):
		save_system.unlock_levels(all_levels)
	else:
		# Если метода нет, используем старый способ, но обязательно сохраняем
		if not save_system.game_data.has("unlocked_levels"):
			save_system.game_data["unlocked_levels"] = []
		
		for level_num in all_levels:
			if not level_num in save_system.game_data["unlocked_levels"]:
				save_system.game_data["unlocked_levels"].append(level_num)
		
		save_system.save_game()

func show_cheat_message(text, color = Color.GRAY):
	# Создаем временное сообщение в левом верхнем углу
	var message = Label.new()
	message.text = text
	message.add_theme_color_override("font_color", color)
	message.add_theme_font_size_override("font_size", 24)
	message.position = Vector2(20, 20)  # Левый верхний угол
	add_child(message)
	
	# Удаляем сообщение через 3 секунды
	await get_tree().create_timer(3.0).timeout
	if is_instance_valid(message):
		message.queue_free()

func _on_play_campaign_pressed():
	var save_system = get_node_or_null("/root/SaveSystem")
	if save_system:
		var next_level = save_system.get_next_level_to_play()
		var scene_path = "res://scenes/levels/Level%d.tscn" % next_level
		
		if ResourceLoader.exists(scene_path):
			print("Play Campaign pressed - loading level ", next_level)
			get_tree().change_scene_to_file(scene_path)
		else:
			print("Level scene not found: ", scene_path, " - loading level map instead")
			get_tree().change_scene_to_file("res://scenes/ui/LevelMap.tscn")
	else:
		print("SaveSystem not found - loading level map")
		get_tree().change_scene_to_file("res://scenes/ui/LevelMap.tscn")

func _on_open_map_pressed():
	print("Open Map pressed - loading level map")
	get_tree().change_scene_to_file("res://scenes/ui/LevelMap.tscn")

func _on_new_game_pressed():
	print("New Game pressed - showing confirmation")
	if confirmation_dialog:
		confirmation_dialog.popup_centered()
	else:
		reset_game_progress()

func _on_quit_button_pressed():
	print("QUIT pressed - exiting")
	get_tree().quit()

func _on_confirmation_confirmed():
	reset_game_progress()

func reset_game_progress():
	var save_system = get_node_or_null("/root/SaveSystem")
	if save_system:
		save_system.reset_progress()
		print("All progress has been reset")
		# Деактивируем чит при сбросе прогресса
		if cheat_active:
			cheat_active = false
			f_press_count = 0
		if get_tree().current_scene.name == "LevelMap":
			get_tree().reload_current_scene()
	else:
		push_error("SaveSystem not found!")
