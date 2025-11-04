extends "res://scripts/levels/LevelTwoInputs.gd"

func _ready():
	level_data = preload("res://data/level_1_data.tres")
	super._ready()

func _on_add_or_button_pressed():
	var or_gate = preload("res://scenes/gates/ORGate.tscn").instantiate()
	or_gate.position = Vector2(600, 400)
	add_child(or_gate)
	movable_objects.append(or_gate)
	update_all_logic_objects()
	mark_level_state_dirty()
	print("OR gate added to movable_objects array")
