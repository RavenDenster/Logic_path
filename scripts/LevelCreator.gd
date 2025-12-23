extends Control

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
var absent_post_classes: Array[LevelInfo.Post]

@onready var help_tabs = find_child("HelpTabs")
@onready var help_preview = find_child("HelpPreview")
@onready var priority = find_child("Priority")
@onready var tutorial_check: CheckBox = find_child("Tutorial")

func reset() -> void:
	if truth_table:
		truth_table.queue_free()
	truth_table = LevelInfo.create_truth_table(3, 1, true, true, false, null, null)
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
	
	if level_data.has("tutorial"): tutorial_check.button_pressed = level_data.tutorial
	if level_data.has("priority"): priority.value = level_data.priority
	
	truth_table.queue_free()
	truth_table = LevelInfo.create_truth_table(
		inputs_spin.value,
		outputs_spin.value,
		true, true, false,
		level_data.input_names,
		level_data.output_names
	)
	
	tab_container.add_child(truth_table)
	LevelInfo.set_truth_table_values(truth_table, false, level_data.truth_table)
	
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
		"truth_table": LevelInfo.get_truth_table_values(truth_table),
		"input_names": input_names,
		"output_names": output_names,
		
		"name": name_input.text,
		"help": help_input.text,
		"n_inputs": int(inputs_spin.value),
		"n_outputs": int(outputs_spin.value),
		"allowed_gates": gates,
		
		"priority": int(priority.value),
		"tutorial": tutorial_check.button_pressed
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
	var current_values = LevelInfo.get_truth_table_values(truth_table)
	
	var input_names = []
	for edit in truth_table.get_meta("input_names"):
		input_names.append(edit.text)
		
	var output_names = []
	for edit in truth_table.get_meta("output_names"):
		output_names.append(edit.text)
		
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
	
	while len(input_names) > value:
		input_names.pop_back()
	
	while len(input_names) < value:
		input_names.append("Вход %d" % [len(input_names) + 1])

	truth_table.queue_free()
	truth_table = LevelInfo.create_truth_table(
		inputs_spin.value, outputs_spin.value,
		true, true, false, input_names, output_names
	)
	
	tab_container.add_child(truth_table)
	LevelInfo.set_truth_table_values(truth_table, false, new_values)

func _on_outputs_spin_box_value_changed(value: float) -> void:
	var values = LevelInfo.get_truth_table_values(truth_table)
	
	var input_names = []
	for edit in truth_table.get_meta("input_names"):
		input_names.append(edit.text)
		
	var output_names = []
	for edit in truth_table.get_meta("output_names"):
		output_names.append(edit.text)
	
	while values.size() > value:
		values.pop_back()
	
	var zero_row = create_zero_array(inputs_spin.value)
	while values.size() < value:
		values.push_back(zero_row)
	
	while len(output_names) > value:
		output_names.pop_back()
	
	while len(output_names) < value:
		output_names.append("Выход %d" % [len(input_names) + 1])
	
	truth_table.queue_free()
	truth_table = LevelInfo.create_truth_table(
		inputs_spin.value, outputs_spin.value,
		true, true, false, input_names, output_names
	)
	tab_container.add_child(truth_table)
	LevelInfo.set_truth_table_values(truth_table, false, values)

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

func _on_post_button_pressed() -> void:
	var table = LevelInfo.get_truth_table_values(truth_table)
	var extra_labels = truth_table.get_meta("extra_output_labels")
	var output_names = truth_table.get_meta("output_names")
	
	var ok: bool = true
	var err_msg: String = "Ошибка:\n"
	
	var base = "    Все выбранные логические элементы "
	const CLASS_DESC = {
		LevelInfo.Post.T0: "сохраняют 0 0 (T0)",
		LevelInfo.Post.T1: "сохраняют 1 (T1)",
		LevelInfo.Post.S: "самодвойственны (S)",
		LevelInfo.Post.M: "мажоритарны (M)",
		LevelInfo.Post.L: "линейны (L)"
	}
	
	for i in range(outputs_spin.value):
		err_msg += output_names[i].text + ":\n"
		
		var f = table[i]
		var classes = LevelInfo.get_post_classes(f, inputs_spin.value)
		var classes_str = classes.map(func(c): return LevelInfo.Post.keys()[c])
		extra_labels[i].text = ", ".join(classes_str)
		
		for j in range(LevelInfo.Post.keys().size()):
			var c = j as LevelInfo.Post
			if not classes.has(c) and not absent_post_classes.has(c):
				ok = false;
				err_msg += base + CLASS_DESC[c] + "\n"
	
	if not ok:
		MessageDisplay.display_message(err_msg)
	else:
		MessageDisplay.display_message("ОК! Задача решаема")

func _on_gates_input_item_clicked(_index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	absent_post_classes.clear()
	for index in gates_input.get_selected_items():
		var classes = LevelInfo.GATE_POST_INV[index as LevelInfo.GateType]
		for c in classes:
			if not absent_post_classes.has(c):
				absent_post_classes.append(c)
	
	var classes_str = absent_post_classes.map(func(c): return LevelInfo.Post.keys()[c])
	$Menu/HBox/Margin/VBox/PostLabel.text = ", ".join(classes_str)
