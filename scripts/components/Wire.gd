extends Line2D
class_name Wire

@export var input_node: Output = null
@export var output_node: InputNode = null
@export var tween = null
@export var tween2 = null

var start_point: Vector2
var end_point: Vector2

var arrow_progress = 0.0
var arrow_speed = 0.4
var outline_line: Line2D

func initialize(start_pos: Vector2, input: Node):
	start_point = start_pos
	input.position_changed.connect(_input_pos_changed)
	end_point = start_point
	input_node = input
	update_line()

func update_line():
	var wire_points = []
	wire_points.append(start_point)
	
	var distance = abs(start_point.x - end_point.x)
	var bend_offset = min(80, distance * 0.3)
	
	if end_point.x >= start_point.x:
		var bend_point1 = Vector2(start_point.x + bend_offset, start_point.y)
		var bend_point2 = Vector2((start_point.x + bend_offset + end_point.x) / 2, end_point.y)
		wire_points.append(bend_point1)
		wire_points.append(bend_point2)
	else:
		var bend_point1 = Vector2(start_point.x - bend_offset, start_point.y)
		var bend_point2 = Vector2((start_point.x - bend_offset + end_point.x) / 2, end_point.y)
		wire_points.append(bend_point1)
		wire_points.append(bend_point2)
		
	wire_points.append(end_point)
		
	clear_points()
	for pt in wire_points:
		add_point(pt)

func _change_end_point(val):
	end_point = val
	update_line()

func _change_start_point(val):
	start_point = val
	update_line()

func untie():
	if input_node:
		input_node.connected_to.erase(output_node)
	if output_node:
		output_node.connected_to = null
		output_node.wire_ref = null
		
func delete_to_start_animation():
	reset_position_changed_connection()
	tween = create_tween()
	tween2 = create_tween()
	tween.tween_method(_change_end_point, end_point, start_point, 0.2)
	tween2.tween_property(self, "modulate:a", 0, 0.2)
	await tween.finished
	await tween2.finished

func delete_to_end_animation():
	reset_position_changed_connection()
	tween = create_tween()
	tween2 = create_tween()
	tween.tween_method(_change_start_point, start_point, end_point, 0.2)
	tween2.tween_property(self, "modulate:a", 0, 0.2)
	await tween.finished
	await tween2.finished

func stop_animation():
	tween.kill()
	tween2.kill()
	start_point = input_node.global_position
	end_point = output_node.global_position
	modulate.a = 1
	position_changed_connect()
	update_line()

func update_end_point(mouse_pos: Vector2):
	end_point = mouse_pos
	update_line()

func _input_pos_changed() -> void:
	start_point = input_node.global_position
	update_line()

func _output_pos_changed() -> void:
	end_point = output_node.global_position
	update_line()

func _ready():
	default_color = Color("232323ff")
	width = 4

func reset_position_changed_connection():
	if output_node and output_node.position_changed.is_connected(_output_pos_changed):
		output_node.position_changed.disconnect(_output_pos_changed)
	if input_node and input_node.position_changed.is_connected(_input_pos_changed):
		input_node.position_changed.disconnect(_input_pos_changed)

func position_changed_connect():
	if output_node and not output_node.position_changed.is_connected(_output_pos_changed):
		output_node.position_changed.connect(_output_pos_changed)
	if input_node and not input_node.position_changed.is_connected(_input_pos_changed):
		input_node.position_changed.connect(_input_pos_changed)

func finalize(end_pos: Vector2, output: Node) -> bool:
	if input_node.connected_to.has(output):
		reset_position_changed_connection()
		return false
	
	if output.connected_to:
		reset_position_changed_connection()
		return false
	
	end_point = end_pos
	output_node = output
	position_changed_connect()
	input_node.connected_to.append(output_node)
	output_node.connected_to = input_node
	output_node.wire_ref = self
	
	update_line()	
	return true
