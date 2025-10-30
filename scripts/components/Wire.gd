extends Line2D

var start_port = null
var end_port = null
var arrow_progress = 0.0
var arrow_speed = 0.4

func connect_ports(start, end):
	start_port = start
	end_port = end
	default_color = Color("#e39e45")
	width = 8
	update_wire()
	
	var arrow = Sprite2D.new()
	arrow.texture = preload("res://assets/arrowGreen.png")
	arrow.name = "Arrow"
	add_child(arrow)
	arrow.scale = Vector2(0.5, 0.5)
	arrow.z_index = 1

func _process(delta):
	if not start_port or not end_port:
		return
	
	update_wire()
	update_arrow(delta)

func update_wire():
	if not start_port or not end_port:
		return
	
	var start_pos = get_collision_shape_global_position(start_port)
	var end_pos = get_collision_shape_global_position(end_port)
	
	var wire_points = []
	wire_points.append(start_pos)
	
	var distance = abs(start_pos.x - end_pos.x)
	var bend_offset = min(80, distance * 0.3)
	
	if abs(start_pos.y - end_pos.y) < 15:
		wire_points.append(end_pos)
	else:
		if end_pos.x >= start_pos.x:
			var bend_point1 = Vector2(start_pos.x + bend_offset, start_pos.y)
			var bend_point2 = Vector2((start_pos.x + bend_offset + end_pos.x) / 2, end_pos.y)
			wire_points.append(bend_point1)
			wire_points.append(bend_point2)
		else:
			var bend_point1 = Vector2(start_pos.x - bend_offset, start_pos.y)
			var bend_point2 = Vector2((start_pos.x - bend_offset + end_pos.x) / 2, end_pos.y)
			wire_points.append(bend_point1)
			wire_points.append(bend_point2)
		
		wire_points.append(end_pos)
	
	clear_points()
	for point in wire_points:
		add_point(point)

func update_arrow(delta):
	var arrow = get_node_or_null("Arrow")
	if not arrow:
		return
	
	var line_points = get_points()
	if line_points.size() < 2:
		return
	
	var total_length = 0.0
	for i in range(line_points.size() - 1):
		total_length += line_points[i].distance_to(line_points[i + 1])
	
	if total_length == 0:
		return
	
	arrow_progress += delta * arrow_speed
	if arrow_progress >= 1.0:
		arrow_progress = 0.0
	
	var target_length = total_length * arrow_progress
	var current_length = 0.0
	var arrow_pos = line_points[0]
	var arrow_rotation = 0.0
	
	for i in range(line_points.size() - 1):
		var segment_length = line_points[i].distance_to(line_points[i + 1])
		if current_length + segment_length >= target_length:
			var segment_progress = (target_length - current_length) / segment_length
			arrow_pos = line_points[i].lerp(line_points[i + 1], segment_progress)
			var direction = (line_points[i + 1] - line_points[i]).normalized()
			arrow_rotation = atan2(direction.y, direction.x)
			break
		else:
			current_length += segment_length
	
	arrow.position = arrow_pos
	arrow.rotation = arrow_rotation

func get_collision_shape_global_position(port):
	var collision_shape = port.get_node("CollisionShape2D")
	if collision_shape:
		return collision_shape.global_position
	return port.global_position
