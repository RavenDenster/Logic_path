@tool
extends ProgrammaticTheme

var default_font_size = 16

var background_color = Color(0.194, 0.194, 0.194, 1.0)
var btn_color = Color(0.553, 0.347, 0.133, 1.0)
var text_color = Color(0.137, 0.137, 0.137, 1.0)

func setup_light_theme():
	set_save_path("res://assets/theme.tres")

func a(col, x):
	return col + Color(0, 0, 0, x)

func sat(col: Color, s):
	col.s += s
	return col

func val(col: Color, v):
	col.v += v
	return col

func define_theme():
	define_default_font_size(default_font_size)
	var font = FontFile.new()
	font.load_dynamic_font("res://assets/fonts/mono.ttf")
	define_default_font(font)
	
	var panel = stylebox_flat({
		bg_color = background_color
	})

	var btn0 = stylebox_flat({
		bg_color = sat(btn_color, -0.8),
		corner_ = corner_radius(16, 16, 16, 16),
		content_margin_ = content_margins(10, 5, 10, 5),
		border_width = 0
	})
	
	var btn1 = inherit(btn0, { bg_color = sat(btn_color, -0.6) })
	var btn2 = inherit(btn0, { bg_color = sat(btn_color, -0.4) })
	var btn3 = inherit(btn0, { bg_color = sat(btn_color, -0.2) })
	var btn4 = inherit(btn0, { bg_color = sat(btn_color, -0.0) })
	var focus = stylebox_flat({
		bg_color = Color(0, 0, 0, 0),
		border_color = sat(val(btn_color, -0.5), -0.5),
		border_width_ = border_width(1, 1, 1, 1),
		corner_ = corner_radius(16, 16, 16, 16)
	})
	
	var button_style = {
		font_color = text_color,
		font_disabled_color = text_color,
		font_focus_color = text_color,
		font_hover_color = text_color,
		font_hover_pressed_color = text_color,
		font_pressed_color = text_color,
		
		disabled = btn0,
		normal = btn1,
		hover = btn2,
		pressed = btn3,
		focus = focus,
	}
	
	var checkbox_style = {
		normal = btn1,
		hover = btn2,
		pressed = btn3,
		hover_pressed = btn4,
	}
	
	var text_edit_style = {
		font_color = text_color,
		caret_color = text_color,
		font_placeholder_color = a(text_color, -0.7),
		
		normal = btn1,
		focus = focus
	}
	
	var scroll_style = {
		grabber = btn1,
		grabber_highlight = btn2,
		grabber_pressed = btn3,
		scroll = inherit(btn0, { border_width_ = border_width(8, 8, 8, 8) }),
		scroll_focus = inherit(btn1, { border_width_ = border_width(8, 8, 8, 8) })
	}
	
	var itemlist_style = {
		font_hovered_color = text_color,
		font_hovered_selected_color = text_color,
		font_outline_color = Color(0, 0, 0, 1),
		font_selected_color = text_color
	}
	
	# define_style("PanelContainer", { panel = panel })
	# define_style("Panel", { panel = panel })
	# define_style("Label", { font_color = text_color })
	# define_style("Button", button_style)
	# define_style("CheckBox", checkbox_style)
	# define_style("TextEdit", text_edit_style)
	# define_style("LineEdit", text_edit_style)
	# define_style("HScrollBar", scroll_style)
	# define_style("VScrollBar", scroll_style)
	# define_style("ItemList", itemlist_style)
