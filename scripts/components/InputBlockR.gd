extends Node2D

var values = []
var current_test_index = 0

func get_output(port_name: String) -> int:
	var result = values[current_test_index]
	print("InputBlock output: ", result)
	return result

func reset_inputs(): 
	pass

func get_input_count() -> int:
	return 1
