extends Area2D

signal wire_ended(input_node, position)
signal select_wire(wire)
signal position_changed()

@export var wire_ref: Node2D
@export var connected_to: Node2D = null

var DEF_TINT = Color(0.8, 0.8, 0.8)
var HOVER_TINT = Color(1, 1, 1)

func get_value(call_idx: int) -> bool:
	if not connected_to: return false
	return connected_to.get_value(call_idx)

func _ready() -> void:
	modulate = DEF_TINT

func _on_mouse_entered() -> void:
	modulate = HOVER_TINT

func _on_mouse_exited() -> void:
	modulate = DEF_TINT

func _on_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_released():
			wire_ended.emit(self, global_position)
		elif event.is_pressed():
			if not wire_ref: return
			connected_to = null
			wire_ref.reset_position_changed_connection()
			wire_ref.output_node = null
			wire_ref.input_node.connected_to.erase(self)
			select_wire.emit(wire_ref)
			

func _notification(what: int):
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		position_changed.emit()
