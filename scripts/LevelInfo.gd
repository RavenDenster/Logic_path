extends Node
class_name LevelInfo

enum GateType { AND, OR, NAND, NOR, NOT }

static var data: Dictionary
static var path: String

static var COL_OFF = Color(0.73, 0.377, 0.383, 1.0)
static var COL_ON  = Color(0.533, 0.705, 0.439, 1.0)
static var STYLE_OFF       = _create_circle_stylebox(COL_OFF)
static var STYLE_ON        = _create_circle_stylebox(COL_ON)
static var STYLE_OFF_HOVER = _create_circle_stylebox(COL_OFF.darkened(0.25))
static var STYLE_ON_HOVER  = _create_circle_stylebox(COL_ON.darkened(0.25))
	

static func load_level_data(level_path: String):
	var file = FileAccess.open(level_path, FileAccess.READ)
	var json_data = JSON.parse_string(file.get_as_text())
	file.close()
	data = json_data
	path = level_path

static func _create_row_line_edit(text: String) -> Control:
	var edit = LineEdit.new()
	edit.text = text
	edit.expand_to_text_length = true
	edit.custom_minimum_size.x = 50
	edit.flat = true
	return edit

static func _create_row_label(text: String) -> Control:
	var label = Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.custom_minimum_size.x = 50
	return label

static func _create_const_dot(val: int) -> Control:
	var dot = Panel.new()
	dot.custom_minimum_size = Vector2(24, 24)
	if val == 1: dot.add_theme_stylebox_override("panel", STYLE_ON)
	else: dot.add_theme_stylebox_override("panel", STYLE_OFF)
	return dot

static func _create_dot() -> Control:
	var button = Button.new()
	button.text = ""
	button.custom_minimum_size = Vector2(24, 24)
	button.toggle_mode = true
	button.add_theme_stylebox_override("normal", STYLE_OFF)
	button.add_theme_stylebox_override("hover", STYLE_OFF_HOVER)
	button.add_theme_stylebox_override("pressed", STYLE_ON)
	button.add_theme_stylebox_override("hover_pressed", STYLE_ON_HOVER)
	return button

static func create_truth_table(
			n_inputs: int,
			n_outputs: int,
			editable_outputs: bool,
			editable_labels: bool,
			result_rows: bool,
			input_labels = null,
			output_labels = null,
	) -> GridContainer:
	var grid = GridContainer.new()
	var n_columns = pow(2, n_inputs)
	grid.columns = n_columns + 2
	
	if input_labels == null:
		input_labels = []
		for i in range(n_inputs):
			input_labels.append("Вход %d" % [i + 1])
	
	if output_labels == null:
		output_labels = []
		for i in range(n_outputs):
			output_labels.append("Выход %d" % [i + 1])
	
	print("input_labels")
	print(input_labels)
	print("output_labels")
	print(output_labels)
	
	var input_names = []
	for i in range(n_inputs):
		var label = _create_row_line_edit(input_labels[i]) if editable_labels \
					else _create_row_label(input_labels[i])
		input_names.append(label)
		grid.add_child(label)
		grid.add_child(VSeparator.new())
		
		for col in range(n_columns):
			var bit = (col >> (n_inputs - 1 - i)) & 1
			var dot = _create_const_dot(bit)
			grid.add_child(dot)
	
	for i in range(n_columns + 2):
		grid.add_child(HSeparator.new())
	
	var output_buttons = []
	var output_names = []
	var result_buttons = []
	for i in range(n_outputs):
		var label
		if result_rows:
			label = _create_row_line_edit("Ожидаемый " + output_labels[i]) if editable_labels \
						else _create_row_label("Ожидаемый " + output_labels[i])
		else:
			label = _create_row_line_edit(output_labels[i]) if editable_labels \
						else _create_row_label(output_labels[i])

		if editable_labels: output_names.append(label)
		grid.add_child(label)
		grid.add_child(VSeparator.new())
		
		var row_buttons = []
		for col in range(n_columns):
			var dot = _create_dot() if editable_outputs \
						else _create_const_dot(0)
			row_buttons.append(dot)
			grid.add_child(dot)
		output_buttons.append(row_buttons)
		
		if not result_rows: continue
		
		var res_label = _create_row_label("Получаемый " + output_labels[i])
		grid.add_child(res_label)
		grid.add_child(VSeparator.new())
		
		var row_res_buttons = []
		for col in range(n_columns):
			var dot = _create_const_dot(0)
			row_res_buttons.append(dot)
			grid.add_child(dot)
		result_buttons.append(row_res_buttons)
	
	grid.set_meta("output_buttons", output_buttons)
	if editable_labels:
		grid.set_meta("input_names", input_names)
		grid.set_meta("output_names", output_names)
	if result_rows:
		grid.set_meta("result_buttons", result_buttons)
	grid.set_meta("n_inputs", n_inputs)
	grid.set_meta("n_outputs", n_outputs)
	return grid

static func _create_circle_stylebox(color: Color) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color.BLACK
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	return style

static func get_truth_table_values(truth_table):
	var output_buttons = truth_table.get_meta("output_buttons")
	var res = []
	for row in output_buttons:
		var res_row = []
		for btn in row:
			res_row.append(btn.button_pressed)
		res.append(res_row)
	return res

static func set_truth_table_values(truth_table, expected: bool, values: Array):
	var output_buttons = truth_table.get_meta("result_buttons" if expected else "output_buttons") 
	for i in range(values.size()):
		var row = values[i]
		for j in range(row.size()):
			var dot = output_buttons[i][j]
			var val = values[i][j]
			if dot is Button:
				dot.button_pressed = val
			elif dot is Panel:
				dot.add_theme_stylebox_override("panel", STYLE_ON if int(val) == 1 else STYLE_OFF)
