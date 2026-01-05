extends Node2D
class_name Output

signal wire_started(input_node, position)
signal position_changed()
signal recursion_detected()

@export var connected_to: Array[Node2D]
@export var eval_func: Callable

var hover_tint = ThemeDB.get_project_theme().get_stylebox("hover", "Button").bg_color
var default_tint = ThemeDB.get_project_theme().get_stylebox("normal", "Button").bg_color
var pressed_tint = ThemeDB.get_project_theme().get_stylebox("pressed", "Button").bg_color
@onready var sprite = $Sprite

var is_pressed: bool = false
var mouse_inside: bool = false

var cur_value: bool
var last_call_idx: int = -1
var marked: bool = false

func get_value(call_idx: int) -> bool:
	if last_call_idx != call_idx:
		if marked:
			recursion_detected.emit()
			return false
		
		marked = true
		cur_value = eval_func.call(call_idx)
		last_call_idx = call_idx
		marked = false
	return cur_value

func _ready() -> void:
	sprite.modulate = default_tint

func _on_area_2d_mouse_entered() -> void:
	mouse_inside = true
	sprite.modulate = hover_tint

func _on_area_2d_mouse_exited() -> void:
	mouse_inside = false
	sprite.modulate = default_tint

func _on_area_2d_input_event(viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_pressed = true
			sprite.modulate = pressed_tint
			wire_started.emit(self, global_position)
			viewport.set_input_as_handled()
		elif event.is_released():
			sprite.modulate = hover_tint if mouse_inside else default_tint
			is_pressed = false
			viewport.set_input_as_handled()
