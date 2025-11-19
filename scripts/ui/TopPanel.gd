extends ColorRect

@onready var level_name_label: Label = $LevelNameLabel
@onready var theory_button: TextureButton = $HBoxContainer/TheoryButton
@onready var menu_button: TextureButton = $HBoxContainer/MenuButton
@onready var map_button: TextureButton = $HBoxContainer/MapButton
@onready var run_button: TextureButton = $HBoxContainer/RunButton

var theory_window_instance: Window
var current_theory_text: String = ""
var hover_style: StyleBoxFlat

func _ready():
	# Создаем стиль для подсветки
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

	# Загрузка теории окна
	var theory_window_scene = preload("res://scenes/ui/TheoryWindow.tscn")
	if theory_window_scene:
		theory_window_instance = theory_window_scene.instantiate()
		get_tree().root.add_child(theory_window_instance)
		theory_window_instance.visible = false
		
		if theory_window_instance.get_script() == null:
			push_error("TheoryWindow instance has no script assigned!")

	# Подключаем сигналы для каждой кнопки отдельно
	if menu_button:
		menu_button.connect("mouse_entered", _on_button_mouse_entered.bind(menu_button))
		menu_button.connect("mouse_exited", _on_button_mouse_exited.bind(menu_button))
	
	if theory_button:
		theory_button.connect("mouse_entered", _on_button_mouse_entered.bind(theory_button))
		theory_button.connect("mouse_exited", _on_button_mouse_exited.bind(theory_button))
		theory_button.connect("pressed", _on_theory_button_pressed)
	
	if map_button:
		map_button.connect("mouse_entered", _on_button_mouse_entered.bind(map_button))
		map_button.connect("mouse_exited", _on_button_mouse_exited.bind(map_button))
	
	if run_button:
		run_button.connect("mouse_entered", _on_button_mouse_entered.bind(run_button))
		run_button.connect("mouse_exited", _on_button_mouse_exited.bind(run_button))

func _on_button_mouse_entered(button: TextureButton):
	button.modulate = Color.YELLOW  # Изменяем цвет кнопки

func _on_button_mouse_exited(button: TextureButton):
	button.modulate = Color.WHITE  # Возвращаем исходный цвет

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
