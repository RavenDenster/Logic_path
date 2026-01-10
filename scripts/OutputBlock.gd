extends Gate

@onready var name_label: Label = $Name
@onready var body: Sprite2D = $Sprite

@export var is_good: bool : set = _set_is_good

var DEFAULT_TINT_BAD = Color(0.8, 0.58, 0.56, 1.0)
var HOVER_TINT_BAD = Color(1.0, 0.725, 0.7, 1.0)
var DEFAULT_TINT_GOOD = Color(0.62, 0.8, 0.56, 1.0)
var HOVER_TINT_GOOD = Color(0.775, 1.0, 0.7, 1.0)

func _set_is_good(val: bool):
	is_good = val
	body.modulate = DEFAULT_TINT_GOOD if is_good else DEFAULT_TINT_BAD

func _ready() -> void:
	inputs = [ $In1 ]
	if OS.get_name() != "Web":
		name_label.add_theme_font_override("font", msdf_font)

func set_label(text: String):
	name_label.text = text
