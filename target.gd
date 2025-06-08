extends Node3D

const DEBUG_LIFETIME = 1.0;

func delete():
	queue_free();

var time = 0.0;
var green_level = 0.0
var red_level = 0.0;

func _process(delta):
	time += delta;
	if (time >= DEBUG_LIFETIME): queue_free()
	
	if (time < DEBUG_LIFETIME / 2.0): green_level = 255.0 * time / DEBUG_LIFETIME;
	else:
		green_level = 255.0 * (DEBUG_LIFETIME - time) / DEBUG_LIFETIME;
		red_level = 255.0 * time / DEBUG_LIFETIME;
	var material = StandardMaterial3D.new();
	material.shading_mode = 0;
	material.albedo_color = Color(red_level, green_level, 0.0, 1.0);
	get_child(0).material_overlay = material;
