extends Node2D

var DEBUG_START_SCENE = "res://VN/vnscenes/main.vnscript" 

func _ready() -> void:
	load_scene(DEBUG_START_SCENE)

func load_scene(path):
	var scene = load("res://vn.tscn").instantiate();
	add_child(scene)
	scene.VN_SCRIPT_SOURCE = path;
	scene._preload()

func load_gd_scene(path):
	print(path)
	get_tree().change_scene_to_file(path)
