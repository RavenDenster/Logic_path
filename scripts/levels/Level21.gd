# Level21.gd
extends "res://scripts/levels/LevelEncoder.gd"

func _ready():
	level_data = preload("res://data/level_21_data.tres")
	super._ready()

func _on_add_or_button_pressed():
	print("Adding OR gate")
	var or_gate = preload("res://scenes/gates/ORGate.tscn").instantiate()
	or_gate.position = Vector2(600, 400)
	add_child(or_gate)
	movable_objects.append(or_gate)
	update_all_logic_objects()
	mark_level_state_dirty()
