extends Node2D

var input1: int = 0
var input2: int = 0

func _ready():
	print("XORGate ready! Has set_input: ", has_method("set_input"))

func set_input(port: int, val: int):
	print("XORGate set_input port ", port, " to: ", val)
	if port == 1: 
		input1 = val
	elif port == 2: 
		input2 = val

func get_output(_port_name: String) -> int:
	var result = int(input1 != input2)
	print("XORGate output: ", result)
	return result

func reset_inputs():
	print("XORGate reset_inputs")
	input1 = 0
	input2 = 0
