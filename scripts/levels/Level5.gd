extends "res://scripts/levels/LevelBase.gd"

func _ready():
	level_data = preload("res://data/level_4_data.tres")
	super._ready()

func _on_add_and_button_pressed():
	var and_gate = preload("res://scenes/gates/ANDGate.tscn").instantiate()
	and_gate.position = Vector2(600, 300)
	add_child(and_gate)
	movable_objects.append(and_gate)
	update_all_logic_objects()
	mark_level_state_dirty()
	print("AND gate added")

func _on_add_or_button_pressed():
	var or_gate = preload("res://scenes/gates/ORGate.tscn").instantiate()
	or_gate.position = Vector2(600, 400)
	add_child(or_gate)
	movable_objects.append(or_gate)
	update_all_logic_objects()
	mark_level_state_dirty()
	print("OR gate added")

func _on_add_not_button_pressed():
	var not_gate = preload("res://scenes/gates/NOTGate.tscn").instantiate()
	not_gate.position = Vector2(600, 500)
	add_child(not_gate)
	movable_objects.append(not_gate)
	update_all_logic_objects()
	mark_level_state_dirty()
	print("NOT gate added")
