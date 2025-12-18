extends Node2D

@onready var name_label: Label = $Name
@onready var body: Sprite2D = $Body/Sprite

@export var outputs: Array[Node2D]
@export var cur_value: bool

const HOVER_TINT = Color(1, 1, 1)
const DEFAULT_TINT = Color(0.8, 0.8, 0.8)

func _ready() -> void:
	body.modulate = DEFAULT_TINT
	outputs = [ $Output ]
	outputs[0].eval_func = func(_call_idx: int): return cur_value

func set_label(text: String): name_label.text = text
func _on_body_mouse_entered() -> void: body.modulate = HOVER_TINT
func _on_body_mouse_exited() -> void: body.modulate = DEFAULT_TINT

var is_dragging = false
var offset = Vector2(0, 0)
func _on_body_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed: is_dragging = true; offset = global_position - get_global_mouse_position();
		else: is_dragging = false
		
func _process(_delta):
	if is_dragging:
		global_position = get_global_mouse_position() + offset
