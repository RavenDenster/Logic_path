extends Gate

@onready var in1 = $In1
@onready var output = $Output

func _ready():
	super._ready()
	output.eval_func = func(call_idx: int):
		return not in1.get_value(call_idx)
	inputs = [ in1 ]
	outputs = [ output ]
