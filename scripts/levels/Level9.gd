extends "res://scripts/levels/LevelBase.gd"

func _ready():
	level_data = preload("res://data/level_9_data.tres")
	super._ready()

func _on_add_xor_button_pressed():
	var xor_gate = preload("res://scenes/gates/XORGate.tscn").instantiate()
	xor_gate.position = Vector2(600, 400)
	add_child(xor_gate)
	movable_objects.append(xor_gate)
	update_all_logic_objects()
	mark_level_state_dirty()
