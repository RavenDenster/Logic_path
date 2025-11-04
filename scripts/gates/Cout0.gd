extends Node2D

var input_value: int = 0
var output_value: int = 0

func _ready():
	add_to_group("Cout0")
	print("Cout0 ready! Has set_input: ", has_method("set_input"))

func set_input(port: int, val: int):
	print("Cout0 set_input port ", port, " to: ", val)
	if port == 1: 
		input_value = val
	output_value = input_value
	print("Cout0 updated - Input:", input_value, " Output:", output_value)

func get_output(port_name: String) -> int:
	var result = output_value
	print("Cout0 output from ", port_name, ": ", result)
	return result

func reset_inputs():
	print("Cout0 reset_inputs")
	input_value = 0
	output_value = 0
