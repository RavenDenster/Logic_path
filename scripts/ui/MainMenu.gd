extends Control

@onready var confirmation_dialog = get_node_or_null("ConfirmationDialog")

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
		if get_tree().current_scene.name == "LevelMap":
			get_tree().reload_current_scene()
	else:
		push_error("SaveSystem not found!")
