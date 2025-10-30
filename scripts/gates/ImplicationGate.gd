extends Node2D

var input1: int = 0  # A
var input2: int = 0  # B

func _ready():
	print("ImplicationGate ready! Has set_input: ", has_method("set_input"))

func set_input(port: int, val: int):
	print("ImplicationGate set_input port ", port, " to: ", val)
	if port == 1: 
		input1 = val
	elif port == 2: 
		input2 = val

func get_output(_port_name: String) -> int:
	# Импликация A → B эквивалентна NOT A OR B
	var result = int(not input1 or input2)
	print("ImplicationGate output: ", result)
	return result

func reset_inputs():
	print("ImplicationGate reset_inputs")
	input1 = 0
	input2 = 0
