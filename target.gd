extends Node3D

const DEBUG_LIFETIME = 1.0;
const DEBUG_DAMAGE = 15;
var is_dying = false;

@onready var root = get_parent();

func delete():
	handle_destroy(time);

var time = 0.0;
var green_level = 0.0
var red_level = 0.0;

func _process(delta):
	time += delta;
	if (time >= DEBUG_LIFETIME and not is_dying): handle_death();
	
	if (time < DEBUG_LIFETIME / 2.0): green_level = 255.0 * time / DEBUG_LIFETIME;
	else:
		green_level = 255.0 * (DEBUG_LIFETIME - time) / DEBUG_LIFETIME;
		red_level = 255.0 * time / DEBUG_LIFETIME;
		
	var material = StandardMaterial3D.new();
	material.shading_mode = 0;
	material.albedo_color = Color(red_level, green_level, 0.0, 1.0);
	get_child(0).material_overlay = material;


func _on_cpu_particles_3d_finished() -> void:
	queue_free()
	
func handle_death():
	root.current_streak = 0;
	root.player_hp = root.player_hp  - DEBUG_DAMAGE;
	queue_free();

func handle_destroy(time):
	root.player_hp = root.player_hp + 1;
	root.current_streak = root.current_streak + 1;
	root.max_streak = max(root.max_streak, root.current_streak);
	root.score = int(root.score + (DEBUG_LIFETIME / 2 - abs(DEBUG_LIFETIME / 2 - time)) * 100);
	get_child(0).queue_free();
	get_child(1).emitting = true;
	is_dying = true;
