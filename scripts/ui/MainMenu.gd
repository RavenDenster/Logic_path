extends Control

@onready var random_level_window = $RandomLevelWindow

var f_press_count = 0
var cheat_active = false

func _ready():
	if OS.get_name() == "Web":
		$Panel/WebWindow.visible = true

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
	MessageDisplay.display_message("Все уровни разблокированы")

func unlock_all_levels(save_system):
	var all_levels = []
	for i in range(1, 31):
		all_levels.append(i)
	
	save_system.unlock_levels(all_levels)

func _on_open_map_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/LevelMap.tscn")

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

func _on_statistics_button_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/Statistics.tscn")

func _on_random_level_pressed() -> void:
	random_level_window.popup_centered()

func _on_web_window_close_requested() -> void:
	$Panel/WebWindow.visible = false
