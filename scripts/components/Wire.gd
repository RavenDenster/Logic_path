extends Line2D

@export var input_node: Node = null
@export var output_node: Node = null

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
	
	if abs(start_point.y - end_point.y) < 15:
		wire_points.append(end_point)
	else:
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
	outline_line = Line2D.new()
	outline_line.default_color = Color("000000ff")
	outline_line.width = 14
	add_child(outline_line)
	
	default_color = Color("d4792eff")
	width = 8

func reset_position_changed_connection():
	output_node.position_changed.disconnect(_output_pos_changed)

func finalize(end_pos: Vector2, output: Node) -> bool:
	if input_node.connected_to.has(output):
		return false
	
	if output.connected_to:
		return false
	
	end_point = end_pos
	output_node = output
	output.position_changed.connect(_output_pos_changed)
	update_line()	
	
	input_node.connected_to.append(output_node)
	output_node.connected_to = input_node
	output_node.wire_ref = self
	return true

#func connect_ports(start, end):
#	if not start or not end or not is_instance_valid(start) or not is_instance_valid(end):
#		return
#		
#	start_port = start
#	end_port = end
#	
#	outline_line = Line2D.new()
#	outline_line.default_color = Color("c8641fff")
#	outline_line.width = 12
#	outline_line.z_index = -1
#	add_child(outline_line)
#	
#	default_color = Color("#e39e45")
#	width = 8
#	z_index = 0
#	
#	update_wire()
#	
#	var arrow = Sprite2D.new()
#	arrow.texture = load("res://assets/arrowGreen.png")
#	arrow.name = "Arrow"
#	add_child(arrow)
#	arrow.scale = Vector2(0.5, 0.5)
#	arrow.z_index = 1
#
#func _process(delta):
#	if not start_port or not is_instance_valid(start_port) or not end_port or not is_instance_valid(end_port):
#		queue_free()
#		return
#	
#	update_wire()
#	update_arrow(delta)
#
#	
#	
#	# Обновляем обе линии
#	clear_points()
#	if outline_line:
#		outline_line.clear_points()
#	
#	for point in wire_points:
#		add_point(point)
#		if outline_line:
#			outline_line.add_point(point)
#
#func update_arrow(delta):
#	var arrow = get_node_or_null("Arrow")
#	if not arrow:
#		return
#	
#	var line_points = get_points()
#	if line_points.size() < 2:
#		return
#	
#	var total_length = 0.0
#	for i in range(line_points.size() - 1):
#		total_length += line_points[i].distance_to(line_points[i + 1])
#	
#	if total_length == 0:
#		return
#	
#	arrow_progress += delta * arrow_speed
#	if arrow_progress >= 1.0:
#		arrow_progress = 0.0
#	
#	var target_length = total_length * arrow_progress
#	var current_length = 0.0
#	var arrow_pos = line_points[0]
#	var arrow_rotation = 0.0
#	
#	for i in range(line_points.size() - 1):
#		var segment_length = line_points[i].distance_to(line_points[i + 1])
#		if current_length + segment_length >= target_length:
#			var segment_progress = (target_length - current_length) / segment_length
#			arrow_pos = line_points[i].lerp(line_points[i + 1], segment_progress)
#			var direction = (line_points[i + 1] - line_points[i]).normalized()
#			arrow_rotation = atan2(direction.y, direction.x)
#			break
#		else:
#			current_length += segment_length
#	
#	arrow.position = arrow_pos
#	arrow.rotation = arrow_rotation
#
