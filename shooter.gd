extends Node3D

const DEBUG_LEVEL = 3
const DEBUG_DIFFICULTY = "insane"
const DEBUG_SPEED = 5.0;
const MIN_PLATFORM_LENGTH = 0.6;
const DEBUG_NOOB_COEFICIENT = 0.7;
const JUMP_TIME = 0.4;

var current_directory;
var list_of_levels;
var beatmap_timings;
var beatmap_types;
var time = 0;
var beatmap_index = 0;
var platform;
var target;
var path_to_music = "";

var last_platform_position = 0;
var next_platform_position = 0


@onready var Player = get_node("PlayerController").get_child(0);
@onready var sky: WorldEnvironment = get_node("Sky");
@onready var light = get_node("Light");
@onready var borders = [get_node("Border"), get_node("Border2"), get_node("Border3"), get_node("Border4")]
@onready var timer: Sprite2D = get_node("UI").get_child(0);

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
	target = preload("res://target.tscn");
	beatmap_types[0] = 1
	print(beatmap_timings)

func _process(delta: float) -> void:
	timer.scale.x = (1.0 - time / max(beatmap_timings[-1], 1)) * get_viewport().size.x;
	if (beatmap_index < beatmap_timings.size() - 1):
		time += delta * 1000;
		if (time > beatmap_timings[beatmap_index] - 500):
			if (beatmap_types[beatmap_index] == 1):
				create_platform(beatmap_index)
				print(1);
				var r = randi_range(0, 1) * 255;
				var g = randi_range(0, 1) * 255;
				var b =  randi_range(0, 1) * 255;
				
				if (r == 255 and g == 255 and b == 255):
					light.light_color = Color(250, 160, 150);
				else:
					sky.environment.sky.sky_material.set("shader_parameter/sun_color", Vector3(r + 1, g  + 1, b + 1));
					light.light_color = Color(255 - r, 255 - g, 255 - b);
			else:
				var scene = target.instantiate();
				scene.position.x = Player.position.x + 10;
				scene.position.y = randi_range(1, 3);
				scene.position.z = randi_range(-1, 1);	
				add_child(scene);
			beatmap_index += 1;
			
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
	beatmap_timings = Array(level.get_slice("[HitObjects]", 1).split("\n")).map(func(x): return int( x.get_slice(",", 2)));
	beatmap_types = Array(level.get_slice("[HitObjects]", 1).split("\n")).map(func(x): return int( x.get_slice(",", 3)));
	
	var i = 1;
	var last_slider = 0
	while(i < beatmap_timings.size()):
		if (beatmap_types[i] == 1 and beatmap_timings[i] - last_slider < 4000):
			beatmap_timings.remove_at(i);
			beatmap_types.remove_at(i);
			i -= 1;
		if (beatmap_types[i] == 1): last_slider = beatmap_timings[i]; 
		i += 1;
	
	path_to_music = level.get_slice("AudioFilename: ", 1).get_slice("\n", 0).trim_prefix(" ").trim_suffix("\n");

func create_platform(index: int) ->void:
	var scene = platform.instantiate();
	var next_platform = index + 1;
	while (beatmap_types[next_platform] != 1 and next_platform < len(beatmap_types)):
		next_platform += 1;
	print(beatmap_timings[next_platform], " ", beatmap_timings[index]," ", beatmap_timings[next_platform] - beatmap_timings[index])
	var time_between_platforms = (beatmap_timings[next_platform] - beatmap_timings[index]);
	var duration_as_distance = time_between_platforms / 1000.0 * DEBUG_SPEED; 
	add_child(scene)
	scene.scale.x = duration_as_distance + 0.5;
	scene.position = Vector3(Player.position.x + duration_as_distance /2, 0, next_platform_position);
	scene.id = next_platform + 1;
	last_platform_position = next_platform_position;
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
