# DoubleLabelButton.gd
class_name DoubleLabelButton
extends PanelContainer

# Emit this to mimic button behavior
signal pressed

# Export properties for easy editing in Inspector
@export var top_text: String = "Top Label":
	set(value):
		top_text = value
		if _top_label:
			_top_label.text = value
			queue_redraw()

@export var bottom_text: String = "Bottom Label":
	set(value):
		bottom_text = value
		if _bottom_label:
			_bottom_label.text = value
			queue_redraw()

# Margin/padding controls
@export var margin_left: int = 20
@export var margin_right: int = 20
@export var margin_top: int = 15
@export var margin_bottom: int = 15
@export var vertical_separation: int = 5

# Node references
var _top_label: Label
var _bottom_label: Label
var _vbox: VBoxContainer
var _is_hovered: bool = false
var _is_pressed: bool = false

func _ready() -> void:
	_setup()
	# Make clickable
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _setup() -> void:
	# Create main container
	_vbox = VBoxContainer.new()
	_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_vbox.add_theme_constant_override("separation", vertical_separation)
	
	# Top label with font size 30
	_top_label = Label.new()
	_top_label.text = top_text
	_top_label.add_theme_font_size_override("font_size", 30)
	_top_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_top_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_top_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_vbox.add_child(_top_label)
	
	# Bottom label with default size
	_bottom_label = Label.new()
	_bottom_label.text = bottom_text
	_bottom_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_bottom_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_bottom_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_vbox.add_child(_bottom_label)
	
	add_child(_vbox)
	
	# Apply initial styling
	_update_style()

func _get_minimum_size() -> Vector2:
	# This is the correct method to override for minimum size calculation
#	if not _top_label or not _bottom_label:
#		return super._get_minimum_size()
	
	# Calculate size based on label content
	var top_size = _top_label.get_minimum_size()
	var bottom_size = _bottom_label.get_minimum_size()
	
	# Account for separation between labels
	var content_height = top_size.y + bottom_size.y + vertical_separation
	var content_width = max(top_size.x, bottom_size.x)
	
	# Add margins (padding)
	return Vector2(
		content_width + margin_left + margin_right,
		content_height + margin_top + margin_bottom
	)

func _update_style() -> void:
	var style = StyleBoxFlat.new()
	
	# Set colors based on state
	if _is_pressed:
		style.bg_color = Color(0.2, 0.4, 0.8)  # Pressed - blue
	elif _is_hovered:
		style.bg_color = Color(0.4, 0.4, 0.4)  # Hover - lighter gray
	else:
		style.bg_color = Color(0.3, 0.3, 0.3)  # Normal - gray
	
	# Rounded corners
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	
	# Border
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.5, 0.5, 0.5)
	
	# Apply margins as content padding
	style.content_margin_left = margin_left
	style.content_margin_right = margin_right
	style.content_margin_top = margin_top
	style.content_margin_bottom = margin_bottom
	
	add_theme_stylebox_override("panel", style)

# Input handling
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_is_pressed = true
			_update_style()
		elif _is_pressed:
			_is_pressed = false
			_update_style()
			pressed.emit()  # Emit our custom signal

func _on_mouse_entered() -> void:
	_is_hovered = true
	_update_style()
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func _on_mouse_exited() -> void:
	_is_hovered = false
	_is_pressed = false  # Reset pressed state if mouse leaves while pressed
	_update_style()
	mouse_default_cursor_shape = Control.CURSOR_ARROW

# Public method to programmatically trigger a size recalculation
func refresh() -> void:
	queue_redraw()

# Helper method to get current state (useful for debugging)
func get_button_state() -> Dictionary:
	return {
		"hovered": _is_hovered,
		"pressed": _is_pressed,
		"top_text": top_text,
		"bottom_text": bottom_text
	}
