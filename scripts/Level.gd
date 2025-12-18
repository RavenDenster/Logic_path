extends Node2D

@onready var level_panel: PanelContainer = find_child("LevelPanel")
@onready var table_panel = find_child("TableContainer")
@onready var level_name: Label = find_child("LevelName")
@onready var root = $PanelContainer
@onready var popup = find_child("Popup")
@onready var description = find_child("Description")

const RADIAL_MENU_SIZE: Vector2 = Vector2(300, 300)

var radial_menu: RadialContainer
var radial_theme1: RadialContainerTheme = RadialContainerTheme.new()
var radial_theme2: RadialContainerTheme = RadialContainerTheme.new()
var radial_prev_idx: int = -1
var inputs: Array[Node2D]
var outputs: Array[Node2D]
var truth_table
var call_idx: int = 0
var have_recursion: bool = false

var start_node: Node = null
var cur_wire: Node = null
@onready var wire_tween: Tween

var wires: Array[Node]

const INPUT_SCENE: PackedScene = preload("res://scenes/blocks/InputBlock.tscn")
const OUTPUT_SCENE: PackedScene = preload("res://scenes/blocks/OutputBlock.tscn")
const WIRE_SCENE = preload("res://scenes/blocks/Wire.tscn")

func create_wire(start_pos: Vector2):
	if cur_wire: cur_wire.queue_free()
	
	var wire = WIRE_SCENE.instantiate()
	level_panel.add_child(wire)
	wire.initialize(start_pos, start_node)
	cur_wire = wire

func _on_wire_started(start: Node, _position: Vector2):
	start_node = start
	create_wire(start.global_position)
		
func _on_wire_ended(end: Node, _position: Vector2):
	if not cur_wire: return
	if cur_wire.finalize(end.global_position, end):
		wire_tween.kill()
		cur_wire.modulate.a = 1
		wires.append(cur_wire)
		recalculate_truth_table()
	else:
		await delete_cur_wire()
	cur_wire = null
	
func _on_select_wire(wire: Node2D):
	if cur_wire: await delete_cur_wire()
	cur_wire = wire

func _process(_delta):
	if cur_wire:
		cur_wire.update_end_point(get_global_mouse_position())

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
	
	radial_theme1.color = Color(0.37, 0.37, 0.37, 1.0)
	radial_theme2.color = Color(0.589, 0.589, 0.589, 1.0)
	
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

func _ready() -> void:
	level_name.text = LevelInfo.data.name
	description.text = LevelInfo.data.help
	
	create_inputs()
	create_outputs()
	create_truth_table()
	create_radial_menu()
	recalculate_truth_table()

func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")

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
	
	for i in range(n_outputs):
		outputs[i].is_good = (not have_recursion and LevelInfo.data.truth_table[i] == new_table[i])
	
	LevelInfo.set_truth_table_values(truth_table, true, new_table)

func delete_cur_wire():
	wire_tween = create_tween()
	wire_tween.tween_property(cur_wire, "modulate:a", 0.0, 0.1).from(cur_wire.modulate.a)
	await wire_tween.finished
	if cur_wire: cur_wire.queue_free()
	cur_wire = null
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

func _on_panel_container_gui_input(event: InputEvent) -> void:
	var pos = get_global_mouse_position()
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			radial_menu.position = get_global_mouse_position() - RADIAL_MENU_SIZE/2
			radial_menu.visible = true
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if not radial_menu.visible: return
			if radial_menu.is_inside_circle(pos):
				var idx = radial_menu.get_index_from_global_position(pos)
				create_gate(idx)
			radial_menu.visible = false
		elif event.is_released():
			if cur_wire: delete_cur_wire()
	elif event is InputEventMouseMotion:
		if radial_menu.is_inside_circle(pos):
			if not radial_menu.is_inside_circle(pos): return
			var idx = radial_menu.get_index_from_global_position(pos)
			
			if radial_prev_idx != -1:
				radial_menu.set_theme_at(radial_prev_idx, radial_theme1)
			radial_menu.set_theme_at(idx, radial_theme2)
			radial_prev_idx = idx


func _on_popup_close_requested() -> void:
	popup.visible = false

func _on_description_button_pressed() -> void:
	popup.visible = true
