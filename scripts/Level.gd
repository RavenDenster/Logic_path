extends Node2D

@onready var level_panel: PanelContainer = find_child("LevelPanel")

const INPUT_SCENE: PackedScene = preload("res://scenes/blocks/InputBlock.tscn")
const OUTPUT_SCENE: PackedScene = preload("res://scenes/blocks/OutputBlock.tscn")

func create_inputs():
	for i in range(LevelInfo.data.n_inputs):
		var input = INPUT_SCENE.instantiate()
		level_panel.add_child(input)
		input.set_label(LevelInfo.data.input_names[i])
		input.position = Vector2(80, 30 + i*100)

func create_outputs():
	for i in range(LevelInfo.data.n_outputs):
		var input = OUTPUT_SCENE.instantiate()
		level_panel.add_child(input)
		input.set_label(LevelInfo.data.output_names[i])
		input.position = Vector2(500, 30 + i*100)

func _ready() -> void:
	create_inputs()
	create_outputs()

func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
