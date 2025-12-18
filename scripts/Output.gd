extends Area2D

signal wire_started(input_node, position)
signal position_changed()
signal recursion_detected()

@export var connected_to: Array[Node2D]
@export var eval_func: Callable
var last_call: int = -1

var DEF_TINT = Color(0.8, 0.8, 0.8)
var HOVER_TINT = Color(1, 1, 1)

func get_value(call_idx: int) -> bool:
	if call_idx == last_call:
		recursion_detected.emit()
		return false
	
	last_call = call_idx
	return eval_func.call(call_idx)

func _ready() -> void:
	modulate = DEF_TINT

func _on_mouse_entered() -> void:
	modulate = HOVER_TINT

func _on_mouse_exited() -> void:
	modulate = DEF_TINT

func _on_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			wire_started.emit(self, global_position)

func _notification(what: int):
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		position_changed.emit()
