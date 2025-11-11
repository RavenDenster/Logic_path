extends Node2D

var input_a: int = 0
var input_b: int = 0

func _ready():
	print("OneBitComparatorGate ready!")

func set_input(port: int, val: int):
	print("OneBitComparatorGate set_input port ", port, " to: ", val)
	if port == 1: 
		input_a = val
	elif port == 2: 
		input_b = val

func get_output(port_name: String) -> int:
	var result = 0
	match port_name:
		"OutputAgtb":  # A > B
			result = int(input_a > input_b)
		"OutputAltb":  # A < B
			result = int(input_a < input_b)
		"OutputAeqb":  # A == B
			result = int(input_a == input_b)
	print("OneBitComparatorGate output ", port_name, ": ", result, " (A=", input_a, ", B=", input_b, ")")
	return result

func reset_inputs():
	print("OneBitComparatorGate reset_inputs")
	input_a = 0
	input_b = 0
