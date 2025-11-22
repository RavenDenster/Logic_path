extends Node2D

var input: int = 0

func _ready():
	print("NOTGate ready! Has set_input: ", has_method("set_input"))

func set_input(_port: int, val: int):  # Игнорируем port
	print("NOTGate set_input called with value: ", val)
	input = val

func get_output(_port_name: String) -> int:
	var result = int(not input)
	return result

func reset_inputs():
	print("NOTGate reset_inputs")
	input = 0
