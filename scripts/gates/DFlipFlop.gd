extends Node2D

var d_input: int = 0
var clk_input: int = 0
var q_output: int = 0

func _ready():
	print("DFlipFlop ready! Has set_input: ", has_method("set_input"))

func set_input(port: int, val: int):
	print("DFlipFlop set_input port ", port, " to: ", val)
	if port == 1: # D input
		d_input = val
	elif port == 2: # CLK input
		clk_input = val

func get_output(_port_name: String) -> int:
	print("DFlipFlop output Q: ", q_output)
	return q_output

func reset_inputs():
	print("DFlipFlop reset_inputs")
	d_input = 0
	clk_input = 0
	q_output = 0
