extends Node2D

var clk_value: int = 0

func _ready():
	print("CLKGate ready!")

func set_input(port: int, val: int):
	print("CLKGate set_input port ", port, " to: ", val)
	if port == 1: # Input from InputBlockCLK
		clk_value = val

func get_output(_port_name: String) -> int:
	print("CLKGate output: ", clk_value)
	return clk_value

func reset_inputs():
	print("CLKGate reset_inputs")
	clk_value = 0
