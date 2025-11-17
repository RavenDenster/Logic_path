extends "res://scripts/levels/LevelBitCounter4.gd"

func _ready():
	level_data = preload("res://data/level_30_data.tres")
	super._ready()

func _on_add_d_flip_flop_button_pressed():
	print("Adding D Flip-Flop in Level30")
	var dff = preload("res://scenes/gates/DFlipFlop.tscn").instantiate()
	dff.position = Vector2(600, 400)
	add_child(dff)
	movable_objects.append(dff)
	update_all_logic_objects()
	mark_level_state_dirty()

func _on_add_clk_button_pressed():
	print("Adding CLK Gate in Level30")
	var clk = preload("res://scenes/gates/CLKGate.tscn").instantiate()
	clk.position = Vector2(600, 500)
	add_child(clk)
	movable_objects.append(clk)
	update_all_logic_objects()
	mark_level_state_dirty()
