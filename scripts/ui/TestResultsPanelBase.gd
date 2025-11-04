extends Control
class_name TestResultsPanelBase

# Базовый класс для всех панелей результатов
# Дочерние классы должны переопределить эти методы

func load_initial_data(_data):
	push_error("load_initial_data not implemented in " + name)

func update_current_outputs(_outputs):
	push_error("update_current_outputs not implemented in " + name)

func initialize_textures():
	push_error("initialize_textures not implemented in " + name)
