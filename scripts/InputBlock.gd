extends Node2D

@onready var name_label: Label = $Name
@onready var body: Sprite2D = $Body/Sprite

var is_dragging = false
var offset = Vector2(0, 0)

func _ready() -> void:
	body.modulate = Color(0.6, 0.6, 0.6)

func set_label(text: String):
	name_label.text = text

func _on_output_mouse_entered() -> void:
	pass

func _on_body_mouse_entered() -> void:
	body.modulate = Color(0.8, 0.8, 0.8)

func _on_body_mouse_exited() -> void:
	body.modulate = Color(0.6, 0.6, 0.6)

func _on_body_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			offset = global_position - get_global_mouse_position()
		else:
			is_dragging = false


func _process(_delta):
	if is_dragging:
		global_position = get_global_mouse_position() + offset
