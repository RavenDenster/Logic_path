extends Node

const SAVE_FILE_PATH = "user://logic_gates_save.json"

@export var game_data = {
	"level_stats": {}
}

@export var displayed_warning: bool = false

var temp_level_stats: Dictionary

func _ready():
	load_game()
	temp_level_stats = _base_level_stats()

func save_game():
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if not file:
		var error = FileAccess.get_open_error()
		MessageDisplay.msgbox("Failed to save game! Error: " + error)
		return
	
	var json_string = JSON.stringify(game_data)
	file.store_string(json_string)
	file.close()

func load_game():
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		reset_progress()
		return
	
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if not file:
		MessageDisplay.msgbox("Не удалось открыть файл с сохранением")
		reset_progress()
		return
	
	var json_string = file.get_as_text()
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result == OK:
		game_data = json.data
	else:
		MessageDisplay.msgbox("JSON Parse Error: " + json.get_error_message())
		reset_progress()
	file.close()

func reset_progress():
	game_data = {
		"level_stats": {}
	}
	save_game()

func start_level(level_stats: Dictionary):
	level_stats["start"] = Time.get_unix_time_from_system()
	
func _base_level_stats() -> Dictionary:
	return {
		"start": 0,
		"time": -1,
		"completed": false
	}

func record_level_start():
	if LevelInfo.path.is_empty():
		temp_level_stats = _base_level_stats()
		start_level(temp_level_stats)
		return
	
	if not game_data.has("level_stats"):
		game_data["level_stats"] = {}

	if not game_data["level_stats"].has(LevelInfo.path):
		game_data["level_stats"][LevelInfo.path] = _base_level_stats()
	
	start_level(game_data["level_stats"][LevelInfo.path])
	save_game()

func record_level_completion_for(stats):
	var completion_time = Time.get_unix_time_from_system()
	var time_taken = completion_time - float(stats.get("start", completion_time))
	
	if stats["time"] == -1:
		stats["time"] = time_taken
	else:
		stats["time"] = min(stats["time"], time_taken)
	
	stats["completed"] = true
	save_game()

func record_level_completion():
	if LevelInfo.path.is_empty():
		record_level_completion_for(temp_level_stats)
		return
	
	if not game_data.has("level_stats") or not game_data["level_stats"].has(LevelInfo.path):
		record_level_start()
	
	record_level_completion_for(game_data["level_stats"][LevelInfo.path])

func res() -> String:
	if OS.has_feature("standalone"):
		return OS.get_executable_path().get_base_dir() + "/"
	else:
		return "res://" 
		
func format_stats_text_for(stats: Dictionary):
	var t = int(stats.time)
	var mins = int(t / 60)
	var secs = int(t) % 60
	
	if stats.completed:
		return " | Решена | %02d:%02d" % [mins, secs]
	else:
		return ""

func format_stats_text(filename):
	if filename == "":
		return format_stats_text_for(temp_level_stats)
	
	if SaveSystemGlobal.game_data.level_stats.has(filename):
		return format_stats_text_for(SaveSystemGlobal.game_data.level_stats[filename])
	else:
		return ""
