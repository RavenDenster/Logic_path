# InputBlockSingle.gd
extends Node2D

var values = []
var current_test_index = 0

func _ready():
	add_to_group("InputBlockSingle")
	print("InputBlockSingle ready! Has get_output: ", has_method("get_output"))

func get_output(port_name: String) -> int:
	var result = values[current_test_index]
	print("InputBlockSingle output from ", port_name, ": ", result)
	return result

func reset_inputs(): 
	pass
