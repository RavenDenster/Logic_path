extends Node2D

@onready var name_label: Label = $Name
@onready var body: Sprite2D = $Body/Sprite

@export var inputs: Array[Node2D]
@export var is_good: bool : set = _set_is_good

var DEFAULT_TINT_BAD = Color(0.8, 0.58, 0.56, 1.0)
var HOVER_TINT_BAD = Color(1.0, 0.725, 0.7, 1.0)
var DEFAULT_TINT_GOOD = Color(0.62, 0.8, 0.56, 1.0)
var HOVER_TINT_GOOD = Color(0.775, 1.0, 0.7, 1.0)

var is_dragging = false
var offset = Vector2(0, 0)

func _set_is_good(val: bool):
	is_good = val
	body.modulate = DEFAULT_TINT_GOOD if is_good else DEFAULT_TINT_BAD

func _ready() -> void:
	body.modulate = DEFAULT_TINT_BAD
	inputs = [ $In1 ]

func set_label(text: String):
	name_label.text = text

func _on_body_mouse_entered() -> void:
	body.modulate = HOVER_TINT_GOOD if is_good else HOVER_TINT_BAD

func _on_body_mouse_exited() -> void:
	body.modulate = DEFAULT_TINT_GOOD if is_good else DEFAULT_TINT_BAD

func _on_body_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			offset = global_position - get_global_mouse_position()
		else:
			is_dragging = false

func _process(_delta):
	if is_dragging:
		global_position = get_global_mouse_position() + offset
