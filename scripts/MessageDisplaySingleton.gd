extends Node2D
class_name MessageDisplaySingleton

signal done

var message_node: Control
var background: ColorRect
var label: Label
var timer: Timer
var tween: Tween
var canvas_layer: CanvasLayer

var fade_duration: float = 0.25
var position_offset: Vector2 = Vector2(10, 10)

func _ready() -> void:
	message_node = Control.new()
	message_node.name = "msgbox"
	message_node.anchor_left = 0.0
	message_node.anchor_top = 0.0
	message_node.mouse_filter = Control.MOUSE_FILTER_PASS
	
	background = ColorRect.new()
	background.name = "Background"
	background.color = Color(0, 0, 0, 0.7)
	background.size = Vector2(300, 40)
	background.mouse_filter = Control.MOUSE_FILTER_PASS
	
	label = Label.new()
	label.name = "Label"
	label.text = ""
	label.position = Vector2(10, 10)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.mouse_filter = Control.MOUSE_FILTER_PASS
	
	timer = Timer.new()
	timer.name = "MessageTimer"
	timer.one_shot = true
	timer.timeout.connect(_on_message_timeout)
	
	message_node.add_child(background)
	background.add_child(label)
	message_node.add_child(timer)
	
	canvas_layer = CanvasLayer.new()
	canvas_layer.add_child(message_node)
	canvas_layer.layer = 300
	
	background.gui_input.connect(_background_gui_input)
	
	message_node.modulate.a = 0.0
	message_node.visible = false

func _background_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_on_message_timeout()

func msgbox(text: String) -> void:
	if not get_tree().root.get_children().has(canvas_layer):
		get_tree().root.add_child(canvas_layer)
	
	label.text = text
	await get_tree().process_frame
	
	var padding = Vector2(20, 20)
	var text_size: Vector2 = Vector2(0, 0)
	
	var font = label.get_theme_font("font")
	var sz = label.get_theme_font_size("font")
		
	var lines = text.split("\n")
	for l in lines:
		var line_size = font.get_string_size(l, HORIZONTAL_ALIGNMENT_LEFT, -1, sz)
		text_size.x = max(text_size.x, line_size.x)
		text_size.y += line_size.y
		
	background.size = text_size + padding
	message_node.position = position_offset
	
	if tween and tween.is_valid():
		tween.kill()
	
	message_node.modulate.a = 1.0
	message_node.visible = true
	
	var sound = AudioStreamPlayer.new()
	sound.stream = load("res://assets/sounds/msg.mp3")
	add_child(sound)
	sound.play()
	
	timer.start(2 + len(text) * 0.07)

func _on_message_timeout() -> void:
	if not is_instance_valid(message_node):
		return
	
	tween = create_tween()
	tween.tween_property(message_node, "modulate:a", 0.0, fade_duration)
	tween.tween_callback(func(): 
		if is_instance_valid(message_node):
			message_node.visible = false
	)
	await tween.finished
	done.emit()
