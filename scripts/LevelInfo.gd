extends Node
class_name LevelInfo

enum GateType { AND, OR, NAND, NOR, NOT }

static var data: Dictionary
static var path: String

static func load_level_data(level_path: String):
	var file = FileAccess.open(level_path, FileAccess.READ)
	var json_data = JSON.parse_string(file.get_as_text())
	file.close()
	data = json_data
	path = level_path
