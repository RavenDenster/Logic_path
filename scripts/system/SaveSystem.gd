extends Node

const SAVE_FILE_PATH = "user://logic_gates_save.json"

var game_data = {
	"completed_levels": [],
	"level_states": {},
	"player_name": "Player",
	"last_played_level": 1
}

func _ready():
	load_game()
	print("SaveSystem ready. Completed levels: ", game_data["completed_levels"], " Last played: ", game_data["last_played_level"])

func save_game():
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		var int_completed_levels = []
		for level in game_data["completed_levels"]:
			int_completed_levels.append(int(level))
		game_data["completed_levels"] = int_completed_levels
		
		var json_string = JSON.stringify(game_data)
		file.store_string(json_string)
		file.close()
		print("Game saved successfully. Completed levels: ", game_data["completed_levels"], " Last played: ", game_data["last_played_level"])
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
				
				var int_completed_levels = []
				for level in game_data["completed_levels"]:
					int_completed_levels.append(int(level))
				game_data["completed_levels"] = int_completed_levels
				game_data["last_played_level"] = int(game_data["last_played_level"])
				
				print("Game loaded successfully. Completed levels: ", game_data["completed_levels"], " Last played: ", game_data["last_played_level"])
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
		"level_states": {},
		"player_name": "Player",
		"last_played_level": 1
	}
	save_game()
	print("Game progress reset")

func complete_level(level_number):
	var level_int = int(level_number)
	if not is_level_completed(level_int):
		game_data["completed_levels"].append(level_int)
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
	var max_level = 9
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
