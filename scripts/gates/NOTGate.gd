extends Node2D

@onready var in1 = $In1
@onready var output = $Output

@export var outputs: Array[Node2D]
@export var inputs: Array[Node2D]

func _ready():
	output.eval_func = func(call_idx: int):
		return not in1.get_value(call_idx)
	inputs = [ in1 ]
	outputs = [ output ]
