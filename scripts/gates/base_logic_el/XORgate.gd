# XORGate.gd
extends Node2D

var input1: int = 0
var input2: int = 0
var output_value: int = 0

func _ready():
	add_to_group("XORGate")
	print("XORGate ready! Has set_input: ", has_method("set_input"))

func set_input(port: int, val: int):
	print("XORGate set_input port ", port, " to: ", val)
	if port == 1:
		input1 = val
	elif port == 2:
		input2 = val
	update_output()

func update_output():
	print("XORGate update_output called")
	print("  Input1: ", input1)
	print("  Input2: ", input2)
	output_value = (input1 != input2)
	print("  Output: ", output_value)

func get_output(port_name: String) -> int:
	print("XORGate output: ", output_value)
	return output_value

func reset_inputs():
	print("XORGate reset_inputs")
	input1 = 0
	input2 = 0
	output_value = 0
