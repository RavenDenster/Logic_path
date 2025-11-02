extends Node2D

var current_test_index: int = 0
# Sel0 значения для 8 тестов: [0,1,0,0,1,0,0,1]
var sel_values: Array[int] = [0,0,1,0,0,1,0,0] 

func _ready():
	add_to_group("Sel0")

func get_output(_port_name: String) -> int:
	if current_test_index < sel_values.size():
		return sel_values[current_test_index]
	return 0

func set_test_index(index: int):
	current_test_index = index
