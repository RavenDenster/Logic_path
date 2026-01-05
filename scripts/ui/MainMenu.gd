extends Control

@onready var random_level_window = $RandomLevelWindow

func _ready():
	$PlatformLabel.text = "OS: %s. %s. %s" % [
		OS.get_name(),
		"Debug" if OS.is_debug_build() else "Release",
		"Standalone" if OS.has_feature("standalone") else "Editor"
	]
	if OS.get_name() == "Web":
		if not SaveSystemGlobal.displayed_warning:
			$WebWindow.popup_centered()
			SaveSystemGlobal.displayed_warning = true
		$Center/VBox/QuitButton.visible = false
		$Center/VBox/LevelEditor.disabled = true

func _on_open_map_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/LevelMap.tscn")

func _on_quit_button_pressed():
	print("QUIT pressed - exiting")
	get_tree().quit()

func _on_level_editor_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/LevelCreator.tscn")

func _on_statistics_button_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/Statistics.tscn")

func _on_random_level_pressed() -> void:
	random_level_window.popup_centered()

func _on_web_window_close_requested() -> void:
	$WebWindow.visible = false
