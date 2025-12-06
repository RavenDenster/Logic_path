# DTrigger.gd
extends Node2D

var input_d: int = 0
var input_clk: int = 0
var output_q: int = 0
var output_q_not: int = 1
var prev_clk: int = 0
var last_clk_value: int = 0

func _ready():
	add_to_group("Sequential")
	add_to_group("DTrigger")
	print("DTrigger ready! Has set_input: ", has_method("set_input"))

func set_input(port: int, val: int):
	print("DTrigger set_input port ", port, " to: ", val)
	if port == 1: 
		input_d = val
		print("DTrigger: input_d = ", input_d)
	elif port == 2: 
		last_clk_value = input_clk
		input_clk = val
		print("DTrigger: CLK changed from ", last_clk_value, " to ", input_clk)
		# Проверяем фронт (0->1)
		if input_clk == 1 and last_clk_value == 0:
			print("DTrigger: Rising edge detected! Updating Q from ", output_q, " to ", input_d)
			output_q = input_d
			output_q_not = 1 - output_q
			print("DTrigger: New Q = ", output_q, ", Q_not = ", output_q_not)

func get_output(port_name: String) -> int:
	var result = 0
	if port_name == "OutputQ":
		result = output_q
	elif port_name == "OutputQNot":
		result = output_q_not
	elif port_name == "Output":
		result = output_q
	print("DTrigger output from ", port_name, ": ", result)
	return result

func reset_inputs():
	print("DTrigger reset_inputs")
	# Не сбрасываем входы полностью, только логические значения
	# input_d = 0
	# input_clk = 0
	# last_clk_value = 0

func reset_state():
	print("DTrigger reset_state")
	input_d = 0
	input_clk = 0
	last_clk_value = 0
	output_q = 0  # Начальное состояние Q = 0
	output_q_not = 1
	print("DTrigger: Reset complete - Q = 0, Q_not = 1")

func update_outputs():
	print("DTrigger update_outputs - текущее состояние: Q=", output_q, ", Q_not=", output_q_not)
	# В этой реализации обновление происходит в set_input при обнаружении фронта
	# Здесь можно обновить спрайты или другие визуальные элементы
