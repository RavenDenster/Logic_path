extends Node2D

var clk_prev: int = 0
var current_state: int = 0
var t_input: int = 1
var is_falling_edge: bool = false
var gate_name: String = ""
var edge_type_set: bool = false

func _ready():
	gate_name = name
	print("TFlipFlopGate initialized: ", gate_name)
	add_to_group("TFlipFlop")
	reset_inputs()

func set_input(port: int, value: int):
	print("TFlipFlopGate ", gate_name, " set_input port ", port, " to: ", value, 
		  " (current_state=", current_state, ", prev_clk=", clk_prev, 
		  ", is_falling_edge=", is_falling_edge, ", t_input=", t_input, ", edge_type_set=", edge_type_set, ")")
	
	match port:
		1:  # CLK input
			if is_falling_edge:
				# Falling edge detection (1->0 transition)
				if clk_prev == 1 and value == 0:
					if t_input == 1:  # Only toggle if T=1
						current_state = 1 - current_state  # Toggle state
						print(">>> ", gate_name, " TOGGLED on FALLING edge! New state: ", current_state)
					else:
						print(">>> ", gate_name, " would toggle on FALLING edge but T=0")
				else:
					if clk_prev != value:
						print(">>> ", gate_name, " no falling edge: prev=", clk_prev, ", current=", value)
			else:
				# Rising edge detection (0->1 transition) - по умолчанию
				if clk_prev == 0 and value == 1:
					if t_input == 1:  # Only toggle if T=1
						current_state = 1 - current_state  # Toggle state
						print(">>> ", gate_name, " TOGGLED on RISING edge! New state: ", current_state)
					else:
						print(">>> ", gate_name, " would toggle on RISING edge but T=0")
				else:
					if clk_prev != value:
						print(">>> ", gate_name, " no rising edge: prev=", clk_prev, ", current=", value)
			clk_prev = value
		2:  # T input
			t_input = value
			print(">>> ", gate_name, " T input set to: ", value)

func get_output(_port_name: String) -> int:
	print("TFlipFlopGate ", gate_name, " get_output: ", current_state)
	return current_state

func reset_inputs():
	clk_prev = 0
	current_state = 0
	t_input = 1
	print("TFlipFlopGate ", gate_name, " reset to state: 0")

func set_edge_type(falling: bool):
	is_falling_edge = falling
	edge_type_set = true
	print(">>> TFlipFlopGate ", gate_name, " set to ", "FALLING" if falling else "RISING", " edge mode")
