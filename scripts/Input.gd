extends Node2D
class_name InputNode

signal wire_ended(input_node, position)
signal select_wire(wire)
signal position_changed()

@export var wire_ref: Wire
@export var connected_to: Output = null

var hover_tint = ThemeDB.get_project_theme().get_stylebox("hover", "Button").bg_color
var default_tint = ThemeDB.get_project_theme().get_stylebox("normal", "Button").bg_color
var pressed_tint = ThemeDB.get_project_theme().get_stylebox("pressed", "Button").bg_color

var is_pressed: bool = false
var mouse_inside: bool = false
@onready var sprite = $Sprite

func get_value(call_idx: int) -> bool:
	if not connected_to: return false
	return connected_to.get_value(call_idx)

func _ready() -> void:
	sprite.modulate = default_tint

func _on_area_2d_mouse_entered() -> void:
	mouse_inside = true
	sprite.modulate = hover_tint

func _on_area_2d_mouse_exited() -> void:
	mouse_inside = false
	sprite.modulate = default_tint

func _on_area_2d_input_event(viewport: Viewport, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_released():
			is_pressed = false
			sprite.modulate = hover_tint if mouse_inside else default_tint
			wire_ended.emit(self, global_position)
			viewport.set_input_as_handled()
			
		elif event.is_pressed():
			is_pressed = true
			sprite.modulate = pressed_tint
			
			if not wire_ref: return
			connected_to = null
			wire_ref.reset_position_changed_connection()
			wire_ref.output_node = null
			wire_ref.input_node.connected_to.erase(self)
			select_wire.emit(wire_ref)
			viewport.set_input_as_handled()
