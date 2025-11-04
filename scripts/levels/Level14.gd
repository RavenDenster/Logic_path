extends "res://scripts/levels/LevelFullAdder.gd"

func _ready():
	level_data = preload("res://data/level_14_data.tres")
	super._ready()

func _on_add_and_button_pressed():
	var and_gate = preload("res://scenes/gates/ANDGate.tscn").instantiate()
	and_gate.position = Vector2(600, 400)
	add_child(and_gate)
	movable_objects.append(and_gate)
	update_all_logic_objects()
	mark_level_state_dirty()

func _on_add_xor_button_pressed():
	var xor_gate = preload("res://scenes/gates/XORGate.tscn").instantiate()
	xor_gate.position = Vector2(600, 600)
	add_child(xor_gate)
	movable_objects.append(xor_gate)
	update_all_logic_objects()
	mark_level_state_dirty()

func _on_add_or_button_pressed():
	var or_gate = preload("res://scenes/gates/ORGate.tscn").instantiate()
	or_gate.position = Vector2(600, 800)
	add_child(or_gate)
	movable_objects.append(or_gate)
	update_all_logic_objects()
	mark_level_state_dirty()
