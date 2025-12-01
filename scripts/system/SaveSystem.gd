extends Node

const SAVE_FILE_PATH = "user://logic_gates_save.json"

var game_data = {
	"completed_levels": [],
	"level_states": {},
	"player_name": "Player",
	"last_played_level": 1,
	"theory_viewed": {},
	"level_stats": {}
}

func _ready():
	load_game()
	print("SaveSystem ready. Completed levels: ", game_data["completed_levels"], " Last played: ", game_data["last_played_level"], " Unlocked levels: ", game_data.get("unlocked_levels", []))


func save_game():
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		var int_completed_levels = []
		for level in game_data["completed_levels"]:
			int_completed_levels.append(int(level))
		game_data["completed_levels"] = int_completed_levels
		
		# Также преобразуем unlocked_levels в int
		if game_data.has("unlocked_levels"):
			var int_unlocked_levels = []
			for level in game_data["unlocked_levels"]:
				int_unlocked_levels.append(int(level))
			game_data["unlocked_levels"] = int_unlocked_levels
		
		var json_string = JSON.stringify(game_data)
		file.store_string(json_string)
		file.close()
		print("Game saved successfully. Completed levels: ", game_data["completed_levels"], " Last played: ", game_data["last_played_level"], " Unlocked levels: ", game_data.get("unlocked_levels", []))
	else:
		var error = FileAccess.get_open_error()
		push_error("Failed to save game! Error: ", error)


func load_game():
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			if parse_result == OK:
				game_data = json.data
				if not game_data.has("completed_levels"):
					game_data["completed_levels"] = []
				if not game_data.has("level_states"):
					game_data["level_states"] = {}
				if not game_data.has("last_played_level"):
					game_data["last_played_level"] = 1
				if not game_data.has("unlocked_levels"):  # Добавляем инициализацию unlocked_levels
					game_data["unlocked_levels"] = []
				if not game_data.has("theory_viewed"):
					game_data["theory_viewed"] = {}
				
				var int_completed_levels = []
				for level in game_data["completed_levels"]:
					int_completed_levels.append(int(level))
				game_data["completed_levels"] = int_completed_levels
				game_data["last_played_level"] = int(game_data["last_played_level"])
				
				# Также преобразуем unlocked_levels в int
				var int_unlocked_levels = []
				for level in game_data["unlocked_levels"]:
					int_unlocked_levels.append(int(level))
				game_data["unlocked_levels"] = int_unlocked_levels
				
				print("Game loaded successfully. Completed levels: ", game_data["completed_levels"], " Last played: ", game_data["last_played_level"], " Unlocked levels: ", game_data["unlocked_levels"])
			else:
				push_error("JSON Parse Error: ", json.get_error_message())
				reset_progress()
			file.close()
		else:
			push_error("Failed to open save file for reading")
			reset_progress()
	else:
		print("No save file found, creating new one")
		reset_progress()

func reset_progress():
	game_data = {
		"completed_levels": [],
		"unlocked_levels": [],
		"level_states": {},
		"player_name": "Player",
		"last_played_level": 1,
		"theory_viewed": {},
		"level_stats": {}  # НОВОЕ
	}
	save_game()
	print("Game progress reset")
	
func record_level_start(level_number: int):
	var level_str = str(level_number)
	if not game_data.has("level_stats"):
		game_data["level_stats"] = {}
	
	if not game_data["level_stats"].has(level_str):
		# Первый заход на уровень
		game_data["level_stats"][level_str] = {
			"first_entry_time": Time.get_unix_time_from_system(),
			"completion_time": 0,
			"attempts": 0,
			"best_time": 0,
			"completed": false
		}
		save_game()
		print("Recorded first entry for level ", level_number)

func record_level_attempt(level_number: int):
	var level_str = str(level_number)
	if game_data.has("level_stats") and game_data["level_stats"].has(level_str):
		var stats = game_data["level_stats"][level_str]
		stats["attempts"] = stats.get("attempts", 0) + 1
		save_game()
		print("Recorded attempt for level ", level_number, ": ", stats["attempts"])

func record_level_completion(level_number: int):
	var level_str = str(level_number)
	if game_data.has("level_stats") and game_data["level_stats"].has(level_str):
		var stats = game_data["level_stats"][level_str]
		if not stats.get("completed", false):
			var completion_time = Time.get_unix_time_from_system()
			var time_taken = completion_time - stats.get("first_entry_time", completion_time)
			
			stats["completion_time"] = completion_time
			stats["time_taken"] = time_taken  # время в секундах
			stats["completed"] = true
			
			# Сохраняем лучшее время
			if stats.get("best_time", 0) == 0 or time_taken < stats["best_time"]:
				stats["best_time"] = time_taken
			
			save_game()
			print("Recorded completion for level ", level_number, 
				" Time taken: ", format_time(time_taken),
				" Attempts: ", stats["attempts"])
	else:
		# Если статистики не было, создаем запись
		record_level_start(level_number)
		record_level_completion(level_number)

func get_level_stats(level_number: int) -> Dictionary:
	var level_str = str(level_number)
	if game_data.has("level_stats") and game_data["level_stats"].has(level_str):
		return game_data["level_stats"][level_str].duplicate(true)
	return {
		"completed": false,
		"attempts": 0,
		"time_taken": 0,
		"best_time": 0
	}

func get_all_level_stats() -> Dictionary:
	if game_data.has("level_stats"):
		return game_data["level_stats"].duplicate(true)
	return {}

func format_time(seconds: float) -> String:
	if seconds <= 0:
		return "N/A"
	
	var minutes = int(seconds / 60)
	var secs = int(seconds) % 60
	var ms = int((seconds - int(seconds)) * 100)
	
	if minutes > 0:
		return "%02d:%02d.%02d" % [minutes, secs, ms]
	else:
		return "%02d.%02d" % [secs, ms]

func unlock_levels(level_numbers):
	for level_num in level_numbers:
		if not level_num in game_data["unlocked_levels"]:
			game_data["unlocked_levels"].append(int(level_num))
	save_game()
	print("Levels unlocked via cheat: ", level_numbers)

func is_level_unlocked(level_number):
	var level_int = int(level_number)
	
	# Если уровень пройден, он автоматически считается открытым
	if is_level_completed(level_int):
		return true
	
	# Проверяем, есть ли уровень в списке открытых
	if game_data.has("unlocked_levels") and level_int in game_data["unlocked_levels"]:
		return true
	
	return false
	
func increment_failed_attempts(level_number: int) -> void:
	if not game_data.has("failed_attempts"):
		game_data["failed_attempts"] = {}
	
	var level_str = str(level_number)
	var current_attempts = game_data["failed_attempts"].get(level_str, 0)
	game_data["failed_attempts"][level_str] = current_attempts + 1
	save_game()
	print("Failed attempts for level ", level_number, ": ", current_attempts + 1)

func reset_failed_attempts(level_number: int) -> void:
	if not game_data.has("failed_attempts"):
		return
	
	var level_str = str(level_number)
	if game_data["failed_attempts"].has(level_str):
		game_data["failed_attempts"][level_str] = 0
		save_game()
		print("Reset failed attempts for level ", level_number)

func get_failed_attempts(level_number: int) -> int:
	if not game_data.has("failed_attempts"):
		return 0
	return game_data["failed_attempts"].get(str(level_number), 0)

func complete_level(level_number):
	var level_int = int(level_number)
	if not is_level_completed(level_int):
		game_data["completed_levels"].append(level_int)
		record_level_completion(level_int)  # Записываем статистику
		save_game()
		print("Level ", level_int, " marked as completed")
	else:
		print("Level ", level_int, " already completed")
		
	# Обновляем last_played_level
	game_data["last_played_level"] = level_int
	save_game()

func is_level_completed(level_number):
	var level_int = int(level_number)
	for level in game_data["completed_levels"]:
		if int(level) == level_int:
			return true
	return false

func get_completed_levels():
	var int_levels = []
	for level in game_data["completed_levels"]:
		int_levels.append(int(level))
	return int_levels

func save_level_state(level_number, data):
	var level_int = int(level_number)
	game_data["level_states"][str(level_int)] = data
	game_data["last_played_level"] = level_int
	save_game()
	print("Level ", level_int, " state saved. Last played level updated to: ", level_int)

func get_level_state(level_number):
	var level_int = int(level_number)
	if game_data.has("level_states") and game_data["level_states"].has(str(level_int)):
		return game_data["level_states"][str(level_int)]
	return null

func get_last_played_level():
	return game_data["last_played_level"]

func set_last_played_level(level_number):
	game_data["last_played_level"] = int(level_number)
	save_game()

func get_next_level_to_play():
	var max_level = 30  # ИСПРАВЛЕНО: было 23, теперь 30
	var last_played = game_data["last_played_level"]
	var completed_levels = game_data["completed_levels"]

	if not is_level_completed(last_played):
		return last_played

	for level in range(last_played + 1, max_level + 1):
		if not is_level_completed(level):
			return level

	return last_played

static func get_save_system():
	return Engine.get_main_loop().root.get_node("SaveSystem")

func is_theory_viewed(level_number: int) -> bool:
	var level_str = str(level_number)
	if game_data.has("theory_viewed") and game_data["theory_viewed"].has(level_str):
		return game_data["theory_viewed"][level_str]
	return false

func set_theory_viewed(level_number: int, viewed: bool):
	if not game_data.has("theory_viewed"):
		game_data["theory_viewed"] = {}
	
	game_data["theory_viewed"][str(level_number)] = viewed
	save_game()
	print("Theory viewed flag set for level ", level_number, ": ", viewed)
