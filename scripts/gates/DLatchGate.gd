# DLatchGate.gd
extends Node2D

var input_d: int = 0
var input_enable: int = 0
var output_q: int = 0
var stored_value: int = 0

func _ready():
	add_to_group("DLatchGate")
	print("DLatchGate ready! Has set_input: ", has_method("set_input"))

func set_input(port: int, val: int):
	print("DLatchGate set_input port ", port, " to: ", val)
	if port == 1: 
		input_d = val
	elif port == 2: 
		input_enable = val
	update_output()

func update_output():
	if input_enable == 1:
		# Когда Enable=1, выход следует за входом D
		output_q = input_d
		stored_value = input_d
		print("DLatchGate: Enable=1, Q follows D: ", output_q)
	else:
		# Когда Enable=0, выход сохраняет последнее значение
		output_q = stored_value
		print("DLatchGate: Enable=0, Q holds previous value: ", output_q)

func get_output(port_name: String) -> int:
	var result = 0
	if port_name == "Output" or port_name == "Q":
		result = output_q
	print("DLatchGate output from ", port_name, ": ", result)
	return result

func reset_inputs():
	print("DLatchGate reset_inputs")
	input_d = 0
	input_enable = 0
	# НЕ сбрасываем stored_value и output_q здесь, чтобы сохранить состояние
	# output_q = 0
	# stored_value = 0

func reset_state():
	print("DLatchGate reset_state - полностью сбрасываем состояние")
	input_d = 0
	input_enable = 0
	output_q = 0
	stored_value = 0
