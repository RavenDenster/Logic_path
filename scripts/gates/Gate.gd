class_name Gate
extends Node2D

var hover_tint = ThemeDB.get_project_theme().get_stylebox("hover", "Button").bg_color
var default_tint = ThemeDB.get_project_theme().get_stylebox("normal", "Button").bg_color
var drag_tint = ThemeDB.get_project_theme().get_stylebox("pressed", "Button").bg_color

signal hovered
signal dragged

@export var removable: bool = true
@export var inputs: Array[Node2D]
@export var outputs: Array[Node2D]

var sprite
@export var is_hovered: bool = false
@export var is_dragged: bool = false
var offset = Vector2(0, 0)

func _hover():
	is_hovered = true
	hovered.emit()
	if not is_dragged: sprite.modulate = hover_tint

func _unhover():
	is_hovered = false
	if not is_dragged: sprite.modulate = default_tint

func _on_area_input_event(viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseMotion:
		viewport.set_input_as_handled()
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			is_dragged = true
			dragged.emit()
			sprite.modulate = drag_tint
			offset = global_position - get_global_mouse_position()
			viewport.set_input_as_handled()
		elif event.is_released() and is_dragged:
			is_dragged = false
			sprite.modulate = hover_tint
			viewport.set_input_as_handled()

func _process(_delta):
	if is_dragged:
		global_position = get_global_mouse_position() + offset
		for input in inputs:
			input.position_changed.emit()
		for output in outputs:
			output.position_changed.emit()

func _ready() -> void:
	var area: Area2D = $Area
	sprite = $Sprite
	area.mouse_entered.connect(_hover)
	area.mouse_exited.connect(_unhover)
	area.input_event.connect(_on_area_input_event)
	
	sprite.modulate = default_tint
	show()
