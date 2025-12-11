extends Node2D

@onready var name_input = find_child("NameInput")
@onready var help_input = find_child("HelpInput")
@onready var inputs_spin = find_child("InputsSpinBox")
@onready var outputs_spin = find_child("OutputsSpinBox")
@onready var gates_input = find_child("GatesInput")

@onready var tab_container = find_child("Container")
var truth_table

@onready var save_file_dlg = find_child("SaveFileDialog")
@onready var load_file_dlg = find_child("LoadFileDialog")
var cur_path: String

@onready var help_tabs = find_child("HelpTabs")
@onready var help_preview = find_child("HelpPreview")

func _create_row_label(text):
	var label = LineEdit.new()
	label.text = text
	label.expand_to_text_length = true
	label.custom_minimum_size.x = 50
	label.flat = true
	return label

func _create_inputs_dots(n_inputs: int, n_outputs: int) -> GridContainer:
	var grid = GridContainer.new()
	var n_columns = pow(2, n_inputs)
	grid.columns = n_columns + 2
	
	var red = Color(0.73, 0.377, 0.383, 1.0)
	var green = Color(0.533, 0.705, 0.439, 1.0)
	
	var red_circle = _create_circle_stylebox(red)
	var green_circle = _create_circle_stylebox(green)
	var red_hover = _create_circle_stylebox(red.darkened(0.25))
	var green_hover = _create_circle_stylebox(green.darkened(0.25))
	
	var input_names = []
	for input_row in range(n_inputs):
		var label = _create_row_label("Вход %d" % input_row)
		input_names.append(label)
		grid.add_child(label)
		grid.add_child(VSeparator.new())
		
		for col in range(n_columns):
			var bit = (col >> (n_inputs - 1 - input_row)) & 1
			var dot = Panel.new()
			
			dot.custom_minimum_size = Vector2(24, 24)
			if bit == 1: dot.add_theme_stylebox_override("panel", green_circle)
			else: dot.add_theme_stylebox_override("panel", red_circle)
			grid.add_child(dot)
	
	for i in range(n_columns + 2):
		grid.add_child(HSeparator.new())
	
	var output_buttons = []
	var output_names = []
	for output_row in range(n_outputs):
		var label = _create_row_label("Выход %d" % output_row)
		output_names.append(label)
		grid.add_child(label)
		grid.add_child(VSeparator.new())
		
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
			grid.add_child(button)
			row_buttons.append(button)
		
		output_buttons.append(row_buttons)
	
	grid.set_meta("output_buttons", output_buttons)
	grid.set_meta("input_names", input_names)
	grid.set_meta("output_names", output_names)
	grid.set_meta("n_inputs", n_inputs)
	grid.set_meta("n_outputs", n_outputs)
	return grid

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

func reset() -> void:
	if truth_table:
		truth_table.queue_free()
	truth_table = _create_inputs_dots(3, 1)
	tab_container.add_child(truth_table)
	
	name_input.text = ""
	help_input.text = ""
	inputs_spin.value = 3
	outputs_spin.value = 1
	gates_input.deselect_all()

func create_zero_array(n: int) -> Array:
	var zero_array = []
	for i in range(n):
		zero_array.append(false)
	return zero_array

func load_level(filename):
	var file = FileAccess.open(filename, FileAccess.READ)
	var level_data = JSON.parse_string(file.get_as_text())
	
	name_input.text = level_data.name
	help_input.text = level_data.help
	inputs_spin.value = level_data.n_inputs
	outputs_spin.value = level_data.n_outputs
	
	truth_table.queue_free()
	truth_table = _create_inputs_dots(inputs_spin.value, outputs_spin.value)
	tab_container.add_child(truth_table)
	set_truth_table_values(level_data.truth_table)
	
	var input_names = truth_table.get_meta("input_names")
	for i in range(len(input_names)):
		input_names[i].text = level_data.input_names[i]
		
	var output_names = truth_table.get_meta("output_names")
	for i in range(len(output_names)):
		output_names[i].text = level_data.output_names[i]
	
	gates_input.deselect_all()
	for gate in level_data.allowed_gates:
		for i in range(gates_input.get_item_count()):
			if gates_input.get_item_text(i) == gate:
				gates_input.select(i, false)
	
	MessageDisplay.display_message("Задача загружена")

func save_level(filename) -> void:
	var gates = []
	for index in gates_input.get_selected_items():
		gates.push_back(gates_input.get_item_text(index))
		
	var input_names = []
	for edit in truth_table.get_meta("input_names"):
		input_names.append(edit.text)
		
	var output_names = []
	for edit in truth_table.get_meta("output_names"):
		output_names.append(edit.text)
		
	var level_data = {
		"truth_table": get_truth_table_values(),
		"input_names": input_names,
		"output_names": output_names,
		
		"name": name_input.text,
		"help": help_input.text,
		"n_inputs": int(inputs_spin.value),
		"n_outputs": int(outputs_spin.value),
		"allowed_gates": gates,
	}
	
	var file = FileAccess.open(filename, FileAccess.WRITE)
	file.store_string(JSON.stringify(level_data, "  "))
	file.close()
	
	MessageDisplay.display_message("Задача сохранена")

#############
# CALLBACKS #
#############

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

func _ready() -> void:
	for gate_name in LevelInfo.GateType.keys():
		gates_input.add_item(gate_name)
		
	help_tabs.set_tab_title(0, "Редактировать")
	help_tabs.set_tab_title(1, "Предпросмотр")
	reset()

func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")

func _on_load_button_pressed() -> void:	
	load_file_dlg.popup_centered()

func _on_save_button_pressed() -> void:
	if cur_path.is_empty():
		save_file_dlg.popup_centered()
	else:
		save_level(cur_path)

func _on_save_as_button_pressed() -> void:
	save_file_dlg.popup_centered()
	
func _on_load_file_dialog_file_selected(path: String) -> void:
	cur_path = path
	load_level(cur_path)

func _on_save_file_dialog_file_selected(path: String) -> void:
	cur_path = path
	save_level(cur_path)

func _on_new_button_pressed() -> void:
	cur_path = ""
	reset()
	MessageDisplay.display_message("Новая задача создана")
	
func _on_help_tabs_tab_changed(tab: int) -> void:
	if tab == 1:
		help_preview.markdown_text = help_input.text
