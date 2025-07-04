extends Control

signal campaign_selected
signal levels_selected
signal settings_opened
signal level_editor_opened
signal game_exited

func _ready():
	var container = VBoxContainer.new()
	container.size = Vector2(400, 500)
	container.position = Vector2(100, 100)
	container.alignment = BoxContainer.ALIGNMENT_BEGIN
	add_child(container)
	container.name = "VBoxContainer"
	
	create_button(container, "CampaignButton", "Кампания", _on_campaign_button_pressed)
	create_button(container, "LevelsButton", "Уровни", _on_levels_button_pressed)
	create_button(container, "SettingsButton", "Настройки", _on_settings_button_pressed)
	create_button(container, "LevelEditorButton", "Редактор уровней", _on_level_editor_button_pressed)
	create_button(container, "ExitButton", "Выход", _on_exit_button_pressed)
	
	await get_tree().process_frame
	$VBoxContainer/CampaignButton.grab_focus()
	
	add_background()

func create_button(container: VBoxContainer, name: String, text: String, callback: Callable):
	var button = Button.new()
	button.name = name
	button.text = text
	button.custom_minimum_size = Vector2(300, 60)
	button.add_theme_font_size_override("font_size", 24)
	button.focus_mode = Control.FOCUS_ALL
	
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_hover_color", Color.LIGHT_BLUE)
	button.add_theme_color_override("font_pressed_color", Color.DARK_BLUE)
	
	button.pressed.connect(callback)
	button.mouse_entered.connect(_on_button_hover.bind(button))
	button.mouse_exited.connect(_on_button_unhover.bind(button))
	
	container.add_child(button)

func add_background():
	var bg: Control
	
	var texture_path = "res://background.png"
	if FileAccess.file_exists(texture_path):
		var texture = load(texture_path)
		var tex_rect = TextureRect.new()
		tex_rect.texture = texture
		tex_rect.stretch_mode = TextureRect.STRETCH_SCALE
		bg = tex_rect
	else:
		var color_rect = ColorRect.new()
		color_rect.color = Color(0.1, 0.1, 0.2, 0.9) 
		bg = color_rect
	
	bg.size = size
	bg.z_index = -1
	add_child(bg)

func _on_button_hover(button: Button):
	button.add_theme_color_override("font_color", Color.LIGHT_BLUE)

func _on_button_unhover(button: Button):
	button.add_theme_color_override("font_color", Color.WHITE)

func _on_campaign_button_pressed():
	print("Запуск кампании...")
	emit_signal("campaign_selected")

func _on_levels_button_pressed():
	print("Открытие выбора уровней...")
	emit_signal("levels_selected")

func _on_settings_button_pressed():
	print("Открытие настроек...")
	emit_signal("settings_opened")

func _on_level_editor_button_pressed():
	print("Запуск редактора уровней...")
	emit_signal("level_editor_opened")

func _on_exit_button_pressed():
	print("Выход из игры...")
	emit_signal("game_exited")
	get_tree().quit()

func show_menu():
	visible = true
	$VBoxContainer/CampaignButton.grab_focus()

func hide_menu():
	visible = false
