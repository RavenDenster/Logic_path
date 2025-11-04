extends Node2D

var input_a: int = 0
var input_b: int = 0
var output_sum: int = 0
var output_carry: int = 0

func _ready():
	add_to_group("HalfAdder")
	print("HalfAdder ready! Has set_input: ", has_method("set_input"))

func set_input(port: int, val: int):
	print("HalfAdder set_input port ", port, " to: ", val)
	if port == 1: 
		input_a = val
	elif port == 2: 
		input_b = val
	update_outputs()

func update_outputs():
	# Sum = A XOR B (побитовый XOR)
	output_sum = input_a ^ input_b
	# Carry = A AND B (побитовый AND)
	output_carry = input_a & input_b
	
	print("HalfAdder updated - A:", input_a, " B:", input_b, " Sum:", output_sum, " Carry:", output_carry)

func get_output(port_name: String) -> int:
	var result = 0
	if port_name == "OutputSum":
		result = output_sum
	elif port_name == "OutputCarry":
		result = output_carry
	print("HalfAdder output from ", port_name, ": ", result)
	return result

func reset_inputs():
	print("HalfAdder reset_inputs")
	input_a = 0
	input_b = 0
	output_sum = 0
	output_carry = 0
