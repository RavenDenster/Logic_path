extends Node
class_name MessageDisplay

static var instance: MessageDisplay

var message_node: Control
var background: ColorRect
var label: Label
var timer: Timer
var tween: Tween
var canvas_layer: CanvasLayer

var fade_duration: float = 1.0
var position_offset: Vector2 = Vector2(10, 10)

static func display_message(text: String):
	instance.display_message_self(text)

func _ready() -> void:
	instance = self
	_create_ui_elements()
	get_tree().root.add_child.call_deferred(message_node)

func _create_ui_elements() -> void:
	message_node = Control.new()
	message_node.name = "MessageDisplay"
	message_node.anchor_left = 0.0
	message_node.anchor_top = 0.0
	message_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	background = ColorRect.new()
	background.name = "Background"
	background.color = Color(0, 0, 0, 0.7)
	background.size = Vector2(300, 40)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	label = Label.new()
	label.name = "Label"
	label.text = ""
	label.position = Vector2(10, 10)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	timer = Timer.new()
	timer.name = "MessageTimer"
	timer.one_shot = true
	timer.timeout.connect(_on_message_timeout)
	
	message_node.add_child(background)
	background.add_child(label)
	message_node.add_child(timer)
	
	message_node.modulate.a = 0.0
	message_node.visible = false

func display_message_self(text: String) -> void:
	if not is_instance_valid(message_node):
		push_warning("MessageDisplay not initialized")
		return
	
	label.text = text
	await get_tree().process_frame
	
	var padding = Vector2(20, 20)
	var text_size = label.get_theme_font("font").get_string_size(text)
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
	
	timer.start(len(text) * 0.09)

func _on_message_timeout() -> void:
	if not is_instance_valid(message_node):
		return
	
	tween = create_tween()
	tween.tween_property(message_node, "modulate:a", 0.0, fade_duration)
	tween.tween_callback(func(): 
		if is_instance_valid(message_node):
			message_node.visible = false
	)
