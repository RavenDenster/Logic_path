extends Control

@onready var level_panel = $Panel/Scroll/LevelPanel
@onready var table_panel = $Panel/Lower/Margin/TableContainer
@onready var level_name: Label = $Panel/Upper/Margin/LevelName
@onready var root = $Panel
@onready var popup = $Panel/Popup
@onready var popup_panel = $Panel/Popup/Panel
@onready var description = $Panel/Popup/Panel/Box/Scroll/Description
@onready var desc_button = $Panel/Upper/Margin/DescriptionButton
@onready var exit_button = $Panel/Upper/Margin/ExitButton

const RADIAL_MENU_SIZE: Vector2 = Vector2(300, 300)

var radial_menu: RadialContainer
var radial_theme1: RadialContainerTheme = RadialContainerTheme.new()
var radial_theme2: RadialContainerTheme = RadialContainerTheme.new()
var inputs: Array[Node2D]
var outputs: Array[Node2D]
var gates: Array[Node2D]
var truth_table
var call_idx: int = 0
var have_recursion: bool = false
var start_node: Node = null
var cur_wire: Wire = null
@onready var wire_tween: Tween

var wires: Array[Node]

const INPUT_SCENE: PackedScene = preload("res://scenes/blocks/InputBlock.tscn")
const OUTPUT_SCENE: PackedScene = preload("res://scenes/blocks/OutputBlock.tscn")
const WIRE_SCENE = preload("res://scenes/blocks/Wire.tscn")

signal wire_started
signal wire_ended
signal gate_deleted

func create_wire(start_pos: Vector2):
	if cur_wire:
		cur_wire.untie()
		cur_wire.queue_free()
		
	var wire = WIRE_SCENE.instantiate()
	level_panel.add_child(wire)
	wire.initialize(start_pos, start_node)
	cur_wire = wire

func _on_wire_started(start: Node, _position: Vector2):
	start_node = start
	create_wire(start.global_position)
	wire_started.emit()
		
func _on_wire_ended(end: Node, _position: Vector2):
	if not cur_wire: return
	if cur_wire.finalize(end.global_position, end):
		var tmp_wire = cur_wire
		cur_wire = null
		tmp_wire.stop_animation()
		wires.append(tmp_wire)
		recalculate_truth_table()
		wire_ended.emit()
	else:
		await delete_cur_wire()
	
func _on_select_wire(wire: Node2D):
	if cur_wire:
		cur_wire.untie()
		cur_wire.queue_free()
	
	cur_wire = wire
	wire_started.emit()

func _process(_delta):
	if cur_wire: cur_wire.update_end_point(get_global_mouse_position())

func _on_recursion() -> void:
	MessageDisplay.display_message("Обнаружена рекурсия!")
	have_recursion = true

func create_inputs():
	const Y_PER_INPUT = 100
	
	var start_x = 200
	var start_y = root.size.y/2 - LevelInfo.data.n_inputs*Y_PER_INPUT/2
	
	for i in range(LevelInfo.data.n_inputs):
		var input = INPUT_SCENE.instantiate()
		level_panel.add_child(input)
		input.set_label(LevelInfo.data.input_names[i])
		input.position = Vector2(
			start_x, start_y + i*Y_PER_INPUT
		)
		input.outputs[0].wire_started.connect(_on_wire_started)
		input.outputs[0].recursion_detected.connect(_on_recursion)
		inputs.append(input)

func create_outputs():
	const Y_PER_OUTPUT = 100
	
	var start_x = root.size.x - 300
	var start_y = root.size.y/2 - LevelInfo.data.n_outputs*Y_PER_OUTPUT/2
	
	for i in range(LevelInfo.data.n_outputs):
		var out = OUTPUT_SCENE.instantiate()
		level_panel.add_child(out)
		out.set_label(LevelInfo.data.output_names[i])
		out.position = Vector2(
			start_x, start_y + i*Y_PER_OUTPUT
		)
		out.inputs[0].wire_ended.connect(_on_wire_ended)
		out.inputs[0].select_wire.connect(_on_select_wire)
		outputs.append(out)

func create_truth_table():
	var table = LevelInfo.create_truth_table(
		LevelInfo.data.n_inputs,
		LevelInfo.data.n_outputs,
		false, false, true,
		LevelInfo.data.input_names,
		LevelInfo.data.output_names
	)
	LevelInfo.set_truth_table_values(table, false, LevelInfo.data.truth_table)
	table_panel.add_child(table)
	truth_table = table

func create_radial_menu() -> void:
	var cv = CanvasLayer.new()
	root.add_child(cv)
	cv.layer = 100
	
	radial_theme1.color = ThemeDB.get_project_theme().get_stylebox("normal", "Button").bg_color
	radial_theme1.radius_factor_inner = 0.3
	radial_theme2.color = ThemeDB.get_project_theme().get_stylebox("hover", "Button").bg_color
	radial_theme2.radius_factor_inner = 0.3
	
	radial_menu = RadialContainer.new()
	radial_menu.radial_theme = radial_theme1
	radial_menu.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var i = 0
	for gate in LevelInfo.data.allowed_gates:
		var lab = Label.new()
		lab.text = gate
		radial_menu.add_child(lab)
		radial_menu.set_theme_at(i, radial_theme1)
		i += 1
	
	if len(LevelInfo.data.allowed_gates) == 1:
		var lab = Label.new()
		lab.text = "Закрыть"
		radial_menu.add_child(lab)
	
	radial_menu.size = RADIAL_MENU_SIZE
	radial_menu.visible = false
	cv.add_child(radial_menu)

var tut_data: Dictionary = {
	radial_visible = false,
	inout_msg = false,
	done = false,
	connect_msg = false,
	level_done = false,
	
	remove_wire_msg = false,
	remove_wire_done = false,
	
	move_gate_msg = false,
	move_gate_done = false,
	
	delete_gate_msg = false,
	delete_gate_done = false,
	
	start_pos = Vector2(-1, -1)
}

func _tutorial_welcome():
	root.mouse_filter = MouseFilter.MOUSE_FILTER_STOP
	popup.visible = false
	
	MessageDisplay.display_message("Добро пожаловать. Эта задача является обучающей.")
	await MessageDisplay.done
	
	MessageDisplay.display_message("Следуйте инструкциям, появляющимся в этом углу экрана.")
	await MessageDisplay.done
	
	MessageDisplay.display_message("Удачи!")
	await MessageDisplay.done
	
	popup.visible = true
	MessageDisplay.display_message(
		"Окно посередине содержит описание задачи. \n\
		Оно закрывается нажатием на крестик.\n\
		Ознакомьтесь с описанием и для продолжения закройте его."
	)
	
	await popup.close_requested
	root.mouse_filter = MouseFilter.MOUSE_FILTER_PASS

func _tutorial_addgate_press():
	MessageDisplay.display_message("Чтобы открыть список логических элементов зажмите правую кнопку мыши.")
	await radial_menu.visibility_changed

func _tutorial_addgate_release():
	MessageDisplay.display_message(
		"Теперь наведите мышью на логический элемент, который хотите создать, \n\
		и отпустите правую кнопку."
	)
	await radial_menu.visibility_changed

func _tutorial_connect_msg():
	MessageDisplay.display_message("Отлично! Теперь нужно соединить входы со входами, а выходы с выходами")
	await MessageDisplay.done
	tut_data.connect_msg = true

func _tutorial_inout():
	MessageDisplay.display_message(
		"Слева находятся входы, справа находятся выходы. \n\
		Между ними можно размещать логические элементы."
	)
	
	await MessageDisplay.done
	tut_data.inout_msg = true

func _tutorial_con(start, end):
	return end.connected_to == start

const HIGHLIGHT_MAX = Color(1.25, 0.8, 0)
const HIGHLIGHT_MIN = Color(0, 0, 0)

func _tutorial_remove_wire(end, end_name, mistake):
	if mistake:
		MessageDisplay.display_message("%s. В него подключено что-то не то. Возьмитесь за него и оттяните провод в сторону" % [end_name])
	else:
		MessageDisplay.display_message("%s. В него подключен провод. Возьмитесь за %s и оттяните провод в сторону" % [end_name, end_name])
	var tween = create_tween().set_loops()
	tween.tween_property(end, "modulate", HIGHLIGHT_MIN, 1).from(HIGHLIGHT_MAX)			
	await wire_started
	tween.kill()
	end.modulate = Color(1, 1, 1)
	MessageDisplay.display_message("Оттяните провод в сторону")
	await wire_ended

func _tutorial_do_con(start, end, start_name, end_name):
	if not end.connected_to:
		if not cur_wire:
			var tween = create_tween().set_loops()
			tween.tween_property(start, "modulate", HIGHLIGHT_MIN, 1).from(HIGHLIGHT_MAX)			
			MessageDisplay.display_message("Нажмите на %s и удерживайте кнопку мыши нажатой " % [start_name])
			await wire_started
			tween.kill()
			start.modulate = Color(1, 1, 1)	
			return
		if cur_wire.input_node != start:
			MessageDisplay.display_message("Выбран не тот выход")
			await wire_ended
			return
		MessageDisplay.display_message("Теперь с помощью движения мыши вы можете протянуть провод.\nПереместите мышь на " + end_name)
		var tween2 = create_tween().set_loops()
		tween2.tween_property(end, "modulate", HIGHLIGHT_MIN, 1).from(HIGHLIGHT_MAX)
		await wire_ended
		tween2.kill()
		end.modulate = Color(1, 1, 1)
		return
	else:
		if not cur_wire:
			await _tutorial_remove_wire(end, end_name, true)
			return
		await get_tree().create_timer(1).timeout

func _tutorial_move_gate():
	if not gates[0].is_hovered:
		tut_data.start_pos = Vector2.ZERO
		MessageDisplay.display_message("Наведитесь мышью на логическое И")
		await gates[0].hovered
	elif not gates[0].is_dragged:
		tut_data.start_pos = Vector2.ZERO
		MessageDisplay.display_message("Зажмите кнопку мыши")
		await gates[0].dragged
	else:
		if tut_data.start_pos == Vector2.ZERO:
			tut_data.start_pos = gates[0].global_position
			MessageDisplay.display_message("Переместите мышь куда-нибудь в сторону")
		
		await get_tree().create_timer(0.25).timeout
		if (tut_data.start_pos - gates[0].global_position).length() > 100:
			tut_data.move_gate_done = true

func _tutorial_delete_gate():
	if not gates[0].is_hovered:
		tut_data.start_pos = Vector2.ZERO
		MessageDisplay.display_message("Наведитесь мышью на логическое И")
		await gates[0].hovered
	else:
		MessageDisplay.display_message("Нажмите правой кнопкой мыши на него")
		await gate_deleted
		tut_data.delete_gate_done = true

func _tutorial_scenario():
	await _tutorial_welcome()
	
	while not tut_data.done:
		if not tut_data.inout_msg: await _tutorial_inout()
		elif not tut_data.delete_gate_done and gates.size() == 0:
				if not radial_menu.visible: await _tutorial_addgate_press()
				else: await _tutorial_addgate_release()
		elif not tut_data.connect_msg: await _tutorial_connect_msg()
		elif not tut_data.level_done:
			if not _tutorial_con(inputs[0].outputs[0], gates[0].inputs[0]):
				await _tutorial_do_con(
					inputs[0].outputs[0], gates[0].inputs[0],
					"вход A", "вход логического И"
				)
			elif not _tutorial_con(inputs[1].outputs[0], gates[0].inputs[1]):
				await _tutorial_do_con(
					inputs[1].outputs[0], gates[0].inputs[1],
					"вход B", "вход логического И"
				)
			elif not _tutorial_con(gates[0].outputs[0], outputs[0].inputs[0]):
				await _tutorial_do_con(
					gates[0].outputs[0], outputs[0].inputs[0],
					"выход логического И", "выход A^B"
				)
			else:
				MessageDisplay.display_message("Уровень пройден! Но обучение еще не занончилось")
				await MessageDisplay.done
				tut_data.level_done = true
		elif not tut_data.remove_wire_msg:
			MessageDisplay.display_message("Лишние провода можно удалять. Для этого нужно взяться за конец провода и оттянуть его в сторону")
			await MessageDisplay.done
			tut_data.remove_wire_msg = true
		elif not tut_data.remove_wire_done:
			if gates[0].inputs[0].connected_to:
				await _tutorial_remove_wire(gates[0].inputs[0], "Вход логического И", false)
			else:
				tut_data.remove_wire_done = true
		elif not tut_data.move_gate_msg:
			MessageDisplay.display_message("Логические элементы можно перемещать.")
			await MessageDisplay.done
			tut_data.move_gate_msg = true
		elif not tut_data.move_gate_done:
			await _tutorial_move_gate()
		elif not tut_data.delete_gate_msg:
			MessageDisplay.display_message("Также, если вы создали лишний логический элемент, то его можно удалить")
			await MessageDisplay.done
			MessageDisplay.display_message("Для этого нужно на него нажать правой кнопкой мыши")
			await MessageDisplay.done
			tut_data.delete_gate_msg = true
		elif not tut_data.delete_gate_done:
			await _tutorial_delete_gate()
		else:
			MessageDisplay.display_message("Обучение пройдено. Можно покинуть эту задачу")
			tut_data.done = true
	
func _ready() -> void:
	if LevelInfo.path == "":
		$Panel/Upper/Margin/DescriptionButton.visible = false
		popup.visible = false
	
	if LevelInfo.data.tutorial:
		call_deferred("_tutorial_scenario")
		
	var stats_text = SaveSystemGlobal.format_stats_text(LevelInfo.path)
	SaveSystemGlobal.record_level_start()
	level_name.text = LevelInfo.data.name + " | " + stats_text
	description.markdown_text = LevelInfo.data.help
	
	create_inputs()
	create_outputs()
	create_truth_table()
	create_radial_menu()
	recalculate_truth_table()

func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/LevelMap.tscn")

func recalculate_truth_table() -> void:
	have_recursion = false
	
	var n_inputs = int(LevelInfo.data.n_inputs)
	var n_outputs = int(LevelInfo.data.n_outputs)
	var n_combinations = (1 << n_inputs)
	
	var new_table: Array = []
	for i in range(n_outputs):
		new_table.append([])
	
	call_idx = 0
	for comb in range(n_combinations):
		for i in range(LevelInfo.data.n_inputs):
			var bit = (comb >> (n_inputs - 1 - i)) & 1
			inputs[i].cur_value = bool(bit)
		
		for i in range(int(LevelInfo.data.n_outputs)):
			var val = outputs[i].inputs[0].get_value(call_idx)
			call_idx += 1
			new_table[i].append(bool(val))
	
	var n_is_good = 0
	for i in range(n_outputs):
		if (not have_recursion and LevelInfo.data.truth_table[i] == new_table[i]):
			outputs[i].is_good = true
			n_is_good += 1
		else:
			outputs[i].is_good = false
	
	LevelInfo.set_truth_table_values(truth_table, true, new_table)
	
	if n_is_good == n_outputs:
		SaveSystemGlobal.record_level_completion()
		var stats_text = SaveSystemGlobal.format_stats_text(LevelInfo.path)
		level_name.text = LevelInfo.data.name + " | " + stats_text
		
		var tween = create_tween()
		tween.tween_property(level_panel, "modulate", Color(0.95, 1.05, 0.95), 0.2).set_trans(Tween.TRANS_SINE)
		
		var tween2 = create_tween().set_loops()
		tween2.tween_property(exit_button, "modulate", Color(1, 1, 1), 1).from(Color(2, 2, 2)).set_trans(Tween.TRANS_SINE)
	else:
		var tween = create_tween()
		tween.tween_property(level_panel, "modulate", Color.WHITE, 0.2).set_trans(Tween.TRANS_SINE)
		
func delete_cur_wire():
	if not cur_wire: return
	await cur_wire.delete_to_start_animation()
	
	if not cur_wire: return 
	cur_wire.untie()
	cur_wire.queue_free()
	cur_wire = null
	wire_ended.emit()
	recalculate_truth_table()

func create_gate(idx: int) -> void:
	if idx >= len(LevelInfo.data.allowed_gates): return
	
	var gate_id = LevelInfo.GateType.get(LevelInfo.data.allowed_gates[idx])
	var gate = LevelInfo.create_gate(gate_id)
	gate.position = radial_menu.position + RADIAL_MENU_SIZE/2
	
	level_panel.add_child(gate)
	for input in gate.inputs:
		input.wire_ended.connect(_on_wire_ended)
		input.select_wire.connect(_on_select_wire)
	for output in gate.outputs:
		output.wire_started.connect(_on_wire_started)
		output.recursion_detected.connect(_on_recursion)
	gates.append(gate)

func _remove_gate(gate: Gate):
	for out in gate.outputs:
		for c in out.connected_to:
			c.wire_ref.delete_to_end_animation()
			c.connected_to = null
	
	for input in gate.inputs:
		if input.wire_ref:
			input.wire_ref.delete_to_start_animation()
			if input.connected_to and input.connected_to.connected_to:
				input.connected_to.connected_to.erase(input)
	
	var tween = create_tween()
	tween.tween_property(gate, "scale", Vector2.ZERO, 0.2)
	await tween.finished
	
	for out in gate.outputs:
		for c in out.connected_to:
			c.wire_ref.queue_free()
	
	for input in gate.inputs:
		if input.wire_ref:
			input.wire_ref.queue_free()
	
	gates.erase(gate)
	gate_deleted.emit()
	gate.queue_free()
	recalculate_truth_table()

func _check_hit():
	var space = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = get_global_mouse_position()
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var result = space.intersect_point(query)
	
	if result.size() == 0:
		var mouse = get_global_mouse_position()
		var tween = create_tween()
		var tween2 = create_tween()
		tween.tween_property(radial_menu, "size", RADIAL_MENU_SIZE, 0.05).from(Vector2(0, 0)).set_ease(Tween.EASE_IN_OUT)
		tween2.tween_property(radial_menu, "position", mouse - RADIAL_MENU_SIZE/2, 0.05).from(mouse).set_ease(Tween.EASE_IN_OUT)
		radial_menu.visible = true
		for i in range(radial_menu.get_children().size()):
			radial_menu.set_theme_at(i, radial_theme1)
	else:
		var gate = result[0].collider.get_parent()
		if gate.removable:
			_remove_gate(gate)

func _on_panel_container_gui_input(event: InputEvent) -> void:
	var pos = get_global_mouse_position()
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_check_hit()
			
		elif event.is_released():
			if radial_menu.visible:
				if radial_menu.is_inside_circle(pos):
					var idx = radial_menu.get_index_from_global_position(pos)
					create_gate(idx)
					
				var tween = create_tween()
				var tween2 = create_tween()
				tween.tween_property(radial_menu, "size", Vector2.ZERO, 0.05).set_ease(Tween.EASE_IN_OUT)
				tween2.tween_property(radial_menu, "position", RADIAL_MENU_SIZE/2, 0.05).as_relative().set_ease(Tween.EASE_IN_OUT)
				await tween.finished
				await tween2.finished
				radial_menu.visible = false
			elif cur_wire:
				delete_cur_wire()
			
	elif event is InputEventMouseMotion:
		for i in range(radial_menu.get_children().size()):
				radial_menu.set_theme_at(i, radial_theme1)
		if radial_menu.is_inside_circle(pos):
			if not radial_menu.is_inside_circle(pos): return
			var idx = radial_menu.get_index_from_global_position(pos)
			radial_menu.set_theme_at(idx, radial_theme2)


func _on_popup_close_requested() -> void:
	var tween = create_tween()
	var tween2 = create_tween()
	var tween3 = create_tween()
	tween.tween_property(popup, "size", Vector2i(100, 100), 0.2).set_ease(Tween.EASE_OUT)
	tween2.tween_property(popup, "position", Vector2i(desc_button.global_position + desc_button.size/2 - Vector2(50, 50)), 0.2).set_ease(Tween.EASE_OUT)
	tween3.tween_property(popup_panel, "modulate:a", 0.0, 0.1)
	await tween3.finished
	await tween.finished
	await tween2.finished
	popup.visible = false
	
	var tween4 = create_tween()
	tween4.tween_property(desc_button, "modulate", Color(1.25, 1.25, 1.25), 0.1).set_ease(Tween.EASE_IN_OUT)
	await tween4.finished
	
	var tween5 = create_tween()
	tween5.tween_property(desc_button, "modulate", Color(1, 1, 1), 0.1).set_ease(Tween.EASE_IN_OUT)
	await tween5.finished

func _on_description_button_pressed() -> void:
	popup.size = popup.max_size
	popup_panel.modulate.a = 1.0
	popup.popup_centered()
