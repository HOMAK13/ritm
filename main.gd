extends Node3D

const DEBUG_LEVEL = 3
const DEBUG_DIFFICULTY = "normal"
const DEBUG_SPEED = 5.0;
const MIN_PLATFORM_LENGTH = 0.5;
const DEBUG_NOOB_COEFICIENT = 0.6;
const JUMP_TIME = .5;

var current_directory;
var list_of_levels;
var beatmap;
var time = 0;
var beatmap_index = 0;
var platform;
var path_to_music = "";


@onready var Player = get_node("PlayerController").get_child(0);
@onready var sky: WorldEnvironment = get_node("Sky");
@onready var light = get_node("Light");

func _ready():
	load_level(DEBUG_LEVEL);
	$MusicController.load_music(current_directory + "/" + path_to_music.erase(path_to_music.length() -1));
	platform = preload("res://platform.tscn");
	create_platform(beatmap_index)

func _process(delta: float) -> void:
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
	var time_between_platforms = (beatmap[beatmap_index] - beatmap[beatmap_index - 1]);
	var duration_as_distance = time_between_platforms / 1000.0 * DEBUG_SPEED; 
	add_child(scene)
	scene.scale.x = duration_as_distance - DEBUG_SPEED * JUMP_TIME * DEBUG_NOOB_COEFICIENT;
	scene.position = Vector3(Player.position.x + duration_as_distance/2 + DEBUG_SPEED * JUMP_TIME * DEBUG_NOOB_COEFICIENT, 0, Player.position.z + (randf_range(-.7, .7)));
	scene.id = beatmap_index;
