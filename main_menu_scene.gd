extends Node3D

var menu_width = 400
var menu_height = 500
var button_height = 60

var game_settings = {
	"volume": 80.0,
	"sensitivity": 0.003,
	"auto_respawn": false
}

var canvas_layer: CanvasLayer
var menu_container: Control
var settings_container: Control
var levels_container: Control
var volume_slider: HSlider
var sensitivity_slider: HSlider
var auto_respawn_checkbox: CheckBox

var DT: CheckBox
var HT: CheckBox
var DRUNK: CheckBox
var FTM: CheckBox
var FIVE_TILES: CheckBox
var SEVEN_TILES: CheckBox
var NF: CheckBox

var selected_level_index: int = -1
var level_paths = []

func _ready():
	if !OS.has_feature("editor"):
		var exe_dir = OS.get_executable_path().get_base_dir()
		var dir = DirAccess.open(exe_dir)
		if dir:
			if !dir.dir_exists("levels"):
				dir.make_dir("levels")
	
	load_settings()
	
	canvas_layer = CanvasLayer.new()
	add_child(canvas_layer)
	
	var menu_size = Vector2(menu_width, menu_height)
	var viewport_size = Vector2(get_viewport().size)
	
	var title_label = Label.new()
	title_label.text = "RITM"
	title_label.add_theme_font_size_override("font_size", 144) 
	title_label.add_theme_color_override("font_color", Color.WHITE)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.size = Vector2(viewport_size.x, 200) 
	canvas_layer.add_child(title_label)
	
	menu_container = Control.new()
	menu_container.size = menu_size
	menu_container.position = (viewport_size - menu_size) / 2
	canvas_layer.add_child(menu_container)
	
	var title_position_y = menu_container.position.y - title_label.size.y + 20
	title_label.position = Vector2(0, title_position_y)
	
	var background = ColorRect.new()
	background.color = Color(0.1, 0.1, 0.2, 0.9)
	background.size = menu_size
	menu_container.add_child(background)
	
	var main_vbox = VBoxContainer.new()
	main_vbox.size = menu_size - Vector2(40, 40)
	main_vbox.position = Vector2(20, 20)
	main_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	menu_container.add_child(main_vbox)
	
	var separator = HSeparator.new()
	separator.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(separator)
	
	var vbox = VBoxContainer.new()
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	main_vbox.add_child(vbox)
	
	var button_size = Vector2(300, 60)
	create_button(vbox, button_size, "Уровни", _on_levels_button_pressed)
	create_button(vbox, button_size, "Настройки", _on_settings_button_pressed)
	create_button(vbox, button_size, "Редактор уровней", _on_level_editor_button_pressed)
	create_button(vbox, button_size, "Выход", _on_exit_button_pressed)
	
	if vbox.get_child_count() > 0:
		vbox.get_child(0).grab_focus()

func create_button(container: VBoxContainer, size: Vector2, text: String, callback: Callable):
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = size
	button.add_theme_font_size_override("font_size", 24)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_hover_color", Color.LIGHT_BLUE)
	button.pressed.connect(callback)
	container.add_child(button)

func _on_settings_button_pressed():
	hide_all_panels()
	
	if settings_container == null:
		create_settings_ui()
	settings_container.visible = true

func _on_levels_button_pressed():
	hide_all_panels()
	
	if levels_container == null:
		create_levels_ui()
	levels_container.visible = true

func hide_all_panels():
	if settings_container:
		settings_container.visible = false
	if levels_container:
		levels_container.visible = false

func create_settings_ui():
	settings_container = Control.new()
	settings_container.size = Vector2(400, 300)
	settings_container.position = Vector2(50, 150)
	settings_container.visible = false
	
	canvas_layer.add_child(settings_container)
	
	var bg = ColorRect.new()
	bg.color = Color(0.15, 0.15, 0.2, 0.95)
	bg.size = settings_container.size
	settings_container.add_child(bg)
	
	var vbox = VBoxContainer.new()
	vbox.size = settings_container.size - Vector2(20, 20)
	vbox.position = Vector2(10, 10)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	settings_container.add_child(vbox)
	
	var title = Label.new()
	title.text = "НАСТРОЙКИ"
	title.add_theme_font_size_override("font_size", 28)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	
	vbox.add_child(Control.new())
	
	var volume_container = HBoxContainer.new()
	volume_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(volume_container)
	
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
	sensitivity_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(sensitivity_container)
	
	var sensitivity_label = Label.new()
	sensitivity_label.text = "Чувствительность:"
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
	respawn_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(respawn_container)
	
	var respawn_label = Label.new()
	respawn_label.text = "Авто-респавн:"
	respawn_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	respawn_container.add_child(respawn_label)
	
	auto_respawn_checkbox = CheckBox.new()
	auto_respawn_checkbox.button_pressed = game_settings["auto_respawn"]
	respawn_container.add_child(auto_respawn_checkbox)
	
	var close_button = Button.new()
	close_button.text = "Закрыть"
	close_button.custom_minimum_size = Vector2(150, 40)
	close_button.pressed.connect(func(): settings_container.visible = false)
	vbox.add_child(close_button)
	
	volume_slider.value_changed.connect(_on_volume_changed)
	sensitivity_slider.value_changed.connect(_on_sensitivity_changed)
	auto_respawn_checkbox.toggled.connect(_on_auto_respawn_toggled)

func create_levels_ui():
	levels_container = Control.new()
	levels_container.size = get_viewport().size
	levels_container.visible = false
	canvas_layer.add_child(levels_container)
	
	var full_bg = ColorRect.new()
	full_bg.color = Color(0.1, 0.1, 0.2, 0.95)
	full_bg.size = levels_container.size
	levels_container.add_child(full_bg)
	
	var main_hbox = HBoxContainer.new()
	main_hbox.size = levels_container.size
	levels_container.add_child(main_hbox)
	
	var left_panel = VBoxContainer.new()
	left_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_panel.size_flags_stretch_ratio = 0.6
	main_hbox.add_child(left_panel)
	
	var levels_title = Label.new()
	levels_title.text = "ВЫБОР УРОВНЯ"
	levels_title.add_theme_font_size_override("font_size", 28)
	levels_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	left_panel.add_child(levels_title)
	
	var levels_scroll = ScrollContainer.new()
	levels_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	levels_scroll.add_theme_constant_override("margin_left", 10)
	levels_scroll.add_theme_constant_override("margin_right", 10)
	levels_scroll.add_theme_constant_override("margin_bottom", 10)
	left_panel.add_child(levels_scroll)
	
	var levels_list = VBoxContainer.new()
	levels_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	levels_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	levels_list.add_theme_constant_override("separation", 10)
	levels_scroll.add_child(levels_list)
	
	load_real_levels(levels_list)
	
	var right_panel = VBoxContainer.new()
	right_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_panel.size_flags_stretch_ratio = 0.4
	main_hbox.add_child(right_panel)
	
	var mods_title = Label.new()
	mods_title.text = "МОДИФИКАТОРЫ"
	mods_title.add_theme_font_size_override("font_size", 28)
	mods_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	right_panel.add_child(mods_title)
	
	var play_button = Button.new()
	play_button.text = "Играть"
	play_button.custom_minimum_size = Vector2(0, 60)
	play_button.add_theme_font_size_override("font_size", 24)
	play_button.pressed.connect(_on_play_level_pressed)
	right_panel.add_child(play_button)
	
	var mods_container = VBoxContainer.new()
	mods_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	mods_container.add_theme_constant_override("separation", 10)
	mods_container.add_theme_constant_override("margin_left", 20)
	mods_container.add_theme_constant_override("margin_right", 20)
	right_panel.add_child(mods_container)
	
	DT = CheckBox.new()
	DT.text = "Double Time"
	DT.add_theme_font_size_override("font_size", 20)
	mods_container.add_child(DT)
	DT.pressed.connect(func(): _set_dt_mode(DT.button_pressed))
	
	HT = CheckBox.new()
	HT.text = "Half Time"
	HT.add_theme_font_size_override("font_size", 20)
	mods_container.add_child(HT)
	HT.pressed.connect(func(): _set_ht_mode(HT.button_pressed))
	
	FIVE_TILES = CheckBox.new()
	FIVE_TILES.text = "Five Tiles"
	FIVE_TILES.add_theme_font_size_override("font_size", 20)
	mods_container.add_child(FIVE_TILES)
	FIVE_TILES.pressed.connect(func(): _set_5t_mode(FIVE_TILES.button_pressed))
	
	SEVEN_TILES = CheckBox.new()
	SEVEN_TILES.text = "Seven Tiles"
	SEVEN_TILES.add_theme_font_size_override("font_size", 20)
	mods_container.add_child(SEVEN_TILES)
	SEVEN_TILES.pressed.connect(func(): _set_7t_mode(SEVEN_TILES.button_pressed))
	
	DRUNK = CheckBox.new()
	DRUNK.text = "Пьяный мастер"
	DRUNK.add_theme_font_size_override("font_size", 20)
	mods_container.add_child(DRUNK)
	DRUNK.pressed.connect(func(): Global.DRUNK_MODE = DRUNK.button_pressed)
	
	FTM = CheckBox.new()
	FTM.text = "Чувствуй!"
	FTM.add_theme_font_size_override("font_size", 20)
	mods_container.add_child(FTM)
	FTM.pressed.connect(func(): Global.FTM_MODE = FTM.button_pressed)
	
	NF = CheckBox.new()
	NF.text = "Одна ошибка и ты ошибся!"
	NF.add_theme_font_size_override("font_size", 20)
	mods_container.add_child(NF)
	NF.pressed.connect(func(): Global.NF_MODE = NF.button_pressed)
	
	var close_button = Button.new()
	close_button.text = "Закрыть"
	close_button.custom_minimum_size = Vector2(0, 60)
	close_button.add_theme_font_size_override("font_size", 24)
	close_button.pressed.connect(_hide_level_menu)
	right_panel.add_child(close_button)

func _hide_level_menu():
	levels_container.visible = false

func load_real_levels(container: VBoxContainer):
	for child in container.get_children():
		child.queue_free()
	
	level_paths = []
	
	# Определяем путь к папке с уровнями
	var levels_dir_path
	if OS.has_feature("editor"):
		levels_dir_path = "res://levels"  # В редакторе
	else:
		# В экспортированной версии - рядом с исполняемым файлом
		levels_dir_path = OS.get_executable_path().get_base_dir().path_join("levels")
	
	# Загружаем уровни из папки
	var dir = DirAccess.open(levels_dir_path)
	if dir:
		dir.list_dir_begin()
		var folder = dir.get_next()
		while folder != "":
			if dir.current_is_dir() and folder != "." and folder != "..":
				level_paths.append(levels_dir_path.path_join(folder))
			folder = dir.get_next()
	else:
		print("Не удалось открыть папку уровней: ", levels_dir_path)
	
	if level_paths.is_empty():
		create_empty_levels_message(container)
		return
	
	# Создаем кнопки для каждого уровня
	for i in range(level_paths.size()):
		var path = level_paths[i]
		var dir_name = path.get_file()
		var button = Button.new()
		button.text = dir_name.replace("_", " ").capitalize()
		button.custom_minimum_size = Vector2(0, 60)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size", 22)
		button.connect("pressed", Callable(self, "_on_level_path_selected").bind(i))
		container.add_child(button)
		
		var separator = HSeparator.new()
		separator.custom_minimum_size.y = 5
		container.add_child(separator)

func _on_level_path_selected(index: int):
	selected_level_index = index
	Global.selected_level_path = level_paths[index]
	print("Выбран уровень: ", Global.selected_level_path)

func _on_play_level_pressed():
	if selected_level_index >= 0:
		print("Запуск уровня: ", Global.selected_level_path)
		get_tree().change_scene_to_file("res://main.tscn")
	else:
		print("Уровень не выбран")

func create_empty_levels_message(container: VBoxContainer):
	var message = Label.new()
	message.text = "Уровни не найдены!\nПоместите папки с уровнями в папку:\n" + OS.get_executable_path().get_base_dir().path_join("levels")
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message.add_theme_font_size_override("font_size", 22)
	container.add_child(message)

func _on_volume_changed(value: float):
	game_settings["volume"] = value
	apply_volume(value)
	save_settings()

func _on_sensitivity_changed(value: float):
	game_settings["sensitivity"] = value
	save_settings()

func _on_auto_respawn_toggled(toggled: bool):
	game_settings["auto_respawn"] = toggled
	save_settings()

func apply_volume(value: float):
	var volume_db = linear_to_db(value / 100.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume_db)

func load_settings():
	if FileAccess.file_exists("user://settings.cfg"):
		var file = FileAccess.open("user://settings.cfg", FileAccess.READ)
		var config = file.get_var()
		if config:
			game_settings = config
			apply_volume(game_settings["volume"])
	else:
		save_settings()

func save_settings():
	var file = FileAccess.open("user://settings.cfg", FileAccess.WRITE)
	file.store_var(game_settings)

func _on_level_editor_button_pressed():
	get_tree().change_scene_to_file("res://Editor.tscn")

func _on_exit_button_pressed():
	save_settings()
	get_tree().quit()

func _set_dt_mode(on):
	if on:
		Global.DT_MODE = true
		Global.HT_MODE = false
		if HT:
			HT.button_pressed = false
	else:
		Global.DT_MODE = false

func _set_ht_mode(on):
	if on:
		Global.HT_MODE = true
		Global.DT_MODE = false
		if DT:
			DT.button_pressed = false
	else:
		Global.HT_MODE = false

func _set_5t_mode(on):
	if on:
		Global.FIVE_TILE_MODE = true
		Global.SEVEN_TILE_MODE = false
		if SEVEN_TILES:
			SEVEN_TILES.button_pressed = false
	else:
		Global.FIVE_TILE_MODE = false

func _set_7t_mode(on):
	if on:
		Global.SEVEN_TILE_MODE = true
		Global.FIVE_TILE_MODE = false
		if FIVE_TILES:
			FIVE_TILES.button_pressed = false
	else:
		Global.SEVEN_TILE_MODE = false
