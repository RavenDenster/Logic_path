@tool
extends ProgrammaticTheme

var default_font_size = 16

var background_color = Color(0.133, 0.133, 0.133, 1.0)
var btn_color = Color(0.88, 0.703, 0.537, 0.204)
var text_color = Color(0.227, 0.227, 0.227, 1.0)

func setup_light_theme():
	set_save_path("res://assets/theme.tres")

func a(col, x):
	return col + Color(0, 0, 0, x)

func define_theme():
	define_default_font_size(default_font_size)

	define_style("PanelContainer", {
		panel = stylebox_flat({
			bg_color = background_color
		})
	})
	
	var panel = stylebox_flat({
		bg_color = background_color
	})
	
	define_style("Panel", {
		panel = panel
	})

	var btn = stylebox_flat({
		bg_color = btn_color,
		text_color = text_color,
		corner_ = corner_radius(16, 16, 16, 16),
		content_margin_ = content_margins(10, 5, 10, 5),
		border_width = 0,
	})
	
	var btn0 = inherit(btn, { bg_color = a(btn_color, -0.1) })
	var btn1 = inherit(btn, { bg_color = a(btn_color, 0.1) })
	var btn2 = inherit(btn, { bg_color = a(btn_color, 0.2) })
	var btn3 = inherit(btn, { bg_color = a(btn_color, 0.3) })
	#var focus = stylebox_flat({ border_color = a(btn_color, 1), border_width_ = border_width(1, 1, 1, 1) })
	var focus = stylebox_flat({ border_color = a(btn_color, 1), border_width_ = border_width(0, 0, 0, 0) })
	
	var check_style = inherit(btn, {
		bg_color = Color(0, 0, 0, 0)
	})
	
	var text_ed = stylebox_flat({
		bg_color = btn_color,
		corner_ = corner_radius(16, 16, 16, 16),
		content_margin_ = content_margins(10, 5, 10, 5)
	})
	
	var scroll = stylebox_flat({
		bg_color = btn_color,
		corner_ = corner_radius(8, 8, 8, 8)
	})

	define_style("Button", {
		normal = btn,
		hover = btn1,
		pressed = btn2,
		disabled = btn0,
		focus = merge(btn0, focus)
	})
	
	define_style("CheckBox", {
		pressed = check_style,
		normal = check_style,
		hover = inherit(check_style, { bg_color = a(btn_color, -0.1) }),
		hover_pressed = inherit(check_style, { bg_color = a(btn_color, -0.1) }),
	})
	
	define_style("TextEdit", {
		normal = text_ed,
		focus = inherit(text_ed, { bg_color = a(btn_color, 0.1) })
	})
	
	define_style("LineEdit", {
		normal = text_ed,
		read_only = inherit(text_ed, { bg_color = a(btn_color, -0.1) }),
		focus = inherit(text_ed, { bg_color = a(btn_color, 0.1) })
	})
	
	var all_scroll = {
		grabber = scroll,
		grabber_highlight = inherit(scroll, { bg_color = a(btn_color, 0.1) }),
		grabber_pressed = inherit(scroll, { bg_color = a(btn_color, 0.2) })
	}
	
	define_style("HScrollBar", all_scroll)
	define_style("VScrollBar", all_scroll)
	
	define_style("ItemList", {
		cursor = merge(btn, focus),
		cursor_unfocused = btn1,
		focus = merge(check_style, focus),
		hovered = btn2,
		hovered_selected = btn3,
		hovered_selected_focus = merge(btn3, focus),
		panel = panel,
		selected = scroll,
		selected_focus = merge(scroll, focus)
	})
