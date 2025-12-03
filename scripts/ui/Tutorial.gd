extends Node2D

enum TutorialStep {
	INTRODUCTION,
	TOP_PANEL_EXPLANATION,
	BOTTOM_PANEL_EXPLANATION,
	INPUT_BLOCK_EXPLANATION,
	OUTPUT_BLOCK_EXPLANATION,
	CONNECTION_EXPLANATION,
	PRACTICE_CONNECTION,
	COMPLETION
}

var current_step = TutorialStep.INTRODUCTION
var tutorial_popup: Window
var next_button: Button
var tutorial_text: RichTextLabel
var current_wire = null
var wire_created = false
var wires = []
var temp_line: Line2D
var start_port = null
var drawing_wire = false
var input_block = null
var output_block = null
var top_panel = null
var test_panel = null
var practice_started = false

# Данные для обучалки
var tutorial_data = {
	"level_name": "Tutorial",
	"input_values_a": [0, 0, 1, 1],
	"input_values_b": [0, 1, 0, 1],
	"expected_output": [0, 1, 1, 1]
}

func _ready():
	# Создаем все элементы обучалки
	create_background()
	create_input_block()
	create_output_block()
	create_top_panel()
	create_test_panel()
	
	# Создаем всплывающее окно для обучалки
	create_tutorial_popup()
	
	# Инициализируем временную линию для провода
	temp_line = Line2D.new()
	add_child(temp_line)
	temp_line.default_color = Color("#e39e45")
	temp_line.width = 8
	temp_line.points = []
	
	# Устанавливаем стиль для окна
	setup_popup_style()
	
	# Запускаем первый шаг
	start_step(current_step)

func setup_popup_style():
	# Ждем один кадр, чтобы окно создалось
	await get_tree().process_frame
	
	# Создаем стиль для окна
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.1, 0.15, 0.95)
	panel_style.border_color = Color(0.4, 0.4, 0.5)
	panel_style.border_width_left = 4
	panel_style.border_width_top = 4
	panel_style.border_width_right = 4
	panel_style.border_width_bottom = 4
	panel_style.corner_radius_top_left = 12
	panel_style.corner_radius_top_right = 12
	panel_style.corner_radius_bottom_left = 12
	panel_style.corner_radius_bottom_right = 12
	
	# Применяем стиль к окну
	if tutorial_popup:
		tutorial_popup.add_theme_stylebox_override("panel", panel_style)
		
		# Также устанавливаем стиль для заголовка окна
		tutorial_popup.add_theme_color_override("title_color", Color(0.9, 0.9, 1.0))
		tutorial_popup.add_theme_font_size_override("title_font_size", 16)


func create_background():
	# Создаем CanvasLayer для фона
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = -100
	add_child(canvas_layer)
	
	# Создаем фон
	var background = TextureRect.new()
	background.name = "Background"
	
	# Пробуем загрузить текстуру
	var texture = load("res://assets/wide_spacing_waves_4k.png")
	if texture:
		background.texture = texture
		background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		background.stretch_mode = TextureRect.STRETCH_SCALE
	else:
		# Если текстура не найдена, используем цветной фон
		background.texture = null
		var color_rect = ColorRect.new()
		color_rect.color = Color(0.1, 0.1, 0.15)
		color_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		background.add_child(color_rect)
	
	# Настраиваем анкоры для полного покрытия
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	canvas_layer.add_child(background)

func create_input_block():
	# Загружаем и создаем InputBlock
	var input_block_scene = load("res://scenes/components/InputBlock2.tscn")
	if input_block_scene:
		input_block = input_block_scene.instantiate()
		input_block.position = Vector2(400, 400)
		
		# Устанавливаем данные для InputBlock
		if input_block.has_method("set_values"):
			input_block.set_values(tutorial_data["input_values_a"], tutorial_data["input_values_b"])
		elif "values_A" in input_block:
			input_block.values_A = tutorial_data["input_values_a"]
			input_block.values_B = tutorial_data["input_values_b"]
		
		# Исправляем позиции портов, чтобы они совпадали с фактическими позициями кружков
		var outputA = input_block.get_node_or_null("OutputA")
		if outputA:
			# Фактическая позиция кружка OutputA
			outputA.position = Vector2(-50, 0)  # Левый порт
			var collision_shape = outputA.get_node_or_null("CollisionShape2D")
			if collision_shape:
				collision_shape.position = Vector2(74, -29)
			var sprite = outputA.get_node_or_null("Sprite2D")
			if sprite:
				sprite.position = Vector2(76, -31)
		
		var outputB = input_block.get_node_or_null("OutputB")
		if outputB:
			# Фактическая позиция кружка OutputB
			outputB.position = Vector2(50, 0)  # Правый порт
			var collision_shape = outputB.get_node_or_null("CollisionShape2D")
			if collision_shape:
				collision_shape.position = Vector2(-25, 27)
			var sprite = outputB.get_node_or_null("Sprite2D")
			if sprite:
				sprite.position = Vector2(-24, 27)
		
		# Устанавливаем collision_layer для портов
		for port_name in ["OutputA", "OutputB"]:
			var port = input_block.get_node_or_null(port_name)
			if port:
				port.collision_layer = 1
				port.collision_mask = 1
		
		add_child(input_block)
		print("InputBlock created at position: ", input_block.position)
	else:
		print("ERROR: Could not load InputBlock2 scene")
		# Создаем заглушку
		input_block = Node2D.new()
		input_block.position = Vector2(400, 400)
		add_child(input_block)

func create_output_block():
	# Загружаем и создаем OutputBlock
	var output_block_scene = load("res://scenes/components/OutputBlock.tscn")
	if output_block_scene:
		output_block = output_block_scene.instantiate()
		output_block.position = Vector2(800, 400)
		
		# Устанавливаем ожидаемые выходы
		if "expected" in output_block:
			output_block.expected = tutorial_data["expected_output"]
		elif output_block.has_method("set_expected"):
			output_block.set_expected(tutorial_data["expected_output"])
		
		# Настраиваем для обучалки
		if "output_type" in output_block:
			output_block.output_type = "DEFAULT"
		
		# Исправляем позицию порта InputPort
		var input_port = output_block.get_node_or_null("InputPort")
		if input_port:
			# Фактическая позиция кружка InputPort
			input_port.position = Vector2(0, 0)  # Центральный порт
			var collision_shape = input_port.get_node_or_null("CollisionShape2D")
			if collision_shape:
				collision_shape.position = Vector2(-30, 0)
			var sprite = input_port.get_node_or_null("Sprite2D")
			if sprite:
				sprite.position = Vector2(-29, -1)
				sprite.scale = Vector2(0.9268293, 0.9268293)
		
		# Устанавливаем collision_layer для порта
		if input_port:
			input_port.collision_layer = 1
			input_port.collision_mask = 1
		
		add_child(output_block)
		print("OutputBlock created at position: ", output_block.position)
	else:
		print("ERROR: Could not load OutputBlock scene")
		# Создаем заглушку
		output_block = Node2D.new()
		output_block.position = Vector2(800, 400)
		add_child(output_block)

func create_top_panel():
	# Загружаем и создаем TopPanel
	var top_panel_scene = load("res://scenes/ui/TopPanel.tscn")
	if top_panel_scene:
		top_panel = top_panel_scene.instantiate()
		
		# Настраиваем для обучалки
		if top_panel.has_method("set_level_name"):
			top_panel.set_level_name(tutorial_data["level_name"])
		
		if top_panel.has_method("set_theory_text"):
			top_panel.set_theory_text(
				"[b]Logic Path Tutorial[/b]\n\n" +
				"Welcome to the tutorial! Here you'll learn the basics of creating logic circuits.\n\n" +
				"[b]What you'll learn:[/b]\n" +
				"• Understanding the interface\n" +
				"• Working with input and output blocks\n" +
				"• Creating connections between components\n" +
				"• Basic logic circuit principles"
			)
		
		add_child(top_panel)
		print("TopPanel created")
		
		# Настраиваем кнопки для обучалки
		setup_top_panel_buttons()
	else:
		print("ERROR: Could not load TopPanel scene")
		# Создаем заглушку
		top_panel = Control.new()
		add_child(top_panel)

func setup_top_panel_buttons():
	# Находим кнопки в TopPanel
	if not top_panel:
		return
	
	var menu_button = top_panel.get_node_or_null("MainContainer/LeftSection/MenuButton")
	var map_button = top_panel.get_node_or_null("MainContainer/LeftSection/MapButton")
	var run_button = top_panel.get_node_or_null("MainContainer/LeftSection/RunButton")
	
	# Отключаем кнопки, которые не используются в обучалке
	if map_button:
		map_button.disabled = true
		map_button.modulate = Color(1, 1, 1, 0.5)
	
	if run_button:
		run_button.disabled = true
		run_button.modulate = Color(1, 1, 1, 0.5)
	
	# Настраиваем кнопку меню - упрощенный подход
	if menu_button:
		# Отключаем старые соединения безопасно
		var connections = menu_button.pressed.get_connections()
		for connection in connections:
			menu_button.pressed.disconnect(connection["callable"])
		
		# Подключаем нашу функцию
		menu_button.pressed.connect(_on_tutorial_menu_pressed)
	
	# Скрываем кнопки ворот
	var gate_buttons_container = top_panel.get_node_or_null("MainContainer/RightSection/GateButtonsContainer")
	if gate_buttons_container:
		for child in gate_buttons_container.get_children():
			child.visible = false

func _on_tutorial_menu_pressed():
	# Возврат в главное меню
	print("Returning to Main Menu from tutorial")
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")

func create_test_panel():
	# Загружаем и создаем TestResultsPanel
	var test_panel_scene = load("res://scenes/ui/bottom_panels/BottonPanelBaseLE.tscn")
	if test_panel_scene:
		test_panel = test_panel_scene.instantiate()
		
		# Настраиваем позицию (нижняя часть экрана)
		test_panel.anchor_left = 0.0
		test_panel.anchor_right = 1.0
		test_panel.anchor_top = 1.0
		test_panel.anchor_bottom = 1.0
		
		var viewport_size = get_viewport_rect().size
		test_panel.position = Vector2(0, viewport_size.y - 160)
		test_panel.size = Vector2(viewport_size.x, 160)
		
		add_child(test_panel)
		
		# Ждем один кадр для инициализации
		await get_tree().process_frame
		
		# Загружаем тестовые данные
		if test_panel.has_method("load_initial_data"):
			test_panel.load_initial_data(
				tutorial_data["input_values_a"],
				tutorial_data["input_values_b"],
				tutorial_data["expected_output"]
			)
			print("TestPanel data loaded")
		else:
			print("TestPanel doesn't have 'load_initial_data' method")
	else:
		print("ERROR: Could not load TestResultsPanel scene")
		# Создаем заглушку
		test_panel = Control.new()
		test_panel.size = Vector2(1920, 160)
		test_panel.position = Vector2(0, 920)
		add_child(test_panel)

func create_tutorial_popup():
	# Создаем всплывающее окно
	tutorial_popup = Window.new()
	tutorial_popup.title = "Logic Path Tutorial"
	tutorial_popup.size = Vector2(700, 400)
	tutorial_popup.unresizable = true
	tutorial_popup.exclusive = true
	
	# Делаем окно модальным
	tutorial_popup.popup_window = true
	
	# Создаем основной контейнер с отступами
	var main_container = MarginContainer.new()
	main_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_container.add_theme_constant_override("margin_left", 20)
	main_container.add_theme_constant_override("margin_right", 20)
	main_container.add_theme_constant_override("margin_top", 20)
	main_container.add_theme_constant_override("margin_bottom", 20)
	
	# Создаем VBoxContainer для организации элементов
	var vbox = VBoxContainer.new()
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# Текст обучалки
	tutorial_text = RichTextLabel.new()
	tutorial_text.bbcode_enabled = true
	tutorial_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tutorial_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tutorial_text.scroll_active = true
	tutorial_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tutorial_text.fit_content = false
	tutorial_text.scroll_following = true
	tutorial_text.custom_minimum_size = Vector2(0, 300)  # Минимальная высота для текста
	
	# Устанавливаем отступы для текста
	tutorial_text.add_theme_constant_override("margin_left", 10)
	tutorial_text.add_theme_constant_override("margin_right", 10)
	tutorial_text.add_theme_constant_override("margin_top", 10)
	tutorial_text.add_theme_constant_override("margin_bottom", 10)
	
	# Создаем стиль для RichTextLabel
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = Color(0.1, 0.1, 0.15, 0.9)
	stylebox.border_color = Color(0.3, 0.3, 0.4)
	stylebox.border_width_left = 2
	stylebox.border_width_top = 2
	stylebox.border_width_right = 2
	stylebox.border_width_bottom = 2
	stylebox.corner_radius_top_left = 8
	stylebox.corner_radius_top_right = 8
	stylebox.corner_radius_bottom_left = 8
	stylebox.corner_radius_bottom_right = 8
	stylebox.content_margin_left = 10
	stylebox.content_margin_top = 10
	stylebox.content_margin_right = 10
	stylebox.content_margin_bottom = 10
	tutorial_text.add_theme_stylebox_override("normal", stylebox)
	
	# Контейнер для кнопки
	var button_container = HBoxContainer.new()
	button_container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button_container.size_flags_vertical = Control.SIZE_SHRINK_END
	button_container.add_spacer(false)
	
	# Кнопка "Далее"
	next_button = Button.new()
	next_button.text = "Next"
	next_button.custom_minimum_size = Vector2(120, 40)
	next_button.pressed.connect(_on_next_button_pressed)
	
	# Добавляем отступы для кнопки
	next_button.add_theme_constant_override("margin_left", 10)
	next_button.add_theme_constant_override("margin_right", 10)
	next_button.add_theme_constant_override("margin_top", 10)
	next_button.add_theme_constant_override("margin_bottom", 10)
	
	# Компоновка
	button_container.add_child(next_button)
	vbox.add_child(tutorial_text)
	vbox.add_spacer(false)  # Добавляем разделитель
	vbox.add_child(button_container)
	
	main_container.add_child(vbox)
	tutorial_popup.add_child(main_container)
	add_child(tutorial_popup)
	
	# Сначала скрываем окно
	tutorial_popup.visible = false

func show_tutorial_popup(text: String):
	tutorial_text.text = text
	tutorial_popup.visible = true
	
	# Позиционируем окно по центру
	var viewport_size = get_viewport_rect().size
	tutorial_popup.position = Vector2(
		(viewport_size.x - tutorial_popup.size.x) / 2,
		(viewport_size.y - tutorial_popup.size.y) / 3
	)
	
	# Делаем окно поверх всех
	tutorial_popup.always_on_top = true
	tutorial_popup.popup_centered()

func _on_next_button_pressed():
	# Сначала скрываем окно при нажатии "Next"
	tutorial_popup.visible = false
	
	match current_step:
		TutorialStep.PRACTICE_CONNECTION:
			# В режиме практики мы просто скрываем окно, но остаемся в этом же шаге
			practice_started = true
			print("Practice mode started - window closed, waiting for connection")
		TutorialStep.COMPLETION:
			# Возвращаемся в главное меню
			get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
		_:
			# Переходим к следующему шагу
			current_step += 1
			start_step(current_step)

func start_step(step):
	current_step = step
	practice_started = false
	
	# Удаляем инструкцию с экрана, если она есть
	if has_node("OnScreenInstruction"):
		get_node("OnScreenInstruction").queue_free()
	
	match step:
		TutorialStep.INTRODUCTION:
			show_tutorial_popup(
				"[b]Welcome to Logic Path Tutorial![/b]\n\n" +
				"In this tutorial, you'll learn the basics of the game interface " +
				"and how to create logic circuits.\n\n" +
				"You'll learn about:\n" +
				"• Top Panel controls\n" +
				"• Bottom Panel information\n" +
				"• Input and Output blocks\n" +
				"• How to connect components\n\n" +
				"Click 'Next' to continue."
			)
		
		TutorialStep.TOP_PANEL_EXPLANATION:
			highlight_top_panel()
			show_tutorial_popup(
				"[b]Top Panel[/b]\n\n" +
				"This is the main control panel. It contains:\n\n" +
				"[color=yellow]• Menu Button[/color]: Returns to main menu\n" +
				"[color=yellow]• Map Button[/color]: Opens level map\n" +
				"[color=yellow]• Theory Button[/color]: Shows circuit theory\n" +
				"[color=yellow]• Run Button[/color]: Tests your circuit\n" +
				"[color=yellow]• Gate Buttons[/color]: Adds logic gates to circuit\n\n" +
				"In this tutorial, only the Menu button is active.\n" +
				"Click 'Next' to learn about the bottom panel."
			)
		
		TutorialStep.BOTTOM_PANEL_EXPLANATION:
			highlight_bottom_panel()
			show_tutorial_popup(
				"[b]Bottom Panel - Test Results[/b]\n\n" +
				"This panel shows the truth table and test results:\n\n" +
				"[color=cyan]• Input A/B[/color]: Input values for each test case\n" +
				"[color=cyan]• Desired Output[/color]: Expected correct values\n" +
				"[color=cyan]• Current Output[/color]: Your circuit's actual output\n\n" +
				"When you press 'Run' in regular levels, it compares your outputs with expected ones.\n" +
				"Click 'Next' to learn about Input Block."
			)
		
		TutorialStep.INPUT_BLOCK_EXPLANATION:
			highlight_input_block()
			show_tutorial_popup(
				"[b]Input Block[/b]\n\n" +
				"This block generates input signals for your circuit.\n\n" +
				"Features:\n" +
				"• Has two output ports (A and B)\n" +
				"• Generates all possible input combinations (00, 01, 10, 11)\n" +
				"• Green dot indicates '1' signal, gray dot indicates '0'\n\n" +
				"Hover your mouse over the Input Block to see its ports highlight in the bottom panel.\n" +
				"Click 'Next' to learn about Output Block."
			)
		
		TutorialStep.OUTPUT_BLOCK_EXPLANATION:
			highlight_output_block()
			show_tutorial_popup(
				"[b]Output Block[/b]\n\n" +
				"This block displays the final result of your circuit.\n\n" +
				"Features:\n" +
				"• Has one input port\n" +
				"• Shows whether circuit output is correct\n" +
				"• Turns green when all tests pass\n\n" +
				"Hover your mouse over the Output Block to see desired values in the bottom panel.\n" +
				"Click 'Next' to learn how to connect blocks."
			)
		
		TutorialStep.CONNECTION_EXPLANATION:
			highlight_connection()
			show_tutorial_popup(
				"[b]Creating Connections[/b]\n\n" +
				"To connect components:\n\n" +
				"1. [color=yellow]LEFT CLICK[/color] on an output port (like Input Block's A or B)\n" +
				"2. Drag to an input port (like Output Block's Input)\n" +
				"3. Release to create the wire\n\n" +
				"To delete connections:\n\n" +
				"1. [color=yellow]RIGHT CLICK[/color] on a wire to remove it\n" +
				"2. [color=yellow]RIGHT CLICK[/color] on a gate to delete it (not available in tutorial)\n\n" +
				"Click 'Next' to practice connecting blocks."
			)
		
		TutorialStep.PRACTICE_CONNECTION:
			wire_created = false
			practice_started = false
			# Сначала сбрасываем все провода
			for wire in wires:
				if is_instance_valid(wire):
					wire.queue_free()
			wires.clear()
			reset_port_sprites()
			
			# Показываем окно с инструкцией для практики
			show_tutorial_popup(
				"[b]Practice: Create a Connection[/b]\n\n" +
				"Your task:\n\n" +
				"1. Connect Input Block's [color=yellow]Output A[/color] to Output Block's [color=yellow]Input[/color]\n" +
				"2. Use LEFT CLICK and drag to create the wire\n" +
				"3. The tutorial will continue automatically when you succeed\n\n" +
				"Hint: Click on the green dot on Input Block and drag to Output Block.\n\n" +
				"Click 'Next' to start practicing."
			)
			next_button.text = "Start Practice"
		
		TutorialStep.COMPLETION:
			show_tutorial_popup(
				"[b]Congratulations![/b] 🎉\n\n" +
				"You've completed the tutorial!\n\n" +
				"You've learned:\n" +
				"✓ How to navigate the interface\n" +
				"✓ How Input and Output blocks work\n" +
				"✓ How to create connections between components\n\n" +
				"You're now ready to start playing Logic Path!\n\n" +
				"Press 'Finish' to return to Main Menu."
			)
			next_button.text = "Finish"

func show_on_screen_instruction(text: String):
	# Удаляем предыдущую инструкцию, если она есть
	if has_node("OnScreenInstruction"):
		get_node("OnScreenInstruction").queue_free()
	
	# Создаем панель с инструкцией
	var instruction_panel = PanelContainer.new()
	instruction_panel.name = "OnScreenInstruction"
	
	# Настраиваем стиль
	instruction_panel.add_theme_stylebox_override("panel", StyleBoxFlat.new())
	var stylebox = instruction_panel.get_theme_stylebox("panel")
	if stylebox is StyleBoxFlat:
		stylebox.bg_color = Color(0, 0, 0, 0.8)
		stylebox.border_color = Color.YELLOW
		stylebox.border_width_left = 4
		stylebox.border_width_top = 4
		stylebox.border_width_right = 4
		stylebox.border_width_bottom = 4
		stylebox.corner_radius_top_left = 10
		stylebox.corner_radius_top_right = 10
		stylebox.corner_radius_bottom_left = 10
		stylebox.corner_radius_bottom_right = 10
	
	# Создаем контейнер
	var container = VBoxContainer.new()
	container.add_theme_constant_override("margin_left", 20)
	container.add_theme_constant_override("margin_right", 20)
	container.add_theme_constant_override("margin_top", 20)
	container.add_theme_constant_override("margin_bottom", 20)
	
	# Создаем текст
	var instruction_label = RichTextLabel.new()
	instruction_label.bbcode_enabled = true
	instruction_label.text = "[center][b]" + text + "[/b][/center]"
	instruction_label.fit_content = false
	instruction_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	instruction_label.custom_minimum_size = Vector2(600, 200)
	
	# Добавляем элементы
	container.add_child(instruction_label)
	instruction_panel.add_child(container)
	add_child(instruction_panel)
	
	# Позиционируем панель
	var viewport_size = get_viewport_rect().size
	instruction_panel.position = Vector2(
		(viewport_size.x - 600) / 2,
		50
	)
	instruction_panel.size = Vector2(600, 200)

func highlight_top_panel():
	if not top_panel:
		return
	
	# Создаем подсветку для верхней панели
	var highlight = ColorRect.new()
	highlight.name = "TopPanelHighlight"
	highlight.color = Color(1, 1, 0, 0.3)
	highlight.size = top_panel.size
	highlight.position = top_panel.position
	add_child(highlight)
	
	# Удаляем через 5 секунд
	await get_tree().create_timer(5.0).timeout
	if has_node("TopPanelHighlight"):
		get_node("TopPanelHighlight").queue_free()

func highlight_bottom_panel():
	if not test_panel:
		return
	
	# Создаем подсветку для нижней панели
	var highlight = ColorRect.new()
	highlight.name = "BottomPanelHighlight"
	highlight.color = Color(0, 1, 1, 0.3)
	highlight.size = test_panel.size
	highlight.position = test_panel.position
	add_child(highlight)
	
	# Удаляем через 5 секунд
	await get_tree().create_timer(5.0).timeout
	if has_node("BottomPanelHighlight"):
		get_node("BottomPanelHighlight").queue_free()

func highlight_input_block():
	if not input_block:
		return
	
	# Подсвечиваем Input Block
	var highlight = ColorRect.new()
	highlight.name = "InputBlockHighlight"
	highlight.color = Color(0, 1, 0, 0.3)
	highlight.size = Vector2(150, 150)
	highlight.position = input_block.position - Vector2(75, 75)
	add_child(highlight)
	
	# Удаляем через 5 секунд
	await get_tree().create_timer(5.0).timeout
	if has_node("InputBlockHighlight"):
		get_node("InputBlockHighlight").queue_free()

func highlight_output_block():
	if not output_block:
		return
	
	# Подсвечиваем Output Block
	var highlight = ColorRect.new()
	highlight.name = "OutputBlockHighlight"
	highlight.color = Color(1, 0, 0, 0.3)
	highlight.size = Vector2(150, 150)
	highlight.position = output_block.position - Vector2(75, 75)
	add_child(highlight)
	
	# Удаляем через 5 секунд
	await get_tree().create_timer(5.0).timeout
	if has_node("OutputBlockHighlight"):
		get_node("OutputBlockHighlight").queue_free()

func highlight_connection():
	if not input_block or not output_block:
		return
	
	# Показываем анимацию соединения
	var line = Line2D.new()
	line.name = "ConnectionDemo"
	line.default_color = Color(1, 1, 0, 0.8)
	line.width = 5
	
	# Определяем позиции портов - используем реальные позиции портов
	var start_port = input_block.get_node_or_null("OutputA")
	var end_port = output_block.get_node_or_null("InputPort")
	
	var start_pos = Vector2()
	var end_pos = Vector2()
	
	if start_port:
		var sprite = start_port.get_node_or_null("Sprite2D")
		if sprite and is_instance_valid(sprite):
			start_pos = start_port.global_position + sprite.position
		else:
			start_pos = input_block.global_position + Vector2(-50, 0) + Vector2(76, -31)
	else:
		start_pos = input_block.global_position + Vector2(26, -31)  # (400-50+76=426, 400+0-31=369) -> (426-400=26, 369-400=-31)
	
	if end_port:
		var sprite = end_port.get_node_or_null("Sprite2D")
		if sprite and is_instance_valid(sprite):
			end_pos = end_port.global_position + sprite.position
		else:
			end_pos = output_block.global_position + Vector2(-29, -1)
	else:
		end_pos = output_block.global_position + Vector2(-29, -1)
	
	print("Connection demo: Start pos = ", start_pos, ", End pos = ", end_pos)
	
	line.points = [start_pos, end_pos]
	add_child(line)
	
	# Мигающая анимация
	var tween = create_tween()
	tween.set_loops(4)
	tween.tween_property(line, "default_color:a", 0.2, 0.5)
	tween.tween_property(line, "default_color:a", 0.8, 0.5)
	
	await tween.finished
	if has_node("ConnectionDemo"):
		get_node("ConnectionDemo").queue_free()
	
func check_wire_connection():
	# Проверяем, есть ли соединение между Input Block и Output Block
	for wire in wires:
		if wire and is_instance_valid(wire):
			# Получаем родительские объекты портов
			var start_parent = null
			var end_parent = null
			
			if "start_port" in wire and wire.start_port and is_instance_valid(wire.start_port):
				start_parent = wire.start_port.get_parent()
			if "end_port" in wire and wire.end_port and is_instance_valid(wire.end_port):
				end_parent = wire.end_port.get_parent()
			
			# Проверяем прямое соединение InputBlock -> OutputBlock
			if start_parent == input_block and end_parent == output_block:
				# Проверяем, что соединен правильный порт (OutputA)
				if "start_port" in wire and wire.start_port:
					var port_name = wire.start_port.name
					if port_name == "OutputA":
						return true
			
			# Проверяем обратное соединение OutputBlock -> InputBlock (если игрок перепутал)
			if end_parent == input_block and start_parent == output_block:
				# Проверяем, что соединен правильный порт (OutputA)
				if "end_port" in wire and wire.end_port:
					var port_name = wire.end_port.name
					if port_name == "OutputA":
						return true
	
	return false

func get_port_under_mouse():
	var mouse_pos = get_global_mouse_position()
	
	# Проверяем порты InputBlock
	if input_block and is_instance_valid(input_block):
		for port_name in ["OutputA", "OutputB"]:
			var port = input_block.get_node_or_null(port_name)
			if port and is_instance_valid(port):
				# Получаем позицию спрайта порта
				var sprite = port.get_node_or_null("Sprite2D")
				if sprite and is_instance_valid(sprite):
					var port_pos = port.global_position + sprite.position
					var distance = port_pos.distance_to(mouse_pos)
					if distance < 30:  # Увеличиваем радиус для лучшего определения
						print("Found InputBlock port: ", port_name, " at distance: ", distance, " pos: ", port_pos)
						return port
	
	# Проверяем порты OutputBlock
	if output_block and is_instance_valid(output_block):
		var input_port = output_block.get_node_or_null("InputPort")
		if input_port and is_instance_valid(input_port):
			# Получаем позицию спрайта порта
			var sprite = input_port.get_node_or_null("Sprite2D")
			if sprite and is_instance_valid(sprite):
				var port_pos = input_port.global_position + sprite.position
				var distance = port_pos.distance_to(mouse_pos)
				if distance < 30:
					print("Found OutputBlock input port at distance: ", distance, " pos: ", port_pos)
					return input_port
	
	return null

func _input(event):
	# Проверяем, что узел находится в дереве сцены
	if not is_inside_tree():
		return
	
	# Если окно tutorial_popup видимо, то мы не должны обрабатывать ввод для проводов
	if tutorial_popup and tutorial_popup.visible:
		return
	
	# Обработка создания проводов - ТОЛЬКО когда practice_started = true и текущий шаг - PRACTICE_CONNECTION
	if current_step != TutorialStep.PRACTICE_CONNECTION or not practice_started:
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var port = get_port_under_mouse()
			if port and is_instance_valid(port):
				drawing_wire = true
				start_port = port
				var sprite = port.get_node_or_null("Sprite2D")
				var port_pos = port.global_position
				if sprite and is_instance_valid(sprite):
					port_pos += sprite.position
				print("Started drawing wire from port: ", port.name, " at position: ", port_pos)
		else:
			if drawing_wire and start_port and is_instance_valid(start_port):
				var end_port = get_port_under_mouse()
				if end_port and is_instance_valid(end_port) and end_port != start_port:
					# Проверяем, что порты не принадлежат одному и тому же объекту
					var start_parent = start_port.get_parent()
					var end_parent = end_port.get_parent()
					
					if start_parent != end_parent:
						# Проверяем, нет ли уже провода между этими портами
						var wire_exists = false
						for wire in wires:
							if not wire or not is_instance_valid(wire):
								continue
								
							var wire_start = wire.start_port if "start_port" in wire else null
							var wire_end = wire.end_port if "end_port" in wire else null
							
							if (wire_start == start_port and wire_end == end_port) or (wire_start == end_port and wire_end == start_port):
								wire_exists = true
								break
						
						if not wire_exists:
							# Создаем провод
							create_wire(start_port, end_port)
							
							# Сразу же сбрасываем состояние рисования
							drawing_wire = false
							start_port = null
							
							# Проверяем, выполнен ли учебный шаг
							if current_step == TutorialStep.PRACTICE_CONNECTION and practice_started:
								if check_wire_connection():
									# Показываем сообщение об успехе
									show_success_message()
									# Ждем 2 секунды, чтобы игрок увидел сообщение
									await get_tree().create_timer(2.0).timeout
									# Переходим к следующему шагу
									current_step = TutorialStep.COMPLETION
									start_step(current_step)
								else:
									# Если соединение неправильное, показываем подсказку
									# Удаляем предыдущие сообщения подсказок перед созданием нового
									if has_node("HintMessage"):
										var hint_node = get_node("HintMessage")
										if is_instance_valid(hint_node):
											hint_node.queue_free()
									show_hint_message("Try connecting Output A to Input port")
				
				# Если мы не создали провод (например, отпустили кнопку не на порте)
				# или создали неправильное соединение, сбрасываем состояние
				if drawing_wire:
					drawing_wire = false
					start_port = null
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		var mouse_pos = get_global_mouse_position()
		
		# Проверяем, кликнули ли по проводу для удаления
		for i in range(wires.size() - 1, -1, -1):
			var wire = wires[i]
			if not wire or not is_instance_valid(wire):
				wires.remove_at(i)
				continue
				
			# Получаем точки провода
			var wire_points = []
			if wire.has_method("get_points"):
				wire_points = wire.get_points()
			elif "points" in wire:
				wire_points = wire.points
			
			if wire_points.size() >= 2:
				var closest_point = get_closest_point_on_line(wire_points, mouse_pos)
				if closest_point.distance_to(mouse_pos) < 15:
					remove_wire(wire)
					# Если удалили провод во время практики, сбрасываем состояние
					if current_step == TutorialStep.PRACTICE_CONNECTION and practice_started:
						print("Wire removed during practice")
					break
				
func show_hint_message(text):
	# Проверяем, что узел находится в дереве сцены
	if not is_inside_tree():
		return
	
	# Удаляем предыдущие сообщения подсказок
	if has_node("HintMessage"):
		var hint_node = get_node("HintMessage")
		if is_instance_valid(hint_node):
			hint_node.queue_free()
			await get_tree().process_frame  # Ждем один кадр для безопасного удаления
	
	var message = Label.new()
	message.name = "HintMessage"
	message.text = text
	
	# Создаем стиль для сообщения
	message.add_theme_color_override("font_color", Color.YELLOW)
	message.add_theme_font_size_override("font_size", 24)
	
	var viewport_size = get_viewport_rect().size
	message.position = Vector2(viewport_size.x / 2 - 150, 150)
	
	add_child(message)
	
	# Анимация появления
	message.modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.tween_property(message, "modulate", Color(1, 1, 1, 1), 0.5)
	
	# Удаляем сообщение через 3 секунды
	await get_tree().create_timer(3.0).timeout
	
	# Проверяем, что сообщение все еще существует и находится в дереве
	if not is_instance_valid(message) or not message.is_inside_tree():
		return
	
	# Анимация исчезновения
	tween = create_tween()
	tween.tween_property(message, "modulate", Color(1, 1, 1, 0), 0.5)
	await tween.finished
	
	# Еще раз проверяем перед удалением
	if is_instance_valid(message) and message.is_inside_tree():
		message.queue_free()
	
func create_wire(start_port, end_port):
	var wire_scene = load("res://scenes/components/Wire.tscn")
	if wire_scene:
		var wire = wire_scene.instantiate()
		
		# Проверяем, какой метод доступен
		if wire.has_method("connect_ports"):
			wire.connect_ports(start_port, end_port)
		else:
			# Альтернативная реализация
			wire.start_port = start_port
			wire.end_port = end_port
		
		add_child(wire)
		wires.append(wire)
		
		# Обновляем цвета портов
		update_port_colors()
		
		print("Wire created in tutorial:")
		print("  Start port: ", start_port.name if start_port else "null")
		print("  End port: ", end_port.name if end_port else "null")
		
		return wire
	
	print("Failed to create wire: wire_scene not loaded")
	return null

func get_closest_point_on_line(points, target_point):
	if points.size() == 0:
		return target_point
	
	var closest_point = points[0]
	var min_distance = target_point.distance_to(points[0])
	
	for i in range(points.size() - 1):
		var segment_start = points[i]
		var segment_end = points[i + 1]
		var closest_on_segment = get_closest_point_on_segment(segment_start, segment_end, target_point)
		var distance = target_point.distance_to(closest_on_segment)
		if distance < min_distance:
			min_distance = distance
			closest_point = closest_on_segment
	
	return closest_point

func get_closest_point_on_segment(a, b, p):
	var ab = b - a
	var ap = p - a
	var ab_length_squared = ab.length_squared()
	
	if ab_length_squared == 0:
		return a
	
	var t = ap.dot(ab) / ab_length_squared
	t = clamp(t, 0.0, 1.0)
	
	return a + ab * t

func remove_wire(wire):
	if wire in wires:
		wires.erase(wire)
	if is_instance_valid(wire):
		wire.queue_free()
	
	update_port_colors()
	print("Wire removed in tutorial")

func update_port_colors():
	# Сбрасываем все порты к стандартному цвету
	reset_port_sprites()
	
	# Устанавливаем зеленый цвет для подключенных портов
	for wire in wires:
		if not wire or not is_instance_valid(wire):
			continue
		
		# Получаем порты
		var start_port = null
		var end_port = null
		
		if "start_port" in wire:
			start_port = wire.start_port
		if "end_port" in wire:
			end_port = wire.end_port
		
		# Обновляем спрайты портов
		if start_port and is_instance_valid(start_port):
			var start_sprite = start_port.get_node_or_null("Sprite2D")
			if start_sprite and is_instance_valid(start_sprite):
				start_sprite.texture = preload("res://assets/pointGreen.png")
		
		if end_port and is_instance_valid(end_port):
			var end_sprite = end_port.get_node_or_null("Sprite2D")
			if end_sprite and is_instance_valid(end_sprite):
				end_sprite.texture = preload("res://assets/pointGreen.png")

func reset_port_sprites():
	# Сбрасываем спрайты портов Input Block
	if input_block:
		for port_name in ["OutputA", "OutputB"]:
			var port = input_block.get_node_or_null(port_name)
			if port and is_instance_valid(port):
				var sprite = port.get_node_or_null("Sprite2D")
				if sprite and is_instance_valid(sprite):
					sprite.texture = preload("res://assets/point.png")
	
	# Сбрасываем спрайты портов Output Block
	if output_block:
		var input_port = output_block.get_node_or_null("InputPort")
		if input_port and is_instance_valid(input_port):
			var sprite = input_port.get_node_or_null("Sprite2D")
			if sprite and is_instance_valid(sprite):
				sprite.texture = preload("res://assets/point.png")

func show_success_message():
	# Проверяем, что узел находится в дереве сцены
	if not is_inside_tree():
		return
	
	# Удаляем инструкцию с экрана
	if has_node("OnScreenInstruction"):
		get_node("OnScreenInstruction").queue_free()
	
	# Удаляем предыдущие сообщения подсказок
	if has_node("HintMessage"):
		get_node("HintMessage").queue_free()
	
	var message = Label.new()
	message.text = "Great! Connection successful! ✓"
	
	# Создаем стиль для сообщения
	message.add_theme_color_override("font_color", Color.GREEN)
	message.add_theme_font_size_override("font_size", 32)
	
	var viewport_size = get_viewport_rect().size
	message.position = Vector2(viewport_size.x / 2 - 200, 100)
	
	add_child(message)
	
	# Анимация появления
	message.modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.tween_property(message, "modulate", Color(1, 1, 1, 1), 0.5)
	
	# Удаляем сообщение через 3 секунды
	await get_tree().create_timer(3.0).timeout
	
	if is_instance_valid(message):
		# Анимация исчезновения
		tween = create_tween()
		tween.tween_property(message, "modulate", Color(1, 1, 1, 0), 0.5)
		await tween.finished
		message.queue_free()

func _process(_delta):
	# Проверяем, что узел находится в дереве сцены
	if not is_inside_tree():
		return
	
	# Обновляем провода
	for wire in wires:
		if wire and is_instance_valid(wire):
			if wire.has_method("update_wire"):
				wire.update_wire()
	
	# Обновляем временную линию только если мы в процессе рисования провода
	if drawing_wire and start_port and is_instance_valid(start_port):
		var start_pos = start_port.global_position
		# Добавляем позицию спрайта к позиции порта
		var sprite = start_port.get_node_or_null("Sprite2D")
		if sprite and is_instance_valid(sprite):
			start_pos += sprite.position
		
		var mouse_pos = get_global_mouse_position()
		
		var points_array = []
		points_array.append(start_pos)
		
		var distance = abs(start_pos.x - mouse_pos.x)
		var bend_offset = min(80, distance * 0.3)
		
		if abs(start_pos.y - mouse_pos.y) < 15:
			points_array.append(mouse_pos)
		else:
			if mouse_pos.x >= start_pos.x:
				var bend_point1 = Vector2(start_pos.x + bend_offset, start_pos.y)
				var bend_point2 = Vector2((start_pos.x + bend_offset + mouse_pos.x) / 2, mouse_pos.y)
				points_array.append(bend_point1)
				points_array.append(bend_point2)
			else:
				var bend_point1 = Vector2(start_pos.x - bend_offset, start_pos.y)
				var bend_point2 = Vector2((start_pos.x - bend_offset + mouse_pos.x) / 2, mouse_pos.y)
				points_array.append(bend_point1)
				points_array.append(bend_point2)
			
			points_array.append(mouse_pos)
		
		temp_line.points = points_array
	else:
		# Если не рисуем провод, очищаем временную линию
		temp_line.points = []

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		# При закрытии окна возвращаемся в главное меню
		get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
