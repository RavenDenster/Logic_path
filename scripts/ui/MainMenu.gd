extends Control

@onready var confirmation_dialog = get_node("ConfirmationDialog")
var f_press_count = 0
var cheat_active = false

@onready var play_campaign_btn = $CenterContainer/VBoxContainer/PlayCampaignButton

func _ready() -> void:
	var save_system = get_node("/root/SaveSystem")
	if len(save_system.get_completed_levels()) == 0:
		play_campaign_btn.text = "Начать"

func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F:	
			f_press_count += 1
			if f_press_count >= 15 and not cheat_active:
				activate_cheat()

func activate_cheat():
	cheat_active = true
	var save_system = get_node("/root/SaveSystem")
	unlock_all_levels(save_system)
	show_message("All levels unlocked!")

func unlock_all_levels(save_system):
	var all_levels = []
	for i in range(1, 31):
		all_levels.append(i)
	
	save_system.unlock_levels(all_levels)

func show_message(text: String):
	var label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_font_size_override("font_size", 24)
	
	var panel = Panel.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.7)
	panel.add_theme_stylebox_override("panel", style)
	
	panel.add_child(label)
	label.position = Vector2(10, 10)
	
	add_child(panel)
	panel.position = Vector2(20, 20)
	
	var sound = AudioStreamPlayer.new()
	sound.stream = load("res://assets/message.mp3")
	add_child(sound)
	sound.play()
	
	await get_tree().process_frame
	panel.size = label.size + Vector2(20, 20)
	
	await get_tree().create_timer(5.0).timeout
	
	var tween = create_tween()
	tween.tween_property(panel, "modulate:a", 0.0, 1.0)
	await tween.finished
	panel.queue_free()

func _on_play_campaign_button_pressed() -> void:
	var save_system = get_node("/root/SaveSystem")
	var next_level = save_system.get_next_level_to_play()
	var scene_path = "res://scenes/levels/Level%d.tscn" % next_level
	
	if ResourceLoader.exists(scene_path):
		get_tree().change_scene_to_file(scene_path)
	else:
		get_tree().change_scene_to_file("res://scenes/ui/LevelMap.tscn")

func _on_open_map_button_pressed() -> void:
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

func reset_game_progress():
	var save_system = get_node("/root/SaveSystem")
	save_system.reset_progress()
	
	cheat_active = false
	f_press_count = 0
	
	if get_tree().current_scene.name == "LevelMap":
		get_tree().reload_current_scene()

func _on_level_editor_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/LevelCreator.tscn")

func _on_confirmation_dialog_confirmed() -> void:
	reset_game_progress()

func _on_tutorial_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/Tutorial.tscn")

func _on_statistics_button_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/Statistics.tscn")
