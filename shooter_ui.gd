extends Control

@onready var streak_label: Label = get_node("Streak");
@onready var max_streak_label = get_node("MaxStreak");
@onready var score_streak_label = get_node("Score");

func _ready() -> void:
	streak_label.global_position.y = 0.0;
	max_streak_label.global_position.y = get_viewport().size.y / 25.0;
	score_streak_label.global_position.y = 2 * get_viewport().size.y / 25.0;
	
	streak_label.global_position.x = 0;
	max_streak_label.global_position.x = 0;
	score_streak_label.global_position.x = 0;
	
	streak_label.label_settings.font_size = get_viewport().size.y / 25.0
	max_streak_label.label_settings.font_size = get_viewport().size.y / 25.0
	score_streak_label.label_settings.font_size = get_viewport().size.y / 25.0
	
