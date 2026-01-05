extends Control

@onready var level_list_container = find_child("LevelListContainer")
var first: bool

func load_json_file(path: String) -> Variant:
	var file = FileAccess.open(path, FileAccess.READ)
	var json_text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_text)
	
	if error != OK:
		push_error("JSON Parse Error: " + json.get_error_message())
		return null
	
	print(json)
	return json.get_data()

func _folder_to_control(path: String, basename: String) -> Control:
	var fold = Container.new() if basename.is_empty() else FoldableContainer.new()
	var margin = MarginContainer.new()
	var g_vbox = VBoxContainer.new()
	var grid = GridContainer.new()
	
	if not basename.is_empty():
		fold.folded = not first
	
	if not basename.is_empty():
		fold.title = basename
	
	margin.add_theme_constant_override("margin_left", 50)
	g_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 20)
	grid.add_theme_constant_override("v_separation", 20)
	
	var dirs: Array[String] = []
	var level_files: Array[String] = []
	var dir = DirAccess.open(SaveSystemGlobal.res() + path)
	
	if not dir:
		return fold
		
	dir.list_dir_begin()
	var fname = dir.get_next()
	while fname != "":
		if dir.current_is_dir():
			dirs.append(fname)
		elif not dir.current_is_dir() and fname.ends_with(".json"):
			level_files.append(fname)
		fname = dir.get_next()
	
	var js = []
	for file in level_files:
		var j = load_json_file(SaveSystemGlobal.res() + path + "/" + file)
		if not j.has("priority"):
			j.priority = 0
		j["file"] = file
		js.append(j)
	
	js.sort_custom(func(a, b): return a.priority > b.priority)
	
	for j in js:
		var btn = Button.new()
		var vbox = VBoxContainer.new()
		var lab1 = Label.new()
		var lab2 = Label.new()
		
		var stats_text = SaveSystemGlobal.format_stats_text(SaveSystemGlobal.res() + path + "/" + j.file)
		var gates_text = ", ".join(j.allowed_gates)
		lab1.add_theme_font_size_override("font_size", 30)
		lab1.text = j.name
		lab2.text = "Входов:%d | Выходов:%d | %s%s" \
			% [j.n_inputs, j.n_outputs, gates_text, stats_text]
		btn.add_theme_font_size_override("font_size", 40)
		btn.pressed.connect(_on_btn_pressed.bind(path + "/" + j.file))
		btn.text = ">"
		btn.set_custom_minimum_size(Vector2(60, 60))
		
		vbox.add_child(lab1)
		vbox.add_child(lab2)
		grid.add_child(btn)
		grid.add_child(vbox)
	
	margin.add_child(grid)
	g_vbox.add_child(margin)
	dirs.sort()
	
	for d in dirs:
		var ctl = _folder_to_control(path + "/" + d, d)
		g_vbox.add_child(ctl)
	
	fold.add_child(g_vbox)
	first = false
	return fold

func _create_level_buttons() -> void:
	var ctl = _folder_to_control("levels/", "")
	level_list_container.add_child(ctl)
	
func _on_btn_pressed(filename: String):
	LevelInfo.load_level_data(filename)
	get_tree().change_scene_to_file("res://scenes/Level.tscn")

func _ready():
	first = true
	_create_level_buttons()
	
func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
