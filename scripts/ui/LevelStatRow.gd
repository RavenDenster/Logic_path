extends HBoxContainer

@onready var level_label = $LevelNumber
@onready var status_label = $Status
@onready var time_label = $Time
@onready var attempts_label = $Attempts

func set_data(level_num: int, level_name: String, completed: bool, time_taken: float, attempts: int):
	level_label.text = level_name
	
	if completed:
		status_label.text = "Completed"
		status_label.add_theme_color_override("font_color", Color(0, 0.8, 0, 1))  # Зеленый
		
		# Форматируем время с единицами измерения
		if time_taken > 0:
			if time_taken < 60:
				# Меньше минуты: показываем секунды
				time_label.text = "%.1f s" % time_taken
			elif time_taken < 3600:
				# Меньше часа: показываем минуты и секунды
				var minutes = int(time_taken / 60)
				var seconds = int(time_taken) - (minutes * 60)  # Исправлено
				if seconds > 0:
					time_label.text = "%d m %d s" % [minutes, seconds]
				else:
					time_label.text = "%d m" % minutes
			else:
				# Больше часа: показываем часы и минуты
				var hours = int(time_taken / 3600)
				var minutes = int((time_taken - (hours * 3600)) / 60)  # Исправлено
				time_label.text = "%d h %d m" % [hours, minutes]
		else:
			time_label.text = "N/A"
	else:
		status_label.text = "Not Completed"
		status_label.add_theme_color_override("font_color", Color(0.8, 0.2, 0.2, 1))  # Красный
		time_label.text = "N/A"
	
	attempts_label.text = str(attempts)
	
	# Добавляем фоновый цвет для чередующихся строк
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
