@tool
extends ProgrammaticTheme

var default_font_size = 16

var background_color = Color(0.994, 0.951, 0.878, 1.0)
var btn_color = Color(1.0, 0.43, 0.05, 1.0)
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

	var btn_margin = content_margins(10, 5, 10, 5)
	var btn0 = stylebox_flat({
		bg_color = val(sat(btn_color, -0.6), -0.2),
		corner_ = corner_radius(16, 16, 16, 16),
		content_margin_ = btn_margin,
		border_width = 0
	})
	
	var btn1col = sat(btn_color, -0.6)
	var btn2col = sat(btn_color, -0.4)
	var btn3col = sat(btn_color, -0.2)
	var btn4col = sat(btn_color, -0.0)
	
	var btn1 = inherit(btn0, { bg_color = btn1col })
	var btn2 = inherit(btn0, { bg_color = btn2col })
	var btn3 = inherit(btn0, { bg_color = btn3col })
	var btn4 = inherit(btn0, { bg_color = btn4col })
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
		grabber = btn0,
		grabber_highlight = btn2,
		grabber_pressed = btn3,
		scroll = inherit(btn0, { border_width_ = border_width(8, 8, 8, 8) }),
		scroll_focus = inherit(btn1, { border_width_ = border_width(8, 8, 8, 8) })
	}
	
	var itemlist_style = {
		font_hovered_color = text_color,
		font_hovered_selected_color = text_color,
		font_selected_color = text_color,
		font_color = a(text_color, -0.5),
		
		panel = inherit(panel, { bg_color = val(background_color, -0.05) }),
		selected = stylebox_flat({ bg_color = btn3col }),
		selected_focus = stylebox_flat({ bg_color = btn3col }),
		
		hovered_selected = stylebox_flat({ bg_color = btn4col }),
		hovered_selected_focus = stylebox_flat({ bg_color = btn4col }),
		
		hovered = stylebox_flat({ bg_color = btn2col }),
	}
	
	var fold_style = {
		font_color = text_color,
		collapsed_font_color = text_color,
		hover_font_color = text_color,
		
		panel = panel,
		title_collapsed_hover_panel = inherit(btn2, { content_margins_ = content_margins(5, 15, 5, 15), corner_ = corner_radius(0, 0, 0, 0) }),
		title_collapsed_panel  = inherit(btn1, { content_margins_ = content_margins(5, 15, 5, 15), bg_color = background_color, corner_ = corner_radius(0, 0, 0, 0) }),
		title_hover_panel  = inherit(btn2, { content_margins_ = content_margins(5, 15, 5, 15), corner_ = corner_radius(0, 0, 0, 0) }),
		title_panel  = inherit(btn1, { content_margins_ = content_margins(5, 15, 5, 15), bg_color = background_color, corner_ = corner_radius(0, 0, 0, 0) })
	}
	
	var tab_style = {
		font_hovered_color = text_color,
		font_selected_color = text_color,
		font_unselected_color = text_color,
		
		tab_focus = focus,
		panel = panel,
		tab_disabled = btn0,
		tab_hovered = btn2,
		tab_selected = btn3,
		tab_unselected = btn1
	}
	
	var win_style = {
	}
	
	var popup_panel_style = {
		panel = panel,
	}
	
	define_style("PanelContainer", { panel = panel })
	define_style("Panel", { panel = panel })
	define_style("Label", { font_color = text_color })
	define_style("Button", button_style)
	define_style("CheckBox", checkbox_style)
	define_style("TextEdit", text_edit_style)
	define_style("LineEdit", text_edit_style)
	define_style("HScrollBar", scroll_style)
	define_style("VScrollBar", scroll_style)
	define_style("ItemList", itemlist_style)
	define_style("FoldableContainer", fold_style)
	define_style("TabContainer", tab_style)
	define_style("Window", win_style)
	define_style("PopupPanel", popup_panel_style)
