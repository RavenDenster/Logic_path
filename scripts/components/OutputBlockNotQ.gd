extends Node2D

var received_value: int = 0
var expected = []

func set_input(port: int, val: int):
	print("OutputBlock set_input: ", val)
	received_value = val

func reset_inputs():
	received_value = 0

func set_default_style():
	if has_node("Sprite2D"):
		var texture = load("res://assets/output.png")
		if texture:
			$Sprite2D.texture = texture
		else:
			print("ERROR: Cannot load output.png")

func set_correct_style():
	if has_node("Sprite2D"):
		var texture = load("res://assets/output_correct.png")
		if texture:
			$Sprite2D.texture = texture
		else:
			print("ERROR: Cannot load output_correct.png")
