extends Node2D

var received_value: int = 0

var expected = []
var main_sprite: Sprite2D

func _ready():
	print("OutputBlock ready! Has set_input: ", has_method("set_input"))
	main_sprite = $Sprite2D

func set_input(_port: int, val: int):
	print("OutputBlock set_input: ", val)
	received_value = val

func reset_inputs():
	print("OutputBlock reset_inputs")
	received_value = 0

func set_correct_style():
	if main_sprite:
		main_sprite.texture = preload("res://assets/outputGreen.png")

func set_default_style():
	if main_sprite:
		main_sprite.texture = preload("res://assets/output.png")
