extends Control

@onready var left_panel = $HBoxContainer/LeftPanel
@onready var right_panel = $HBoxContainer/RightPanel
@onready var arcade_container = $HBoxContainer/RightPanel/ArcadeContainer
@onready var level_list = $HBoxContainer/RightPanel/ArcadeContainer/ScrollContainer/LevelList
@onready var settings_container = $HBoxContainer/RightPanel/SettingsContainer

var volume_slider: HSlider
var sensitivity_slider: HSlider
var auto_respawn_checkbox: CheckBox
var back_button: Button

var level_directories = []
var selected_level: String = ""

var game_settings: Dictionary = {
	"volume": 80.0,
	"sensitivity": 0.003,
	"auto_respawn": false
}

func _ready():
	load_settings()
	
	apply_volume_settings()
	
	arcade_container.hide()
	settings_container.hide()
	
	load_levels()
	
	create_menu_buttons()
	
	configure_ui_style()

func configure_ui_style():
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.1, 0.15, 0.8)
	panel_style.border_color = Color(0.3, 0.3, 0.4)
	panel_style.border_width_bottom = 2
	panel_style.border_width_top = 2
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	
	left_panel.add_theme_stylebox_override("panel", panel_style)
	right_panel.add_theme_stylebox_override("panel", panel_style)
	
	var button_style = StyleBoxFlat.new()
	button_style.bg_color = Color(0.2, 0.2, 0.3)
	button_style.border_color = Color(0.5, 0.5, 0.7)
	button_style.border_width_bottom = 2
	button_style.border_width_top = 2
	button_style.border_width_left = 2
	button_style.border_width_right = 2
	button_style.corner_radius_bottom_left = 5
	button_style.corner_radius_bottom_right = 5
	button_style.corner_radius_top_left = 5
	button_style.corner_radius_top_right = 5
	
	for node in get_tree().get_nodes_in_group("menu_button"):
		node.add_theme_stylebox_override("normal", button_style)
		
		var hover_style = button_style.duplicate()
		hover_style.bg_color = Color(0.3, 0.3, 0.4)
		node.add_theme_stylebox_override("hover", hover_style)
		
		var pressed_style = button_style.duplicate()
		pressed_style.bg_color = Color(0.4, 0.4, 0.6)
		node.add_theme_stylebox_override("pressed", pressed_style)

func create_menu_buttons():
	var buttons = [
		{"text": "Аркада", "callback": "_on_arcade_pressed"},
		{"text": "Настройки", "callback": "_on_settings_pressed"},
		{"text": "Выход", "callback": "_on_quit_pressed"}
	]
	
	for button_info in buttons:
		var button = Button.new()
		button.text = button_info["text"]
		button.custom_minimum_size = Vector2(250, 60)
		button.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		button.add_theme_font_size_override("font_size", 28)
		button.connect("pressed", Callable(self, button_info["callback"]))
		button.add_to_group("menu_button")
		left_panel.add_child(button)
		
		if button_info != buttons.back():
			var separator = HSeparator.new()
			separator.custom_minimum_size.y = 10
			left_panel.add_child(separator)

func load_levels():
	for child in level_list.get_children():
		child.queue_free()
	
	var dir = DirAccess.open("user://levels")
	if not dir:
		print("Папка с уровнями не найдена")
		create_empty_levels_message()
		return
	
	level_directories = dir.get_directories()
	if level_directories.is_empty():
		print("Уровни не найдены")
		create_empty_levels_message()
		return
	
	for level_dir in level_directories:
		var button = Button.new()
		button.text = level_dir.replace("_", " ").capitalize()
		button.custom_minimum_size = Vector2(300, 70)
		button.add_theme_font_size_override("font_size", 24)
		button.connect("pressed", Callable(self, "_on_level_selected").bind(level_dir))
		button.add_to_group("menu_button")
		level_list.add_child(button)
		
		var separator = HSeparator.new()
		separator.custom_minimum_size.y = 5
		level_list.add_child(separator)

func create_empty_levels_message():
	var message = Label.new()
	message.text = "Уровни не найдены!\nПоместите .osu файлы в папку user://levels"
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message.add_theme_font_size_override("font_size", 22)
	level_list.add_child(message)

func create_settings_ui():
	for child in settings_container.get_children():
		child.queue_free()
	
	var settings_vbox = VBoxContainer.new()
	settings_container.add_child(settings_vbox)
	
	var settings_label = Label.new()
	settings_label.text = "НАСТРОЙКИ"
	settings_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	settings_label.add_theme_font_size_override("font_size", 32)
	settings_vbox.add_child(settings_label)
	
	var volume_container = HBoxContainer.new()
	settings_vbox.add_child(volume_container)
	
	var volume_label = Label.new()
	volume_label.text = "Громкость:"
	volume_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	volume_container.add_child(volume_label)
	
	volume_slider = HSlider.new()
	volume_slider.min_value = 0
	volume_slider.max_value = 100
	volume_slider.value = game_settings["volume"]
	volume_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	volume_container.add_child(volume_slider)
	
	var sensitivity_container = HBoxContainer.new()
	settings_vbox.add_child(sensitivity_container)
	
	var sensitivity_label = Label.new()
	sensitivity_label.text = "Чувствительность мыши:"
	sensitivity_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sensitivity_container.add_child(sensitivity_label)
	
	sensitivity_slider = HSlider.new()
	sensitivity_slider.min_value = 0.001
	sensitivity_slider.max_value = 0.01
	sensitivity_slider.step = 0.0005
	sensitivity_slider.value = game_settings["sensitivity"]
	sensitivity_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sensitivity_container.add_child(sensitivity_slider)
	
	var respawn_container = HBoxContainer.new()
	settings_vbox.add_child(respawn_container)
	
	var respawn_label = Label.new()
	respawn_label.text = "Автоматическое возрождение:"
	respawn_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	respawn_container.add_child(respawn_label)
	
	auto_respawn_checkbox = CheckBox.new()
	auto_respawn_checkbox.button_pressed = game_settings["auto_respawn"]
	respawn_container.add_child(auto_respawn_checkbox)
	
	back_button = Button.new()
	back_button.text = "Назад"
	back_button.custom_minimum_size = Vector2(200, 50)
	settings_vbox.add_child(back_button)
	
	volume_slider.connect("value_changed", Callable(self, "_on_volume_changed"))
	sensitivity_slider.connect("value_changed", Callable(self, "_on_sensitivity_changed"))
	auto_respawn_checkbox.connect("toggled", Callable(self, "_on_auto_respawn_toggled"))
	back_button.connect("pressed", Callable(self, "_on_back_button_pressed"))

func _on_arcade_pressed():
	settings_container.hide()
	arcade_container.show()

func _on_settings_pressed():
	arcade_container.hide()
	
	create_settings_ui()
	settings_container.show()

func _on_level_selected(level_name):
	selected_level = level_name
	get_tree().change_scene_to_file("res://game.tscn")

func _on_quit_pressed():
	get_tree().quit()

func _on_back_button_pressed():
	settings_container.hide()
	arcade_container.hide()

func _on_volume_changed(value):
	game_settings["volume"] = value
	apply_volume_settings()
	save_settings()

func _on_sensitivity_changed(value):
	game_settings["sensitivity"] = value
	save_settings()

func _on_auto_respawn_toggled(toggled):
	game_settings["auto_respawn"] = toggled
	save_settings()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_settings()

func load_settings():
	if FileAccess.file_exists("user://settings.cfg"):
		var file = FileAccess.open("user://settings.cfg", FileAccess.READ)
		var config = file.get_var()
		if config:
			game_settings = config
		else:
			game_settings = {
				"volume": 80.0,
				"sensitivity": 0.003,
				"auto_respawn": false
			}
	else:
		save_settings()

func save_settings():
	var file = FileAccess.open("user://settings.cfg", FileAccess.WRITE)
	file.store_var(game_settings)

# Применение настроек звука
func apply_volume_settings():
	var volume_db = linear_to_db(game_settings["volume"] / 100.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume_db)
