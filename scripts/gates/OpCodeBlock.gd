extends Node2D
class_name OpCodeBlock

var values_op0 = []
var values_op1 = []
var current_test_index = 0

func _ready():
	add_to_group("OpCodeBlocks")  # Добавляем в группу
	print("OpCodeBlock ready! Values Op0: ", values_op0, " Op1: ", values_op1)

func get_output(port_name: String) -> int:
	var result = 0
	if port_name == "Op0":
		if values_op0.size() > current_test_index:
			result = values_op0[current_test_index]
		else:
			result = 0  # Значение по умолчанию
	elif port_name == "Op1":
		if values_op1.size() > current_test_index:
			result = values_op1[current_test_index]
		else:
			result = 0  # Значение по умолчанию
	
	print("OpCodeBlock output from ", port_name, " at index ", current_test_index, ": ", result)
	return result

func reset_inputs(): 
	pass

func get_input_count() -> int:
	return 0
