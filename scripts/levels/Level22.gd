# Level22.gd
extends "res://scripts/levels/LevelEncoderPriority.gd"

func _ready():
	level_data = preload("res://data/level_22_data.tres")
	super._ready()

func _on_add_or_button_pressed():
	print("Adding OR gate")
	var or_gate = preload("res://scenes/gates/ORGate.tscn").instantiate()
	or_gate.position = Vector2(600, 400)
	add_child(or_gate)
	movable_objects.append(or_gate)
	update_all_logic_objects()
	mark_level_state_dirty()

func _on_add_and_button_pressed():
	print("Adding AND gate")
	var and_gate = preload("res://scenes/gates/ANDGate.tscn").instantiate()
	and_gate.position = Vector2(600, 500)
	add_child(and_gate)
	movable_objects.append(and_gate)
	update_all_logic_objects()
	mark_level_state_dirty()

func _on_add_not_button_pressed():
	print("Adding NOT gate")
	var not_gate = preload("res://scenes/gates/NOTGate.tscn").instantiate()
	not_gate.position = Vector2(600, 600)
	add_child(not_gate)
	movable_objects.append(not_gate)
	update_all_logic_objects()
	mark_level_state_dirty()
