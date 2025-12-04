# RSFlipFlop.gd
extends Node2D
class_name RSFlipFlop

var input_r: int = 0
var input_s: int = 0
var output_q: int = 0
var output_not_q: int = 1

func _ready():
	print("RSFlipFlop ready!")

func set_input(port: int, val: int):
	print("RSFlipFlop set_input port ", port, " to: ", val)
	if port == 1:
		input_s = val
	elif port == 2:
		input_r = val
	# Removed call to calculate_outputs here

func get_input(port: int) -> int:
	if port == 1:
		return input_s
	elif port == 2:
		return input_r
	return 0

func update_state():
	calculate_outputs()

func calculate_outputs():
	# Логика RS-триггера на NOR
	if input_s == 1 and input_r == 0: # Set
		output_q = 1
		output_not_q = 0
	elif input_s == 0 and input_r == 1: # Reset
		output_q = 0
		output_not_q = 1
	elif input_s == 1 and input_r == 1: # Forbidden
		output_q = 0
		output_not_q = 0
	# При S=0, R=0 состояние сохраняется (не меняем outputs)
	print("RSFlipFlop calculated: Q=", output_q, " !Q=", output_not_q)

func get_output(port_name: String) -> int:
	if port_name == "OutputQ":
		return output_q
	elif port_name == "OutputNotQ":
		return output_not_q
	return 0

func reset_inputs():
	print("RSFlipFlop reset_inputs")
	input_r = 0
	input_s = 0
	output_q = 0
	output_not_q = 1
