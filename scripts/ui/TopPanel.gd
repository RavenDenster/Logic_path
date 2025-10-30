extends ColorRect

@onready var level_name_label: Label = $LevelNameLabel
@onready var theory_button: TextureButton = $HBoxContainer/TheoryButton

var theory_window_instance: Window
var current_theory_text: String = ""

func _ready():
	var theory_window_scene = preload("res://scenes/ui/TheoryWindow.tscn")
	if theory_window_scene:
		theory_window_instance = theory_window_scene.instantiate()
		get_tree().root.add_child(theory_window_instance)
		theory_window_instance.visible = false
		
		if theory_window_instance.get_script() == null:
			push_error("TheoryWindow instance has no script assigned!")

	if theory_button:
		theory_button.connect("pressed", _on_theory_button_pressed)

func set_level_name(name: String):
	if level_name_label:
		level_name_label.text = name

func set_theory_text(text: String):
	current_theory_text = text

func _on_theory_button_pressed():
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
