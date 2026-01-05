extends Gate

@onready var name_label: Label = $Name
@export var cur_value: bool

func _ready() -> void:
	super._ready()
	outputs = [ $Output ]
	outputs[0].eval_func = func(_call_idx: int): return cur_value

func set_label(text: String): name_label.text = text
