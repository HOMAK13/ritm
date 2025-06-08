extends Node3D

# В будущем надо убрать из main меню. Я добавил его сюда временно. Лучше создать отдельную сцену? То же самое для Экрана смерти

const DEBUG_LEVEL = 0
const DEBUG_DIFFICULTY = "hard"
const DEBUG_SPEED = 5.0;
const MIN_PLATFORM_LENGTH = 0.6;
const DEBUG_NOOB_COEFICIENT = 0.7;
const JUMP_TIME = 0.4;

var current_directory;
var list_of_levels;
var beatmap;
var time = 0;
var beatmap_index = 0;
var platform;
var path_to_music = "";
var SENSETIVITY = 0.003;

var last_platform_position = 0;
var next_platform_position = 0


@onready var Player = get_node("PlayerController").get_child(0);
@onready var sky: WorldEnvironment = get_node("Sky");
@onready var light = get_node("Light");
@onready var borders = [get_node("Border"), get_node("Border2"), get_node("Border3"), get_node("Border4")]
@onready var timer: Sprite2D = get_node("UI").get_child(0);

var pause_menu: CanvasLayer
var continue_button: Button
var settings_button: Button
var settings_menu: VBoxContainer
var volume_slider: HSlider
var sensitivity_slider: HSlider
var back_button: Button
var main_menu_container: VBoxContainer
var settings_menu_container: VBoxContainer

var death_screen: CanvasLayer
var death_label: Label
var retry_button: Button
var auto_respawn: bool = false
var auto_respawn_checkbox: CheckBox

func _ready():
	timer.global_position.y = 0;
	load_level(DEBUG_LEVEL);
	for x in borders:
		x.Player = Player;
		var material = StandardMaterial3D.new();
		material.albedo_color = Color(255, 255, 255, 0);
		material.shading_mode = 1;
		x.get_child(0).set_surface_override_material(0, material); 
	$MusicController.load_music(current_directory + "/" + path_to_music.erase(path_to_music.length() -1));
	sky.environment.sky.sky_material.set("shader_parameter/rotation_speed", difficulty_to_rotation_speed(DEBUG_DIFFICULTY));
	platform = preload("res://platform.tscn");
	
	# Экран смерти
	death_screen = CanvasLayer.new()
	death_screen.layer = 2
	death_screen.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(death_screen)
	death_screen.hide()
	
	var background = ColorRect.new()
	background.color = Color(0, 0, 0, 1)
	background.size = Vector2(2000, 2000)
	death_screen.add_child(background)
	
	death_label = Label.new()
	death_label.text = "ПРОБЛЕМА С НАВЫКОМ"
	death_label.add_theme_color_override("font_color", Color.RED)
	death_label.add_theme_font_size_override("font_size", 72)
	death_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	death_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	death_label.size = Vector2(1000, 200)
	death_screen.add_child(death_label)
	
	retry_button = Button.new()
	retry_button.text = "Ещё раз"
	retry_button.custom_minimum_size = Vector2(400, 100)
	retry_button.connect("pressed", _on_retry_button_pressed)
	death_screen.add_child(retry_button)
	
	
	# Меню
	
	pause_menu = CanvasLayer.new()
	pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(pause_menu)
	
	main_menu_container = VBoxContainer.new()
	main_menu_container.alignment = BoxContainer.ALIGNMENT_CENTER
	main_menu_container.custom_minimum_size = Vector2(400, 330)
	pause_menu.add_child(main_menu_container)
	main_menu_container.name = "MainMenu"
	
	continue_button = Button.new()
	continue_button.text = "Продолжить"
	continue_button.custom_minimum_size = Vector2(300, 100)
	main_menu_container.add_child(continue_button)
	
	settings_menu_container = VBoxContainer.new()
	settings_menu_container.alignment = BoxContainer.ALIGNMENT_CENTER
	settings_menu_container.custom_minimum_size = Vector2(400, 300)
	settings_menu_container.name = "SettingsMenu"
	pause_menu.add_child(settings_menu_container)
	settings_menu_container.hide()
	
	
	var settings_label = Label.new()
	settings_label.text = "НАСТРОЙКИ"
	settings_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	settings_label.add_theme_font_size_override("font_size", 32)
	settings_menu_container.add_child(settings_label)
	
	var volume_container = HBoxContainer.new()
	settings_menu_container.add_child(volume_container)
	
	var volume_label = Label.new()
	volume_label.text = "Громкость:"
	volume_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	volume_container.add_child(volume_label)
	
	volume_slider = HSlider.new()
	volume_slider.min_value = 0
	volume_slider.max_value = 100
	volume_slider.value = 80 
	volume_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	volume_container.add_child(volume_slider)
	
	var sensitivity_container = HBoxContainer.new()
	settings_menu_container.add_child(sensitivity_container)
	
	var sensitivity_label = Label.new()
	sensitivity_label.text = "Чувствительность мыши:"
	sensitivity_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sensitivity_container.add_child(sensitivity_label)
	
	sensitivity_slider = HSlider.new()
	sensitivity_slider.min_value = 0.001
	sensitivity_slider.max_value = 0.01
	sensitivity_slider.step = 0.0005
	sensitivity_slider.value = SENSETIVITY
	sensitivity_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sensitivity_container.add_child(sensitivity_slider)
		
	back_button = Button.new()
	back_button.text = "Назад"
	back_button.custom_minimum_size = Vector2(400, 100)
	settings_menu_container.add_child(back_button)
	
	settings_button = Button.new()
	settings_button.text = "Настройки"
	settings_button.custom_minimum_size = Vector2(300, 100)
	main_menu_container.add_child(settings_button)
	back_button.connect("pressed", _on_back_button_pressed)
	volume_slider.connect("value_changed", _on_volume_changed)
	sensitivity_slider.connect("value_changed", _on_sensitivity_changed)
	
	var respawn_container = HBoxContainer.new()
	settings_menu_container.add_child(respawn_container)
	
	var respawn_label = Label.new()
	respawn_label.text = "Автоматическое возрождение:"
	respawn_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	respawn_container.add_child(respawn_label)
	
	auto_respawn_checkbox = CheckBox.new()
	auto_respawn_checkbox.button_pressed = auto_respawn
	auto_respawn_checkbox.connect("toggled", _on_auto_respawn_toggled)
	auto_respawn_checkbox.tooltip_text = "При включении игра автоматически перезапускается после смерти"
	respawn_container.add_child(auto_respawn_checkbox)
	
	apply_volume_settings()
	
	main_menu_container.hide()
	
	continue_button.connect("pressed", _on_continue_button_pressed)
	settings_button.connect("pressed", _on_settings_button_pressed)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	load_settings()

func _process(delta: float) -> void:
	timer.scale.x = (1.0 - time / beatmap[-1]) * get_viewport().size.x;
	if Player.global_transform.origin.y <= -1:
		show_death_screen()
	if (beatmap_index < beatmap.size() - 1):
		time += delta * 1000;
		if (time > beatmap[beatmap_index]):
			beatmap_index += 1;
			
			create_platform(beatmap_index)
			
			var r = randi_range(0, 1) * 255;
			var g = randi_range(0, 1) * 255;
			var b =  randi_range(0, 1) * 255;
			
			if (r == 255 and g == 255 and b == 255):
				light.light_color = Color(250, 160, 150);
			else:
				sky.environment.sky.sky_material.set("shader_parameter/sun_color", Vector3(r + 1, g  + 1, b + 1));
				light.light_color = Color(255 - r, 255 - g, 255 - b);
			
func load_level (index: int):
	var dir: DirAccess = DirAccess.open("user://levels");
	if not dir: 
		DirAccess.make_dir_absolute("user://levels");
		dir = DirAccess.open("user://levels");
	list_of_levels = dir.get_directories();
	current_directory = "user://levels/" + list_of_levels[index];
	dir = DirAccess.open(current_directory);
	var files = dir.get_files();
	var levels = Array(files).filter(func(x): return x.find(".osu") != -1);
	
	var level
	
	if levels.any(func(x): return x.to_lower().find(DEBUG_DIFFICULTY) != -1):
		level = FileAccess.open(current_directory + "/" + levels.filter(func(x): return x.to_lower().find(DEBUG_DIFFICULTY) != -1)[0], FileAccess.READ).get_as_text();
	else :
		level = FileAccess.open(current_directory + "/" + levels[0], FileAccess.READ).get_as_text();
	beatmap = Array(level.get_slice("[HitObjects]", 1).split("\n")).map(func(x): return int( x.get_slice(",", 2)));
		
	var i = 1;
	while (i < beatmap.size()):
		if float(beatmap[i] - beatmap[i - 1])/1000.0 * DEBUG_SPEED < MIN_PLATFORM_LENGTH + (DEBUG_SPEED * JUMP_TIME) * 0.75:
			beatmap.remove_at(i)
			i -= 1
		i += 1;
		print(i)
	
	path_to_music = level.get_slice("AudioFilename: ", 1).get_slice("\n", 0).trim_prefix(" ").trim_suffix("\n");
	print(path_to_music)
	
func create_platform(index: int) ->void:
	var scene = platform.instantiate();
	scene.add_to_group("platform")
	var time_between_platforms = (beatmap[beatmap_index] - beatmap[beatmap_index - 1]);
	var duration_as_distance = time_between_platforms / 1000.0 * DEBUG_SPEED; 
	add_child(scene)
	scene.scale.x = duration_as_distance - DEBUG_SPEED * JUMP_TIME * DEBUG_NOOB_COEFICIENT;
	var c = duration_as_distance/2 + DEBUG_SPEED * JUMP_TIME * DEBUG_NOOB_COEFICIENT;
	var a = abs(last_platform_position - next_platform_position);
	var distance_to_next_platform = sqrt(max(c ** 2 - a ** 2, 0));
	last_platform_position = next_platform_position;
	scene.position = Vector3(Player.position.x + distance_to_next_platform , 0, next_platform_position);
	scene.id = beatmap_index;
	next_platform_position = randi_range(-1, 1);
	highlight_next_position(next_platform_position);
	
func highlight_next_position(next_position: int):
	next_position += 1;
	for x in borders:
		var a: MeshInstance3D =  x.get_child(0)
		var material = a.get_surface_override_material(0);
		material.shading_mode = 0;
		material.transparency = 1;
		material.albedo_color = Color(255, 255, 255, 0.4);
		a.set_surface_override_material(0, material);
		a.material_overlay = material;
	
	for x in range(next_position, next_position + 2):
		var a: MeshInstance3D =  borders[x].get_child(0)
		var material = a.get_surface_override_material(0);
		material.shading_mode = 0;
		material.transparency = 1;
		material.albedo_color = Color(255, 0, 0, 0.4);
		a.set_surface_override_material(0, material);
		a.material_overlay = material;
		
func difficulty_to_rotation_speed(difficulty: String):
	if (difficulty == "easy"): return 0.4
	if (difficulty == "normsl"): return 0.6
	if (difficulty == "hard"): return 0.8
	if (difficulty == "insane"): return 1
	return 0.5
	
	
	# Экран смерти
func show_death_screen():
	if auto_respawn:
		reset_game()
		return
	
	get_tree().paused = true
	$MusicController.stop() 
	
	var viewport_size = get_viewport().size
	death_label.position = Vector2(
		(viewport_size.x - death_label.size.x) / 2,
		(viewport_size.y - death_label.size.y) / 2 - 100
	)
	retry_button.position = Vector2(
		(viewport_size.x - retry_button.size.x) / 2,
		(viewport_size.y - retry_button.size.y) / 2 + 100
	)
	
	death_screen.show()
	retry_button.grab_focus()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func _on_auto_respawn_toggled(button_pressed: bool):
	auto_respawn = button_pressed
	save_settings()


func _on_retry_button_pressed():
	reset_game()
	death_screen.hide()
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func reset_game():
	for child in get_children():
		if child.is_in_group("platform"):
			child.queue_free()
	
	time = 0
	beatmap_index = 0
	last_platform_position = 0
	next_platform_position = 0
	

	Player.global_transform.origin = Vector3(0, 2, 0)
	Player.velocity = Vector3.ZERO
	
	load_level(DEBUG_LEVEL)
	
	$MusicController.play()
	

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused:
			if settings_menu_container.visible:
				_on_back_button_pressed()
			else:
				_on_continue_button_pressed()
		else:
			get_tree().paused = true
			$MusicController.set_process(false)
			_update_menu_position()
			pause_menu.get_node("MainMenu").show()
			settings_button.grab_focus()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			
func _on_continue_button_pressed():
	get_tree().paused = false
	$MusicController.set_process(true)
	pause_menu.get_node("MainMenu").hide()
	settings_menu_container.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _on_settings_button_pressed() -> void:
	pause_menu.get_node("MainMenu").hide()
	settings_menu_container.show()
	back_button.grab_focus()
	
func _update_menu_position():
	if not is_instance_valid(main_menu_container) or not is_instance_valid(settings_menu_container):
		return
	var viewport_size = get_viewport().size
	
	main_menu_container.position = Vector2(
		(viewport_size.x - main_menu_container.size.x) / 2,
		(viewport_size.y - main_menu_container.size.y) / 2
	)
	settings_menu_container.position = Vector2(
		(viewport_size.x - settings_menu_container.size.x) / 2,
		(viewport_size.y - settings_menu_container.size.y) / 2
	)
	
func _on_back_button_pressed():
	settings_menu_container.hide()
	pause_menu.get_node("MainMenu").show()
	settings_button.grab_focus()
	
func _on_volume_changed(value: float):
	apply_volume_settings()
	save_settings()
	
func _on_sensitivity_changed(value: float):
	SENSETIVITY = value
	if Player.has_method("set_mouse_sensitivity"):
		Player.set_mouse_sensitivity(SENSETIVITY)
		save_settings()
		
func apply_volume_settings():
	var volume_db = linear_to_db(volume_slider.value / 100.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume_db)
	$MusicController.update_volume(volume_slider.value / 100.0)
	
func save_settings():
	var config = {
		"volume": volume_slider.value,
		"sensitivity": sensitivity_slider.value,
		"auto_respawn": auto_respawn
	}
	var file = FileAccess.open("user://settings.cfg", FileAccess.WRITE)
	file.store_var(config)

func load_settings():
	if FileAccess.file_exists("user://settings.cfg"):
		var file = FileAccess.open("user://settings.cfg", FileAccess.READ)
		var config = file.get_var()
		volume_slider.value = config.get("volume", 80)
		sensitivity_slider.value = config.get("sensitivity", 0.1)
		auto_respawn = config.get("auto_respawn", false)
		
		if auto_respawn_checkbox:
			auto_respawn_checkbox.button_pressed = auto_respawn
		
		apply_volume_settings()
		_on_sensitivity_changed(sensitivity_slider.value)
	
	
