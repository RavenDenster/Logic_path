extends Node2D

var values_A = []
var values_B = []
var current_test_index = 0

func get_output(port_name: String) -> int:
	var result = 0
	if port_name == "OutputA": 
		result = values_A[current_test_index]
	elif port_name == "OutputB": 
		result = values_B[current_test_index]
	print("InputBlock output from ", port_name, ": ", result)
	return result

func reset_inputs(): 
	pass
