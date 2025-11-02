
extends Node2D

var current_test_index: int = 0
var sel_values: Array[int] = [0,1,0,0,1,0,0,1]

func _ready():
	add_to_group("Sel1")
	print("Sel1 gate ready - added to group Sel1")

func get_output(_port_name: String) -> int:
	if current_test_index < sel_values.size():
		return sel_values[current_test_index]
	return 0

func set_test_index(index: int):
	current_test_index = index
	print("Sel1 test index set to: ", index, " value: ", sel_values[index])
