# ConstantOne.gd
extends Node2D

var output_value: int = 1

func _ready():
	add_to_group("ConstantOne")
	print("ConstantOne ready! Always outputs 1")
	output_value = 1

func get_output(port_name: String) -> int:
	print("ConstantOne get_output: ", output_value)
	return output_value

func reset_inputs():
	print("ConstantOne reset_inputs - ничего не делает")
	# Всегда выдает 1, поэтому не нужно сбрасывать
