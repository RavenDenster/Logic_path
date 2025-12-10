extends HBoxContainer

@onready var level_label = $LevelNumber
@onready var status_label = $Status
@onready var time_label = $Time
@onready var attempts_label = $Attempts

func set_data(level_num: int, level_name: String, completed: bool, time_taken: float, attempts: int):
	level_label.text = level_name
	
	if completed:
		status_label.text = "Выполнена"
		status_label.add_theme_color_override("font_color", Color(0, 0.8, 0, 1))  # Зеленый
		
		var itime = int(time_taken)
		var secs  = itime % 60
		@warning_ignore("integer_division")
		itime = int(itime / 60)
		var mins  = itime % 60
		@warning_ignore("integer_division")
		itime = int(itime / 60)
		var hours = itime % 60
		
		time_label.text = "%d:%02d:%02d" % [hours, mins, secs]
	else:
		status_label.text = "Не выполнена"
		status_label.add_theme_color_override("font_color", Color(0.8, 0.2, 0.2, 1))  # Красный
		time_label.text = "—"
	
	attempts_label.text = str(attempts)
	
	var index = get_index()
	if index % 2 == 0:
		add_theme_stylebox_override("panel", _create_stylebox(Color(0.2, 0.2, 0.25, 0.3)))
	else:
		add_theme_stylebox_override("panel", _create_stylebox(Color(0.15, 0.15, 0.2, 0.3)))

func _create_stylebox(color: Color) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_right = 5
	style.corner_radius_bottom_left = 5
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 5
	style.content_margin_bottom = 5
	return style
