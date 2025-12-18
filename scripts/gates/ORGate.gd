extends Node2D

@onready var in1 = $In1
@onready var in2 = $In2
@onready var output = $Output

@export var outputs: Array[Node2D]
@export var inputs: Array[Node2D]

func _ready():
	output.eval_func = func(call_idx: int):
		return in1.get_value(call_idx) or in2.get_value(call_idx)
	inputs = [ in1, in2 ]
	outputs = [ output ]
