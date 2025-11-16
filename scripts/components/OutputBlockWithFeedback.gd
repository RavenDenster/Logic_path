extends Node2D
class_name OutputBlockWithFeedback

var received_value = 0
var output_value = 0
var expected = []

@onready var input_port = $InputPort
@onready var output_port = $Output

func _ready():
	print("OutputBlockWithFeedback ready! Has set_input: ", has_method("set_input"))

func set_input(port_name, value):
	print("OutputBlockWithFeedback set_input called with value: ", value)
	received_value = value
	# Немедленно обновляем выходное значение для обратной связи
	output_value = value

func get_output(port_name):
	return output_value

func reset_inputs():
	# Не сбрасываем output_value - это важно для памяти защелки!
	received_value = 0
func set_default_style():
	$Sprite2D.texture = preload("res://assets/output.png")

func set_correct_style():
	$Sprite2D.texture = preload("res://assets/outputGreen.png")
