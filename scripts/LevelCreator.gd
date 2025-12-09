extends Node2D

@onready var name_input = find_child("NameInput")
@onready var filename_input = find_child("FilenameInput")
@onready var help_input = find_child("HelpInput")
@onready var inputs_spin = find_child("InputsSpinBox")
@onready var outputs_spin = find_child("OutputsSpinBox")
@onready var save_button = find_child("SaveButton")
@onready var menu_panel = find_child("Menu")
@onready var tab_container = find_child("Container")
@onready var allowed_gates_btn = find_child("AllowedGatesButton")
var truth_table
@onready var gates_input = find_child("GatesInput")
@onready var group_input = find_child("GroupInput")

func _create_inputs_dots(n_inputs: int, n_outputs: int) -> VBoxContainer:
	var container = VBoxContainer.new()
	var n_columns = pow(2, n_inputs)
	
	var red = Color(0.73, 0.377, 0.383, 1.0)
	var green = Color(0.533, 0.705, 0.439, 1.0)
	
	var red_circle = _create_circle_stylebox(red)
	var green_circle = _create_circle_stylebox(green)
	var red_hover = _create_circle_stylebox(red.darkened(0.25))
	var green_hover = _create_circle_stylebox(green.darkened(0.25))
	
	for input_row in range(n_inputs):
		var row = HBoxContainer.new()
		var label = Label.new()
		label.text = "In%d" % input_row
		label.custom_minimum_size.x = 50
		row.add_child(label)
		
		for col in range(n_columns):
			var bit = (col >> (n_inputs - 1 - input_row)) & 1
			var dot = Panel.new()
			
			dot.custom_minimum_size = Vector2(24, 24)
			if bit == 1: dot.add_theme_stylebox_override("panel", green_circle)
			else: dot.add_theme_stylebox_override("panel", red_circle)
			row.add_child(dot)
		
		container.add_child(row)
	
	var sep = HSeparator.new()
	container.add_child(sep)
	
	var output_buttons = []
	for output_row in range(n_outputs):
		var row = HBoxContainer.new()
		var label = Label.new()
		label.text = "Out%d" % output_row
		label.custom_minimum_size.x = 50
		row.add_child(label)
		
		var row_buttons = []
		for col in range(n_columns):
			var button = Button.new()
			button.text = ""
			button.custom_minimum_size = Vector2(24, 24)
			button.toggle_mode = true
			button.add_theme_stylebox_override("normal", red_circle)
			button.add_theme_stylebox_override("hover", red_hover)
			button.add_theme_stylebox_override("pressed", green_circle)
			button.add_theme_stylebox_override("hover_pressed", green_hover)
			row.add_child(button)
			row_buttons.append(button)
		
		container.add_child(row)
		output_buttons.append(row_buttons)
	
	container.set_meta("output_buttons", output_buttons)
	container.set_meta("n_inputs", n_inputs)
	container.set_meta("n_outputs", n_outputs)
	return container

func get_truth_table_values():
	var output_buttons = truth_table.get_meta("output_buttons")
	var res = []
	for row in output_buttons:
		var res_row = []
		for btn in row:
			res_row.append(btn.button_pressed)
		res.append(res_row)
	return res

func set_truth_table_values(values: Array):
	var output_buttons = truth_table.get_meta("output_buttons")
	for i in range(values.size()):
		var row = values[i]
		for j in range(row.size()):
			output_buttons[i][j].button_pressed = values[i][j]

func _create_circle_stylebox(color: Color) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color.BLACK
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	return style

func _on_save_button_pressed() -> void:
	var selected_items = gates_input.get_selected_items()
	var gates = []
	for index in selected_items:
		gates.push_back(gates_input.get_item_text(index))
		
	var level_data = {
		"name": name_input.text,
		"n_inputs": int(inputs_spin.value),
		"n_outputs": int(outputs_spin.value),
		"allowed_gates": gates,
		"truth_table": get_truth_table_values(),
		"help": help_input.text
	}
	
	var level_name = filename_input.text
	var file_path = "res://levels/%s.json" % level_name
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(level_data, "  "))
	file.close()
	
func create_gate_selection_panel():
	for gate_name in LevelInfo.GateType.keys():
		gates_input.add_item(gate_name)
	
func _ready() -> void:
	truth_table = _create_inputs_dots(3, 1)
	tab_container.add_child(truth_table)
	create_gate_selection_panel()

func _on_inputs_spin_box_value_changed(value: float) -> void:
	var n_inputs = int(value)
	var n_columns = int(pow(2, n_inputs))
	var current_values = get_truth_table_values()
	var n_outputs = current_values.size()
	
	var new_values = []
	for row_idx in range(n_outputs):
		var new_row = []
		var old_row = current_values[row_idx] if row_idx < current_values.size() else []
		
		for col_idx in range(n_columns):
			if col_idx < old_row.size():
				new_row.append(old_row[col_idx])
			else:
				new_row.append(false)
				
		new_values.append(new_row)

	truth_table.queue_free()
	truth_table = _create_inputs_dots(inputs_spin.value, outputs_spin.value)
	tab_container.add_child(truth_table)
	set_truth_table_values(new_values)

func create_zero_array(n: int) -> Array:
	var zero_array = []
	for i in range(n):
		zero_array.append(false)
	return zero_array

func _on_outputs_spin_box_value_changed(value: float) -> void:
	var values = get_truth_table_values()
	while values.size() > value:
		values.pop_back()
	
	var zero_row = create_zero_array(inputs_spin.value)
	while values.size() < value:
		values.push_back(zero_row)
	
	truth_table.queue_free()
	truth_table = _create_inputs_dots(inputs_spin.value, outputs_spin.value)
	tab_container.add_child(truth_table)
	set_truth_table_values(values)


func _on_load_button_pressed() -> void:	
	var level_name = filename_input.text
	var file_path = "res://levels/%s.json" % level_name
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var level_data = JSON.parse_string(file.get_as_text())
		name_input.text = level_data.name
		inputs_spin.value = level_data.n_inputs
		outputs_spin.value = level_data.n_outputs
		
		gates_input.deselect_all()
		for gate in level_data.allowed_gates:
			for i in range(gates_input.get_item_count()):
				if gates_input.get_item_text(i) == gate:
					gates_input.select(i, false)
		
		truth_table.queue_free()
		truth_table = _create_inputs_dots(inputs_spin.value, outputs_spin.value)
		tab_container.add_child(truth_table)
		set_truth_table_values(level_data.truth_table)
		help_input.text = level_data.help
		
	else:
		print("Unknown name")


func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
