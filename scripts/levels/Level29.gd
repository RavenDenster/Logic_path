# Level29.gd
extends "res://scripts/levels/LevelBitCounter.gd"

func _ready():
	level_data = preload("res://data/level_29_data.tres")
	
	# Явно вызываем родительский _ready
	super._ready()

func _on_add_tflipflop_button_pressed():
	print("Level29: Adding T-FlipFlop gate")
	var gate_scene = preload("res://scenes/gates/TFlipFlopGate.tscn")
	var gate = gate_scene.instantiate()
	
	# Позиция рядом с курсором или в центре экрана
	var viewport_size = get_viewport_rect().size
	gate.position = Vector2(viewport_size.x / 2, viewport_size.y / 2)
	
	add_child(gate)
	movable_objects.append(gate)
	update_all_logic_objects()
	mark_level_state_dirty()
	
	print("T-FlipFlop gate added at position: ", gate.position)
