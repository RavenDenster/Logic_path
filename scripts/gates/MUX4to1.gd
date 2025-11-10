extends Node2D

var inputs: Array[int] = [0, 0, 0, 0] 
var sel0: int = 0
var sel1: int = 0
var output: int = 0

func _ready():
	print("MUX4to1 ready! Has set_input: ", has_method("set_input"))

func set_input(port: int, val: int):
	print("Port: ", port, " Value: ", val)
	match port:
		1: 
			inputs[0] = val
		2: 
			inputs[1] = val  
		3: 
			inputs[2] = val
		4: 
			inputs[3] = val
		5: 
			sel0 = val
		6: 
			sel1 = val
	update_output()

func update_output():
	var select = sel1 * 2 + sel0
	print("Sel1: ", sel1, " Sel0: ", sel0, " → Select: ", select)

	match select:
		0: print("→ SELECTING Input0 (AND): ", inputs[0])
		1: print("→ SELECTING Input1 (OR): ", inputs[1])  
		2: print("→ SELECTING Input2 (XOR): ", inputs[2])
		3: print("→ SELECTING Input3 (NOT USED): ", inputs[3])
		_: print("→ INVALID SELECT: ", select)
	
	output = inputs[select] if select < inputs.size() else 0

func get_output(_port_name: String) -> int:
	print("MUX4to1 get_output: ", output)
	return output

func reset_inputs():
	print("MUX4to1 RESET")
	inputs = [0, 0, 0, 0]
	sel0 = 0
	sel1 = 0
	output = 0
